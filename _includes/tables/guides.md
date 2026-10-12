{%- comment -%}
  Guides of one service: every page under docs/<service>/guides/ with `parent: Guides`,
  in nav_order, with the `description` from its front matter.
  Params: service - service slug
{%- endcomment -%}
{%- assign gd_pages = site.pages | where: "service", include.service | where: "parent", "Guides" | sort: "nav_order", "last" -%}
{%- if gd_pages.size == 0 %}
_No guides yet._
{%- else %}
| Guide | What it's for |
|:------|:--------------|
{% for g in gd_pages -%}
| [{{ g.title | escape | replace: "|", "&#124;" }}]({{ g.url | relative_url }}) | {{ g.description | escape | replace: "|", "&#124;" }} |
{% endfor %}
{%- endif %}
