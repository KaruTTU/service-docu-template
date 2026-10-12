{%- comment -%}
  External dependencies table. "Used by" and protocol/port are derived from connections.yml.
  Params: service - service slug; component - optional, only externals this component connects to
{%- endcomment -%}
{%- assign ex_svc = site.data[include.service] -%}
{%- assign ex_count = 0 -%}
{%- capture ex_rows -%}
{%- for x in ex_svc.external -%}
  {%- assign ex_conns = ex_svc.connections | where: "to", x.id -%}
  {%- if include.component -%}{%- assign ex_conns = ex_conns | where: "from", include.component -%}{%- endif -%}
  {%- if ex_conns.size > 0 -%}
    {%- assign ex_count = ex_count | plus: 1 -%}
    {%- assign ex_users = ex_conns | map: "from" | uniq %}
| {{ x.name | escape | replace: "|", "&#124;" }} | `{{ x.url }}` | {% for e in ex_conns %}{{ e.protocol | escape | replace: "|", "&#124;" }}:{{ e.port }}{% unless forloop.last %}, {% endunless %}{% endfor %} | {% for u in ex_users %}{% include entity-name.md service=include.service id=u %}{% unless forloop.last %}, {% endunless %}{% endfor %} | {{ x.vendor | escape | replace: "|", "&#124;" }} | {{ x.notes | escape | replace: "|", "&#124;" }} |
  {%- endif -%}
{%- endfor -%}
{%- endcapture -%}
{%- if ex_count == 0 -%}
_None._
{%- else %}
| Name | URL / host | Protocol:port | Used by | Vendor / owner | Notes |
|:-----|:-----------|:--------------|:--------|:---------------|:------|
{{- ex_rows }}
{% endif %}
