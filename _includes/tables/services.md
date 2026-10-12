{%- comment -%}
  Table of all services from _data/services.yml.
{%- endcomment -%}
| Service | Summary | Owners |
|:--------|:--------|:-------|
{% for s in site.data.services -%}
| [{{ s.title | escape | replace: "|", "&#124;" }}]({{ "/docs/" | append: s.slug | append: "/" | relative_url }}) | {{ s.summary | escape | replace: "|", "&#124;" }} | {{ s.owners | map: "name" | join: ", " | escape | replace: "|", "&#124;" }} |
{% endfor %}
