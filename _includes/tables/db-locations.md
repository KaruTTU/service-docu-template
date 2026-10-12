{%- comment -%}
  Databases of one environment, grouped by where they run: one block per shared database
  server (env.db_servers), then one per host of databases that have their own host/port.
  Matches the boxes in mermaid/db-placement.md. The server's host, port, notes and (if all
  databases on it share one) engine are shown once, above its table, followed by its nodes
  (db_servers.<id>.nodes) when it is a cluster.
  Params: service - service slug; env - environment id
{%- endcomment -%}
{%- assign dl_svc = site.data[include.service] -%}
{%- assign dl_env = dl_svc.environments | where: "id", include.env | first -%}
{%- assign dl_none = "" | split: "" -%}
{%- assign dl_hosts = dl_none -%}
{%- for d in dl_svc.databases -%}
  {%- assign dl_loc = dl_env.databases[d.id] -%}
  {%- unless dl_loc.server -%}{%- assign dl_hosts = dl_hosts | push: dl_loc.host -%}{%- endunless -%}
{%- endfor -%}
{%- assign dl_hosts = dl_hosts | uniq -%}
{%- for s in dl_env.db_servers %}
{%- assign dl_sid = s[0] %}{% assign dl_server = s[1] %}
{%- assign dl_dbs = dl_none %}
{%- for d in dl_svc.databases %}{% if dl_env.databases[d.id].server == dl_sid %}{% assign dl_dbs = dl_dbs | push: d %}{% endif %}{% endfor %}
{%- assign dl_engines = dl_dbs | map: "engine" | uniq %}

#### {{ dl_sid }}
{: .no_toc }

`{{ dl_server.host }}:{{ dl_server.port }}`{% if dl_engines.size == 1 %} · {{ dl_engines[0] | escape }}{% endif %}{% if dl_server.notes %} · {{ dl_server.notes | escape }}{% endif %}
{% include tables/db-nodes.md env=dl_env server=dl_sid %}

| Database | Schema |{% if dl_engines.size > 1 %} Engine |{% endif %} Owner | Also used by |
|:---------|:-------|{% if dl_engines.size > 1 %}:-------|{% endif %}:------|:-------------|
{% for d in dl_dbs -%}
{%- assign dl_users = dl_svc.connections | where: "to", d.id | map: "from" | uniq -%}
| {{ d.name | default: d.id | escape }} | `{{ dl_env.databases[d.id].schema }}` |{% if dl_engines.size > 1 %} {{ d.engine | escape }} |{% endif %} {% include entity-name.md service=include.service id=d.owner %} | {% assign dl_first = true %}{% for u in dl_users %}{% unless u == d.owner %}{% unless dl_first %}, {% endunless %}{% include entity-name.md service=include.service id=u %}{% assign dl_first = false %}{% endunless %}{% endfor %} |
{% endfor %}
{%- endfor %}
{%- for h in dl_hosts %}
{%- assign dl_title = h %}{% assign dl_cohost = nil %}
{%- for c in dl_svc.components %}{% if dl_env.components[c.id].hosts contains h %}{% assign dl_cohost = c %}{% endif %}{% endfor %}

#### {% if dl_cohost %}{{ dl_cohost.name | escape }} host{% else %}{{ h }}{% endif %}
{: .no_toc }

`{{ h }}`{% if dl_cohost %} · shared with {% include entity-name.md service=include.service id=dl_cohost.id %}{% endif %}

| Database | Schema | Port | Engine | Owner | Also used by |
|:---------|:-------|-----:|:-------|:------|:-------------|
{% for d in dl_svc.databases -%}
{%- assign dl_loc = dl_env.databases[d.id] -%}
{%- if dl_loc.server == nil and dl_loc.host == h -%}
{%- assign dl_users = dl_svc.connections | where: "to", d.id | map: "from" | uniq -%}
| {{ d.name | default: d.id | escape }} | `{{ dl_loc.schema }}` | {{ dl_loc.port }} | {{ d.engine | escape }} | {% include entity-name.md service=include.service id=d.owner %} | {% assign dl_first = true %}{% for u in dl_users %}{% unless u == d.owner %}{% unless dl_first %}, {% endunless %}{% include entity-name.md service=include.service id=u %}{% assign dl_first = false %}{% endunless %}{% endfor %} |
{% endif -%}
{%- endfor %}
{%- endfor %}
