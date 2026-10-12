{%- comment -%}
  Sites (data centres) and Kubernetes clusters of one environment. Each part is left out when
  the environment doesn't declare it.
  Params: service - service slug; env - environment id
{%- endcomment -%}
{%- assign st_svc = site.data[include.service] -%}
{%- assign st_env = st_svc.environments | where: "id", include.env | first -%}
{%- if st_env.sites %}
| Site | What runs there | Notes |
|:-----|:----------------|:------|
{% for s in st_env.sites -%}
{%- assign st_sid = s[0] -%}
| {{ s[1].name | default: st_sid | escape | replace: "|", "&#124;" }} | {% assign st_first = true %}{% for srv in st_env.db_servers %}{% for n in srv[1].nodes %}{% if n.site == st_sid %}{% unless st_first %}<br>{% endunless %}`{{ srv[0] }}` {{ n.role | escape | replace: "|", "&#124;" }} · `{{ n.host }}`{% assign st_first = false %}{% endif %}{% endfor %}{% endfor %}{% for cl in st_env.clusters %}{% if cl[1].sites contains st_sid %}{% unless st_first %}<br>{% endunless %}`{{ cl[0] }}` {{ cl[1].type | default: "Kubernetes" | escape }} nodes{% assign st_first = false %}{% endif %}{% endfor %} | {{ s[1].notes | escape | replace: "|", "&#124;" }} |
{% endfor %}
{%- endif %}
{%- if st_env.clusters %}

| Cluster | Type | API | Sites | Components (namespace) | Notes |
|:--------|:-----|:----|:------|:-----------------------|:------|
{% for cl in st_env.clusters -%}
{%- assign st_cid = cl[0] -%}
| `{{ st_cid }}` | {{ cl[1].type | default: "Kubernetes" | escape }} | {% if cl[1].api %}`{{ cl[1].api }}`{% endif %} | {% for s in cl[1].sites %}{{ st_env.sites[s].name | default: s | escape }}{% unless forloop.last %}, {% endunless %}{% endfor %} | {% assign st_first = true %}{% for c in st_svc.components %}{% assign st_c = st_env.components[c.id] %}{% if st_c.cluster == st_cid %}{% unless st_first %}<br>{% endunless %}{% include entity-name.md service=include.service id=c.id %} (`{{ st_c.namespace }}`){% assign st_first = false %}{% endif %}{% endfor %} | {{ cl[1].notes | escape | replace: "|", "&#124;" }} |
{% endfor %}
{%- endif -%}
