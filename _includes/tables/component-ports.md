{%- comment -%}
  Listening ports of one component.
  Params: service - service slug; component - component id
{%- endcomment -%}
{%- assign cpo_c = site.data[include.service].components | where: "id", include.component | first -%}
| Port | Protocol | Purpose |
|-----:|:---------|:--------|
{% for p in cpo_c.ports -%}
| {{ p.port }} | {{ p.protocol | escape | replace: "|", "&#124;" }} | {{ p.purpose | escape | replace: "|", "&#124;" }} |
{% endfor %}
