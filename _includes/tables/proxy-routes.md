{%- comment -%}
  Reverse proxies and their routes for one environment.
  Params: service - service slug; env - environment id
          component - optional; show only routes to this component (and no proxy summary)
{%- endcomment -%}
{%- assign pr_svc = site.data[include.service] -%}
{%- assign pr_proxies = pr_svc.proxy[include.env] -%}
{%- assign pr_env = pr_svc.environments | where: "id", include.env | first -%}
{%- assign pr_count = 0 -%}
{%- capture pr_rows -%}
{%- for px in pr_proxies -%}
  {%- assign pr_routes = px.routes -%}
  {%- if include.component -%}{%- assign pr_routes = pr_routes | where: "component", include.component -%}{%- endif -%}
  {%- for r in pr_routes -%}
    {%- assign pr_count = pr_count | plus: 1 %}
| {{ px.name | escape | replace: "|", "&#124;" }} | `{{ r.public_host }}` | `{{ r.path }}` | {% include entity-name.md service=include.service id=r.component %} :{{ r.port }} | {% include runs-on.md env=pr_env component=r.component sep="<br>" %} | {{ r.tls | escape | replace: "|", "&#124;" }} | {{ r.notes | escape | replace: "|", "&#124;" }} |
  {%- endfor -%}
{%- endfor -%}
{%- endcapture -%}
{%- unless include.component %}
| Proxy | Clients | Type | Host | Listens on |
|:------|:--------|:-----|:-----|:-----------|
{% for px in pr_proxies -%}
| {{ px.name | escape | replace: "|", "&#124;" }} | {{ px.clients | escape | replace: "|", "&#124;" }} | {{ px.type | escape | replace: "|", "&#124;" }} | `{{ px.host }}` | {% for l in px.listen %}{{ l.protocol | escape }}:{{ l.port }}{% unless forloop.last %}, {% endunless %}{% endfor %} |
{% endfor %}
{% endunless -%}
{%- if pr_count == 0 %}
_No proxy routes._
{%- else %}
| Proxy | Public host | Path | Backend | Backend runs on | TLS | Notes |
|:------|:------------|:-----|:--------|:--------------|:----|:------|
{{- pr_rows }}
{% endif %}
