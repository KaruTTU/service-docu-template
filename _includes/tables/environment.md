{%- comment -%}
  Components of one environment: where each runs (hosts or Kubernetes cluster) and the
  databases each one owns.
  Ports are on the component pages, database locations in tables/db-locations.md.
  Params: service - service slug; env - environment id
{%- endcomment -%}
{%- assign ev_svc = site.data[include.service] -%}
{%- assign ev_env = ev_svc.environments | where: "id", include.env | first -%}
| Component | Runs on | Owns databases |
|:----------|:------|:---------------|
{% for c in ev_svc.components -%}
{%- assign ev_dbs = ev_svc.databases | where: "owner", c.id -%}
| {% include entity-name.md service=include.service id=c.id %} | {% include runs-on.md env=ev_env component=c.id sep="<br>" %} | {% for d in ev_dbs %}{{ d.name | default: d.id | escape | replace: "|", "&#124;" }}{% unless forloop.last %}, {% endunless %}{% endfor %} |
{% endfor %}
