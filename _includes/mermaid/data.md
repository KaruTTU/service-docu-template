{%- comment -%}
  Data diagram: which component uses which database.
  Params: service - service slug
  Solid edge = owner (databases.yml `owner`), dashed edge = access by a non-owning component.
  Edges come from connections.yml entries whose `to` is a database.
{%- endcomment -%}
{%- assign data_svc = site.data[include.service] -%}
```mermaid
flowchart LR
{%- for c in data_svc.components %}
  {% include mermaid/node-id.md id=c.id %}["{% include mermaid/label.md text=c.name %}"]:::comp
{%- endfor %}
{%- for d in data_svc.databases %}
  {% include mermaid/node-id.md id=d.id %}[("{% include mermaid/label.md text=d.name %}{% if d.engine != d.name %}<br/>{% include mermaid/label.md text=d.engine %}{% endif %}")]:::db
{%- endfor %}
{%- for e in data_svc.connections %}
  {%- assign data_db = data_svc.databases | where: "id", e.to | first %}
  {%- if data_db %}
    {%- if data_db.owner == e.from %}
  {% include mermaid/node-id.md id=e.from %} -->|"owner"| {% include mermaid/node-id.md id=e.to %}
    {%- else %}
  {% include mermaid/node-id.md id=e.from %} -.->|"access"| {% include mermaid/node-id.md id=e.to %}
    {%- endif %}
  {%- endif %}
{%- endfor %}
{% include mermaid/styles.md %}
```
