{%- comment -%}
  Neighbourhood diagram for one component: what calls it (left) and what it calls (right).
  Params: service - service slug; component - component id
  Inbound: proxies routing to it (from proxy.yml, all environments; deduplicated) and
  connections.yml entries with `to` = component. Outbound: entries with `from` = component.
  Databases are grouped into boxes as in mermaid/db-placement.md, using the first environment:
  a box per shared database server, and a "<component> host" box for databases on a
  component's host (this component is drawn inside it when it is its own host). When every
  database in a server box is reached with the same protocol:port, one edge goes to the box.
{%- endcomment -%}
{%- assign cd_svc = site.data[include.service] -%}
{%- assign cd_env = cd_svc.environments | first -%}
{%- assign cd_none = "" | split: "" -%}
{%- assign cd_db_ids = cd_svc.databases | map: "id" -%}
{%- assign cd_c = cd_svc.components | where: "id", include.component | first -%}
{%- assign cd_in = cd_svc.connections | where: "to", include.component -%}
{%- assign cd_out = cd_svc.connections | where: "from", include.component -%}
{%- assign cd_out_db = cd_out | where_exp: "e", "cd_db_ids contains e.to" -%}
{%- assign cd_out_other = cd_none -%}
{%- for e in cd_out -%}{%- unless cd_db_ids contains e.to -%}{%- assign cd_out_other = cd_out_other | push: e -%}{%- endunless -%}{%- endfor -%}
{%- assign cd_my_hosts = cd_env.components[include.component].hosts -%}
{%- capture cd_self %}{% include mermaid/node-id.md id=include.component %}{% endcapture -%}
{%- capture cd_self_node %}{{ cd_self }}["{% include mermaid/label.md text=cd_c.name %}"]:::focus{% endcapture -%}
{%- include mermaid/box-styles.md -%}

{%- comment -%} Where each outbound database runs: servers, component hosts, or loose. {%- endcomment -%}
{%- assign cd_servers = cd_none -%}{%- assign cd_hosts = cd_none -%}{%- assign cd_loose = cd_none -%}
{%- for e in cd_out_db -%}
  {%- assign cd_loc = cd_env.databases[e.to] -%}
  {%- if cd_loc.server -%}{%- assign cd_servers = cd_servers | push: cd_loc.server -%}
  {%- else -%}
    {%- assign cd_co = nil -%}
    {%- for c in cd_svc.components -%}{%- if cd_env.components[c.id].hosts contains cd_loc.host -%}{%- assign cd_co = c -%}{%- endif -%}{%- endfor -%}
    {%- if cd_co -%}{%- assign cd_hosts = cd_hosts | push: cd_loc.host -%}{%- else -%}{%- assign cd_loose = cd_loose | push: e.to -%}{%- endif -%}
  {%- endif -%}
{%- endfor -%}
{%- assign cd_servers = cd_servers | uniq -%}{%- assign cd_hosts = cd_hosts | uniq -%}
{%- assign cd_self_boxed = false -%}
{%- for h in cd_hosts -%}{%- if cd_my_hosts.size == 1 and cd_my_hosts[0] == h -%}{%- assign cd_self_boxed = true -%}{%- endif -%}{%- endfor -%}

