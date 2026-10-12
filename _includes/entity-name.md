{%- comment -%}
  Display name for a component, database or external dependency id.
  Params: service - service slug; id - entity id
  Components link to their page; databases show their name; externals get an "(external)" suffix.
{%- endcomment -%}
{%- assign en_svc = site.data[include.service] -%}
{%- assign en_c = en_svc.components | where: "id", include.id | first -%}
{%- assign en_x = en_svc.external | where: "id", include.id | first -%}
{%- assign en_d = en_svc.databases | where: "id", include.id | first -%}
{%- if en_c -%}
  {%- assign en_page = site.pages | where: "service", include.service | where: "component", include.id | first -%}
  {%- if en_page -%}[{{ en_c.name | escape | replace: "|", "&#124;" }}]({{ en_page.url | relative_url }}){%- else -%}{{ en_c.name | escape | replace: "|", "&#124;" }}{%- endif -%}
{%- elsif en_x -%}
  {{ en_x.name | escape | replace: "|", "&#124;" }} (external)
{%- elsif en_d -%}
  {{ en_d.name | default: en_d.id | escape | replace: "|", "&#124;" }}
{%- else -%}
  `{{ include.id }}`
{%- endif -%}
