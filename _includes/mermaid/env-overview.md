{%- comment -%}
  Everything in one environment in one diagram: clients -> proxies -> components -> databases
  and external dependencies, with every connection from proxy.yml and connections.yml.
  Params: service - service slug; env - environment id
  Databases are boxed as in mermaid/db-placement.md: one box per shared database server, and a
  "<component> host" box (containing that component) for databases on a component's only host.
  Database edges are solid from the owner and dashed from other components; a component that
  reaches every database in a server box with the same protocol:port gets one edge to the box.
  Components deployed to a Kubernetes cluster show the cluster and namespace in their label; no
  box is drawn for the cluster, because edges into a box make Mermaid stack their labels.
  Routes from one proxy to one component share an edge (parallel edges made Mermaid crowd
  their labels and push them into the component box), labelled by mermaid/route-label.md
  with one line per route; route lines don't wrap, so they can't spill over a neighbour.
  Connections with the same from and to share one edge ("grpc:9000, http:9001"), and a pair
  connected both ways with the same label gets one two-headed edge.
  Box titles are short (server id, "<component> host"); full hosts are in the tables below.
  Labels wrap at 400px so hostnames stay on one line; click the diagram to see it full size.
{%- endcomment -%}
{%- assign ov_svc = site.data[include.service] -%}
{%- assign ov_env = ov_svc.environments | where: "id", include.env | first -%}
{%- assign ov_proxies = ov_svc.proxy[include.env] -%}
{%- assign ov_clients = ov_proxies | map: "clients" | uniq -%}
{%- assign ov_none = "" | split: "" -%}
{%- assign ov_db_ids = ov_svc.databases | map: "id" -%}
{%- include mermaid/box-styles.md -%}