{%- capture cd_proxy_lines -%}
  {%- for env in cd_svc.environments -%}
    {%- for px in cd_svc.proxy[env.id] -%}
      {%- assign cd_routes = px.routes | where: "component", include.component -%}
      {%- for r in cd_routes -%}
        {%- assign cd_pid = px.id | slugify | replace: "-", "_" -%}
        x_proxy_{{ cd_pid }}["{% include mermaid/label.md text=px.name %}"]:::net§x_proxy_{{ cd_pid }} -->|":{{ r.port }}"| {{ cd_self }}§
      {%- endfor -%}
    {%- endfor -%}
  {%- endfor -%}
{%- endcapture -%}
{%- assign cd_proxy_lines = cd_proxy_lines | split: "§" | uniq -%}
```mermaid
flowchart LR
{%- unless cd_self_boxed %}
  {{ cd_self_node }}
{%- endunless %}
{%- for l in cd_proxy_lines %}
  {{ l }}
{%- endfor %}
{%- for e in cd_in %}
  {% include mermaid/node.md service=include.service id=e.from %}
  {%- capture cd_label %}{{ e.protocol }}:{{ e.port }}{% endcapture %}
  {% include mermaid/node-id.md id=e.from %} -->|"{% include mermaid/label.md text=cd_label %}"| {{ cd_self }}
{%- endfor %}
{%- for e in cd_out_other %}
  {% include mermaid/node.md service=include.service id=e.to %}
  {%- capture cd_label %}{{ e.protocol }}:{{ e.port }}{% endcapture %}
  {{ cd_self }} -->|"{% include mermaid/label.md text=cd_label %}"| {% include mermaid/node-id.md id=e.to %}
{%- endfor %}
{%- for sid in cd_servers %}
  {%- assign cd_gid = sid | slugify | replace: "-", "_" | prepend: "x_server_" %}
  {%- assign cd_es = cd_out_db | where_exp: "e", "cd_env.databases[e.to].server == sid" %}
  subgraph {{ cd_gid }}["{% include mermaid/label.md text=sid %}"]
  {%- for e in cd_es %}
    {%- assign d = cd_svc.databases | where: "id", e.to | first %}
    {% include mermaid/node-id.md id=d.id %}[("{% include mermaid/label.md text=d.name %}{% if d.engine != d.name %}<br/>{% include mermaid/label.md text=d.engine %}{% endif %}")]:::db
  {%- endfor %}
  end
  style {{ cd_gid }} {{ box_server_style }}
  {%- capture cd_labels %}{% for e in cd_es %}{{ e.protocol }}:{{ e.port }}§{% endfor %}{% endcapture %}
  {%- assign cd_labels = cd_labels | split: "§" | uniq %}
  {%- assign cd_label = cd_labels | first %}
  {%- if cd_es.size > 1 and cd_labels.size == 1 %}
  {{ cd_self }} -->|"{% include mermaid/label.md text=cd_label %}"| {{ cd_gid }}
  {%- else %}
    {%- for e in cd_es %}
      {%- capture cd_label %}{{ e.protocol }}:{{ e.port }}{% endcapture %}
  {{ cd_self }} -->|"{% include mermaid/label.md text=cd_label %}"| {% include mermaid/node-id.md id=e.to %}
    {%- endfor %}
  {%- endif %}
{%- endfor %}
{%- for h in cd_hosts %}
  {%- assign cd_gid = h | slugify | replace: "-", "_" | prepend: "x_host_" %}
  {%- assign cd_co = nil %}
  {%- for c in cd_svc.components %}{% if cd_env.components[c.id].hosts contains h %}{% assign cd_co = c %}{% endif %}{% endfor %}
  {%- capture cd_title %}{{ cd_co.name }} host{% endcapture %}
  subgraph {{ cd_gid }}["{% include mermaid/label.md text=cd_title %}"]
  {%- if cd_self_boxed and cd_my_hosts[0] == h %}
    {{ cd_self_node }}
  {%- endif %}
  {%- for e in cd_out_db %}
    {%- assign cd_loc = cd_env.databases[e.to] %}
    {%- if cd_loc.server == nil and cd_loc.host == h %}
    {%- assign d = cd_svc.databases | where: "id", e.to | first %}
    {% include mermaid/node-id.md id=d.id %}[("{% include mermaid/label.md text=d.name %}{% if d.engine != d.name %}<br/>{% include mermaid/label.md text=d.engine %}{% endif %}")]:::db
    {%- endif %}
  {%- endfor %}
  end
  style {{ cd_gid }} {{ box_host_style }}
  {%- for e in cd_out_db %}
    {%- assign cd_loc = cd_env.databases[e.to] %}
    {%- if cd_loc.server == nil and cd_loc.host == h %}
      {%- capture cd_label %}{{ e.protocol }}:{{ e.port }}{% endcapture %}
  {{ cd_self }} -->|"{% include mermaid/label.md text=cd_label %}"| {% include mermaid/node-id.md id=e.to %}
    {%- endif %}
  {%- endfor %}
{%- endfor %}
{%- for t in cd_loose %}
  {% include mermaid/node.md service=include.service id=t %}
  {%- assign e = cd_out_db | where: "to", t | first %}
  {%- capture cd_label %}{{ e.protocol }}:{{ e.port }}{% endcapture %}
  {{ cd_self }} -->|"{% include mermaid/label.md text=cd_label %}"| {% include mermaid/node-id.md id=t %}
{%- endfor %}
{% include mermaid/styles.md %}
```
