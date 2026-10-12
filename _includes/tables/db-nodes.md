{%- comment -%}
  Nodes of one database server or cluster (db_servers.<id>.nodes), with site and role.
  Outputs nothing when the server lists no nodes.
  Params: env - environment object (from environments.yml); server - db_servers id
{%- endcomment -%}
{%- assign dn_server = include.env.db_servers[include.server] -%}
{%- if dn_server.nodes %}
| Node | Site | Role |
|:-----|:-----|:-----|
{% for n in dn_server.nodes -%}
{%- assign dn_site = include.env.sites[n.site] -%}
| `{{ n.host }}` | {{ dn_site.name | default: n.site | escape | replace: "|", "&#124;" }} | {{ n.role | escape | replace: "|", "&#124;" }} |
{% endfor %}
{%- endif -%}
