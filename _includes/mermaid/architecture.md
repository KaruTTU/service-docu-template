{%- comment -%}
  Architecture / communication diagram for a service.
  Params: service - service slug (key under _data/)
  Nodes: components, databases, external dependencies (coloured by type, no grouping boxes, so
  the layout can place each database next to the components that use it).
  Edges: connections.yml, labeled protocol:port.
{%- endcomment -%}
{%- assign arch_svc = site.data[include.service] -%}
```mermaid
flowchart TB
{%- for c in arch_svc.components %}
  {% include mermaid/node-id.md id=c.id %}["{% include mermaid/label.md text=c.name %}"]:::comp
{%- endfor %}
{%- for d in arch_svc.databases %}
  {% include mermaid/node-id.md id=d.id %}[("{% include mermaid/label.md text=d.id %}<br/>{% include mermaid/label.md text=d.engine %}")]:::db
{%- endfor %}
{%- for x in arch_svc.external %}
  {% include mermaid/node-id.md id=x.id %}(["{% include mermaid/label.md text=x.name %}"]):::ext
{%- endfor %}
{%- for e in arch_svc.connections %}
  {%- capture arch_label %}{{ e.protocol }}:{{ e.port }}{% endcapture %}
  {% include mermaid/node-id.md id=e.from %} -->|"{% include mermaid/label.md text=arch_label %}"| {% include mermaid/node-id.md id=e.to %}
{%- endfor %}
{% include mermaid/styles.md %}
```
