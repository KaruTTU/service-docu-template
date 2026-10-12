{%- comment -%}
  Connections table from connections.yml.
  Params: service - service slug; from / to - optional component id filters
{%- endcomment -%}
{%- assign cn_rows = site.data[include.service].connections -%}
{%- if include.from -%}{%- assign cn_rows = cn_rows | where: "from", include.from -%}{%- endif -%}
{%- if include.to -%}{%- assign cn_rows = cn_rows | where: "to", include.to -%}{%- endif -%}
{%- if cn_rows.size == 0 -%}
_None._
{%- else %}
| From | To | Protocol | Port | Description |
|:-----|:---|:---------|-----:|:------------|
{% for e in cn_rows -%}
| {% include entity-name.md service=include.service id=e.from %} | {% include entity-name.md service=include.service id=e.to %} | {{ e.protocol | escape | replace: "|", "&#124;" }} | {{ e.port }} | {{ e.description | escape | replace: "|", "&#124;" }} |
{% endfor %}
{%- endif %}
