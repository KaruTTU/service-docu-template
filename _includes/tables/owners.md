{%- comment -%}
  Owners of a service from _data/services.yml.
  Params: service - service slug
{%- endcomment -%}
{%- assign ow_service = site.data.services | where: "slug", include.service | first -%}
| Name | Role | Contact |
|:-----|:-----|:--------|
{% for o in ow_service.owners -%}
| {{ o.name | escape | replace: "|", "&#124;" }} | {{ o.role | escape | replace: "|", "&#124;" }} | {{ o.contact | escape | replace: "|", "&#124;" }} |
{% endfor %}