{%- comment -%} Hosts of databases that are not on a shared server; components boxed with them. {%- endcomment -%}
{%- assign ov_hosts = ov_none -%}
{%- for d in ov_svc.databases -%}
  {%- assign ov_loc = ov_env.databases[d.id] -%}
  {%- unless ov_loc.server -%}{%- assign ov_hosts = ov_hosts | push: ov_loc.host -%}{%- endunless -%}
{%- endfor -%}
{%- assign ov_hosts = ov_hosts | uniq -%}
{%- assign ov_inside = ov_none -%}
{%- for c in ov_svc.components -%}
  {%- assign ov_ch = ov_env.components[c.id].hosts -%}
  {%- if ov_ch.size == 1 and ov_hosts contains ov_ch[0] -%}{%- assign ov_inside = ov_inside | push: c.id -%}{%- endif -%}
{%- endfor -%}
```mermaid
%%{init: {"flowchart": {"wrappingWidth": 400}}}%%
flowchart LR
{%- comment -%} Clients and proxies {%- endcomment -%}
{%- for cl in ov_clients %}
  x_src_{{ cl | slugify | replace: "-", "_" }}(("{% include mermaid/label.md text=cl %}")):::net
{%- endfor %}
{%- for px in ov_proxies %}
  {%- capture ov_listen -%}{%- for l in px.listen -%}{{ l.protocol }}:{{ l.port }}{% unless forloop.last %}, {% endunless %}{%- endfor -%}{%- endcapture %}
  x_proxy_{{ px.id | slugify | replace: "-", "_" }}["{% include mermaid/label.md text=px.name %}<br/>{% include mermaid/label.md text=px.host %}"]:::net
  x_src_{{ px.clients | slugify | replace: "-", "_" }} -->|"{% include mermaid/label.md text=ov_listen %}"| x_proxy_{{ px.id | slugify | replace: "-", "_" }}
{%- endfor %}
{%- comment -%} Components not drawn inside a host box {%- endcomment -%}
{%- for c in ov_svc.components %}
  {%- unless ov_inside contains c.id %}
  {%- assign ov_cc = ov_env.components[c.id] %}
  {%- capture ov_ns %}{{ ov_cc.cluster }} · ns {{ ov_cc.namespace }}{% endcapture %}
  {% include mermaid/node-id.md id=c.id %}["{% include mermaid/label.md text=c.name %}
    {%- if ov_cc.cluster %}<br/>{% include mermaid/label.md text=ov_ns %}{% endif -%}
    {%- for h in ov_cc.hosts -%}<br/>{% include mermaid/label.md text=h %}{%- endfor -%}
  "]:::comp
  {%- endunless %}
{%- endfor %}
{%- comment -%} External dependencies {%- endcomment -%}
{%- for x in ov_svc.external %}
  {% include mermaid/node-id.md id=x.id %}(["{% include mermaid/label.md text=x.name %}<br/>{% include mermaid/label.md text=x.url %}"]):::ext
{%- endfor %}
{%- comment -%} Database servers {%- endcomment -%}
{%- for s in ov_env.db_servers %}
  {%- assign ov_sid = s[0] %}{% assign ov_server = s[1] %}
  subgraph x_server_{{ ov_sid | slugify | replace: "-", "_" }}["{% include mermaid/label.md text=ov_sid %}"]
  {%- for d in ov_svc.databases %}
    {%- assign ov_loc = ov_env.databases[d.id] %}
    {%- if ov_loc.server == ov_sid %}
    {% include mermaid/node-id.md id=d.id %}[("{% include mermaid/label.md text=d.name %}")]:::db
    {%- endif %}
  {%- endfor %}
  end
  style x_server_{{ ov_sid | slugify | replace: "-", "_" }} {{ box_server_style }}
{%- endfor %}
{%- comment -%} Hosts with their own databases (and the component that runs there) {%- endcomment -%}
{%- for h in ov_hosts %}
  {%- assign ov_title = h %}
  {%- for c in ov_svc.components %}{% if ov_inside contains c.id and ov_env.components[c.id].hosts[0] == h %}{% assign ov_title = c.name | append: " host" %}{% endif %}{% endfor %}
  subgraph x_host_{{ h | slugify | replace: "-", "_" }}["{% include mermaid/label.md text=ov_title %}"]
  {%- for c in ov_svc.components %}
    {%- if ov_inside contains c.id and ov_env.components[c.id].hosts[0] == h %}
    {% include mermaid/node-id.md id=c.id %}["{% include mermaid/label.md text=c.name %}"]:::comp
    {%- endif %}
  {%- endfor %}
  {%- for d in ov_svc.databases %}
    {%- assign ov_loc = ov_env.databases[d.id] %}
    {%- if ov_loc.server == nil and ov_loc.host == h %}
    {% include mermaid/node-id.md id=d.id %}[("{% include mermaid/label.md text=d.name %}<br/>:{{ ov_loc.port }}")]:::db
    {%- endif %}
  {%- endfor %}
  end
  style x_host_{{ h | slugify | replace: "-", "_" }} {{ box_host_style }}
{%- endfor %}
{%- comment -%} Proxy routes: one edge per proxy and component {%- endcomment -%}
{%- for px in ov_proxies %}
  {%- assign ov_targets = px.routes | map: "component" | uniq %}
  {%- for t in ov_targets %}
    {%- assign ov_routes = px.routes | where: "component", t %}
  x_proxy_{{ px.id | slugify | replace: "-", "_" }} -->|"{% include mermaid/route-label.md routes=ov_routes %}"| {% include mermaid/node-id.md id=t %}
  {%- endfor %}
{%- endfor %}
{%- comment -%}
  Connections to components and external dependencies: one edge per from/to pair; a pair
  connected both ways with the same label is drawn once, as a two-headed edge.
{%- endcomment -%}
{%- capture ov_pair_keys %}{% for e in ov_svc.connections %}{% unless ov_db_ids contains e.to %}{{ e.from }}>{{ e.to }}§{% endunless %}{% endfor %}{% endcapture %}
{%- assign ov_pair_keys = ov_pair_keys | split: "§" | uniq %}
{%- for k in ov_pair_keys %}
  {%- assign ov_from = k | split: ">" | first %}{% assign ov_to = k | split: ">" | last %}
  {%- assign ov_es = ov_svc.connections | where: "from", ov_from | where: "to", ov_to %}
  {%- assign ov_back = ov_svc.connections | where: "from", ov_to | where: "to", ov_from %}
  {%- capture ov_label %}{% for e in ov_es %}{{ e.protocol }}:{{ e.port }}{% unless forloop.last %}, {% endunless %}{% endfor %}{% endcapture %}
  {%- capture ov_back_label %}{% for e in ov_back %}{{ e.protocol }}:{{ e.port }}{% unless forloop.last %}, {% endunless %}{% endfor %}{% endcapture %}
  {%- assign ov_arrow = "-->" %}
  {%- if ov_back_label == ov_label %}
    {%- if ov_from > ov_to %}{% continue %}{% endif %}
    {%- assign ov_arrow = "<-->" %}
  {%- endif %}
  {% include mermaid/node-id.md id=ov_from %} {{ ov_arrow }}|"{% include mermaid/label.md text=ov_label %}"| {% include mermaid/node-id.md id=ov_to %}
{%- endfor %}
{%- comment -%} Connections to databases: per component and server, collapsed when uniform {%- endcomment -%}
{%- for c in ov_svc.components %}
  {%- assign ov_dbconns = ov_svc.connections | where: "from", c.id | where_exp: "e", "ov_db_ids contains e.to" %}
  {%- assign ov_done = ov_none %}
  {%- for s in ov_env.db_servers %}
    {%- assign ov_sid = s[0] %}
    {%- assign ov_sdbs = ov_none %}
    {%- for d in ov_svc.databases %}{% if ov_env.databases[d.id].server == ov_sid %}{% assign ov_sdbs = ov_sdbs | push: d.id %}{% endif %}{% endfor %}
    {%- assign ov_es = ov_dbconns | where_exp: "e", "ov_sdbs contains e.to" %}
    {%- capture ov_labels %}{% for e in ov_es %}{{ e.protocol }}:{{ e.port }}§{% endfor %}{% endcapture %}
    {%- assign ov_labels = ov_labels | split: "§" | uniq %}
    {%- assign ov_owned = ov_svc.databases | where: "owner", c.id | where_exp: "d", "ov_sdbs contains d.id" %}
    {%- if ov_sdbs.size > 1 and ov_es.size == ov_sdbs.size and ov_labels.size == 1 %}
      {%- assign ov_label = ov_labels | first %}
      {%- if ov_owned.size == ov_sdbs.size %}
  {% include mermaid/node-id.md id=c.id %} -->|"{% include mermaid/label.md text=ov_label %}"| x_server_{{ ov_sid | slugify | replace: "-", "_" }}
      {%- else %}
  {% include mermaid/node-id.md id=c.id %} -.->|"{% include mermaid/label.md text=ov_label %}"| x_server_{{ ov_sid | slugify | replace: "-", "_" }}
      {%- endif %}
      {%- assign ov_done = ov_done | concat: ov_sdbs %}
    {%- endif %}
  {%- endfor %}
  {%- for e in ov_dbconns %}
    {%- unless ov_done contains e.to %}
      {%- assign ov_db = ov_svc.databases | where: "id", e.to | first %}
      {%- capture ov_label %}{{ e.protocol }}:{{ e.port }}{% endcapture %}
      {%- if ov_db.owner == c.id %}
  {% include mermaid/node-id.md id=c.id %} -->|"{% include mermaid/label.md text=ov_label %}"| {% include mermaid/node-id.md id=e.to %}
      {%- else %}
  {% include mermaid/node-id.md id=c.id %} -.->|"{% include mermaid/label.md text=ov_label %}"| {% include mermaid/node-id.md id=e.to %}
      {%- endif %}
    {%- endunless %}
  {%- endfor %}
{%- endfor %}
{% include mermaid/styles.md %}
```
