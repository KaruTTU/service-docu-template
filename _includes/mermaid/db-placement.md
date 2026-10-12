{%- comment -%}
  Database placement in one environment. Every database is drawn inside a box for where it runs:
  a shared server from env.db_servers, or the host it has its own host/port on. A host box that is
  also a component's (only) host contains that component, so co-located services are visible.
  Components connect with solid edges (owner) or dashed edges (access), as in the data diagram;
  a component that uses every database in a box the same way gets one edge to the box.
  Params: service - service slug; env - environment id
{%- endcomment -%}
{%- assign dp_svc = site.data[include.service] -%}
{%- assign dp_env = dp_svc.environments | where: "id", include.env | first -%}
{%- assign dp_db_ids = dp_svc.databases | map: "id" -%}
{%- assign dp_none = "" | split: "" -%}
{%- include mermaid/box-styles.md -%}

{%- comment -%} Hosts of databases that are not on a shared server, in database order. {%- endcomment -%}
{%- assign dp_hosts = dp_none -%}
{%- for d in dp_svc.databases -%}
  {%- assign dp_loc = dp_env.databases[d.id] -%}
  {%- unless dp_loc.server -%}{%- assign dp_hosts = dp_hosts | push: dp_loc.host -%}{%- endunless -%}
{%- endfor -%}
{%- assign dp_hosts = dp_hosts | uniq -%}

{%- comment -%} Components whose single host is one of those hosts are drawn inside its box. {%- endcomment -%}
{%- assign dp_inside = dp_none -%}
{%- for c in dp_svc.components -%}
  {%- assign dp_ch = dp_env.components[c.id].hosts -%}
  {%- if dp_ch.size == 1 and dp_hosts contains dp_ch[0] -%}{%- assign dp_inside = dp_inside | push: c.id -%}{%- endif -%}
{%- endfor -%}
```mermaid
flowchart LR
{%- for c in dp_svc.components %}
  {%- assign dp_uses = dp_svc.connections | where: "from", c.id | where_exp: "e", "dp_db_ids contains e.to" %}
  {%- if dp_uses.size > 0 %}{% unless dp_inside contains c.id %}
  {% include mermaid/node-id.md id=c.id %}["{% include mermaid/label.md text=c.name %}"]:::comp
  {%- endunless %}{% endif %}
{%- endfor %}
{%- for s in dp_env.db_servers %}
  {%- assign dp_sid = s[0] %}{% assign dp_server = s[1] %}
  {%- assign dp_sites = dp_server.nodes | map: "site" | compact | uniq %}
  subgraph x_server_{{ dp_sid | slugify | replace: "-", "_" }}["{% include mermaid/label.md text=dp_sid %} · {% include mermaid/label.md text=dp_server.host %}:{{ dp_server.port }}
    {%- if dp_server.nodes %}<br/>{{ dp_server.nodes.size }} nodes{% if dp_sites.size > 1 %} across {{ dp_sites.size }} sites{% endif %}{% endif %}"]
  {%- for d in dp_svc.databases %}
    {%- assign dp_loc = dp_env.databases[d.id] %}
    {%- if dp_loc.server == dp_sid %}
    {% include mermaid/node-id.md id=d.id %}[("{% include mermaid/label.md text=d.name %}")]:::db
    {%- endif %}
  {%- endfor %}
  end
  style x_server_{{ dp_sid | slugify | replace: "-", "_" }} {{ box_server_style }}
{%- endfor %}
{%- for h in dp_hosts %}
  {%- assign dp_title = h %}
  {%- for c in dp_svc.components %}{% if dp_inside contains c.id and dp_env.components[c.id].hosts[0] == h %}{% assign dp_title = c.name | append: " host · " | append: h %}{% endif %}{% endfor %}
  subgraph x_host_{{ h | slugify | replace: "-", "_" }}["{% include mermaid/label.md text=dp_title %}"]
  {%- for c in dp_svc.components %}
    {%- if dp_inside contains c.id and dp_env.components[c.id].hosts[0] == h %}
    {% include mermaid/node-id.md id=c.id %}["{% include mermaid/label.md text=c.name %}"]:::comp
    {%- endif %}
  {%- endfor %}
  {%- for d in dp_svc.databases %}
    {%- assign dp_loc = dp_env.databases[d.id] %}
    {%- if dp_loc.server == nil and dp_loc.host == h %}
    {% include mermaid/node-id.md id=d.id %}[("{% include mermaid/label.md text=d.name %}<br/>:{{ dp_loc.port }}")]:::db
    {%- endif %}
  {%- endfor %}
  end
  style x_host_{{ h | slugify | replace: "-", "_" }} {{ box_host_style }}
{%- endfor %}
{%- comment -%}
  Edges, box by box. Group = the databases in one server or host box.
{%- endcomment -%}
{%- assign dp_groups = dp_none -%}
{%- for s in dp_env.db_servers %}{% assign dp_groups = dp_groups | push: s[0] %}{% endfor -%}
{%- for h in dp_hosts %}{% assign dp_groups = dp_groups | push: h %}{% endfor -%}
{%- for g in dp_groups %}
  {%- assign dp_gdbs = dp_none %}
  {%- for d in dp_svc.databases %}
    {%- assign dp_loc = dp_env.databases[d.id] %}
    {%- if dp_loc.server == g or dp_loc.server == nil and dp_loc.host == g %}{% assign dp_gdbs = dp_gdbs | push: d.id %}{% endif %}
  {%- endfor %}
  {%- if dp_env.db_servers[g] %}
    {%- assign dp_gid = g | slugify | replace: "-", "_" | prepend: "x_server_" %}
  {%- else %}
    {%- assign dp_gid = g | slugify | replace: "-", "_" | prepend: "x_host_" %}
  {%- endif %}
  {%- for c in dp_svc.components %}
    {%- assign dp_conns = dp_svc.connections | where: "from", c.id | where_exp: "e", "dp_gdbs contains e.to" %}
    {%- if dp_conns.size == 0 %}{% continue %}{% endif %}
    {%- assign dp_targets = dp_conns | map: "to" | uniq %}
    {%- assign dp_owned = dp_svc.databases | where: "owner", c.id | where_exp: "d", "dp_targets contains d.id" %}
    {%- assign dp_here = false %}
    {%- if dp_inside contains c.id and dp_env.components[c.id].hosts[0] == g %}{% assign dp_here = true %}{% endif %}
    {%- if dp_gdbs.size > 1 and dp_targets.size == dp_gdbs.size and dp_here == false and dp_owned.size == dp_targets.size %}
  {% include mermaid/node-id.md id=c.id %} -->|"owner"| {{ dp_gid }}
    {%- elsif dp_gdbs.size > 1 and dp_targets.size == dp_gdbs.size and dp_here == false and dp_owned.size == 0 %}
  {% include mermaid/node-id.md id=c.id %} -.->|"access"| {{ dp_gid }}
    {%- else %}
      {%- for t in dp_targets %}
        {%- assign dp_db = dp_svc.databases | where: "id", t | first %}
        {%- if dp_db.owner == c.id %}
  {% include mermaid/node-id.md id=c.id %} -->|"owner"| {% include mermaid/node-id.md id=t %}
        {%- else %}
  {% include mermaid/node-id.md id=c.id %} -.->|"access"| {% include mermaid/node-id.md id=t %}
        {%- endif %}
      {%- endfor %}
    {%- endif %}
  {%- endfor %}
{%- endfor %}
{% include mermaid/styles.md %}
```
