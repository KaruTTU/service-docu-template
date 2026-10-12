{%- comment -%}
  Full Mermaid node definition (id, shape, label, class) for a component, database or external id.
  Params: service - service slug; id - entity id
{%- endcomment -%}
{%- assign nd_svc = site.data[include.service] -%}
{%- assign nd_c = nd_svc.components | where: "id", include.id | first -%}
{%- assign nd_d = nd_svc.databases | where: "id", include.id | first -%}
{%- assign nd_x = nd_svc.external | where: "id", include.id | first -%}
{%- if nd_c -%}
  {% include mermaid/node-id.md id=include.id %}["{% include mermaid/label.md text=nd_c.name %}"]:::comp
{%- elsif nd_d -%}
  {% include mermaid/node-id.md id=include.id %}[("{% include mermaid/label.md text=nd_d.name %}{% if nd_d.engine != nd_d.name %}<br/>{% include mermaid/label.md text=nd_d.engine %}{% endif %}")]:::db
{%- elsif nd_x -%}
  {% include mermaid/node-id.md id=include.id %}(["{% include mermaid/label.md text=nd_x.name %}"]):::ext
{%- else -%}
  {% include mermaid/node-id.md id=include.id %}["{% include mermaid/label.md text=include.id %}"]
{%- endif -%}
