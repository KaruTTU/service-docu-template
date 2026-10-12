{%- comment -%}
  Overview table of a service's components.
  Params: service - service slug
{%- endcomment -%}
{%- assign cp_svc = site.data[include.service] -%}
| Component | Description | Team | Repositories | Listens on |
|:----------|:------------|:-----|:-------------|:-----------|
{% for c in cp_svc.components -%}
| {% include entity-name.md service=include.service id=c.id %} | {{ c.description | escape | replace: "|", "&#124;" }} | {{ c.team | escape | replace: "|", "&#124;" }} | {% if c.code_repo %}[code]({{ c.code_repo }}){% endif %}{% if c.code_repo and c.deploy_repo %} · {% endif %}{% if c.deploy_repo %}[deployment]({{ c.deploy_repo }}){% endif %} | {% for p in c.ports %}{{ p.protocol | escape | replace: "|", "&#124;" }}:{{ p.port }}{% unless forloop.last %}, {% endunless %}{% endfor %} |
{% endfor %}
