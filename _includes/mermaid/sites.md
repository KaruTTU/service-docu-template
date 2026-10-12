{%- comment -%}
  Physical layout of one environment: a box per site (env.sites) with the database-cluster nodes
  (db_servers.<id>.nodes) and Kubernetes clusters (env.clusters.<id>.sites) located there.
  Replication edges per database cluster: with exactly one primary/leader node, a dashed edge from
  it to every other node; with several primaries (active-active / multi-primary) or none, one
  two-way "sync" edge between each pair of nodes.
  Nodes without a known site are drawn outside the boxes. Outputs nothing without env.sites.
  Params: service - service slug; env - environment id
{%- endcomment -%}
{%- assign sm_svc = site.data[include.service] -%}
{%- assign sm_env = sm_svc.environments | where: "id", include.env | first -%}
{%- include mermaid/box-styles.md -%}
{%- if sm_env.sites -%}
```mermaid
%%{init: {"flowchart": {"wrappingWidth": 400}}}%%
flowchart LR
{%- for s in sm_env.sites %}
  {%- assign sm_sid = s[0] %}
  {%- assign sm_title = s[1].name | default: sm_sid %}
  subgraph x_site_{{ sm_sid | slugify | replace: "-", "_" }}["{% include mermaid/label.md text=sm_title %}"]
  {%- for srv in sm_env.db_servers %}
    {%- assign sm_srv = srv[0] %}
    {%- for n in srv[1].nodes %}{% if n.site == sm_sid %}
    x_node_{{ n.host | slugify | replace: "-", "_" }}[("{% include mermaid/label.md text=sm_srv %} · {% include mermaid/label.md text=n.role %}<br/>{% include mermaid/label.md text=n.host %}")]:::db
    {%- endif %}{% endfor %}
  {%- endfor %}
  {%- for cl in sm_env.clusters %}{% if cl[1].sites contains sm_sid %}
    {%- assign sm_cl = cl[0] %}{% assign sm_type = cl[1].type | default: "Kubernetes" %}
    x_cl_{{ sm_cl | slugify | replace: "-", "_" }}_{{ sm_sid | slugify | replace: "-", "_" }}["{% include mermaid/label.md text=sm_cl %}<br/>{% include mermaid/label.md text=sm_type %} nodes"]:::comp
  {%- endif %}{% endfor %}
  end
  style x_site_{{ sm_sid | slugify | replace: "-", "_" }} {{ box_site_style }}
{%- endfor %}
{%- for srv in sm_env.db_servers %}
  {%- assign sm_srv = srv[0] %}
  {%- for n in srv[1].nodes %}{% unless sm_env.sites[n.site] %}
  x_node_{{ n.host | slugify | replace: "-", "_" }}[("{% include mermaid/label.md text=sm_srv %} · {% include mermaid/label.md text=n.role %}<br/>{% include mermaid/label.md text=n.host %}")]:::db
  {%- endunless %}{% endfor %}
  {%- assign sm_primary_count = 0 %}
  {%- for n in srv[1].nodes %}{% if n.role == "primary" or n.role == "leader" %}
    {%- assign sm_primary_count = sm_primary_count | plus: 1 %}{% assign sm_primary = n %}
  {%- endif %}{% endfor %}
  {%- if sm_primary_count == 1 %}
    {%- for n in srv[1].nodes %}{% unless n.host == sm_primary.host %}
  x_node_{{ sm_primary.host | slugify | replace: "-", "_" }} -.->|"replication"| x_node_{{ n.host | slugify | replace: "-", "_" }}
    {%- endunless %}{% endfor %}
  {%- else %}
    {%- for p in srv[1].nodes %}
      {%- assign sm_i = forloop.index %}
      {%- for n in srv[1].nodes %}{% if forloop.index > sm_i %}
  x_node_{{ p.host | slugify | replace: "-", "_" }} <-.->|"sync"| x_node_{{ n.host | slugify | replace: "-", "_" }}
      {%- endif %}{% endfor %}
    {%- endfor %}
  {%- endif %}
{%- endfor %}
{% include mermaid/styles.md %}
```
{%- endif -%}
