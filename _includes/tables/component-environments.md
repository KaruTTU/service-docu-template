{%- comment -%}
  One component per environment: where it runs (hosts or Kubernetes cluster), and every database it connects to with where
  that database runs (server box or host, as in mermaid/db-placement.md).
  Params: service - service slug; component - component id
{%- endcomment -%}
{%- assign ce_svc = site.data[include.service] -%}
{%- assign ce_db_ids = ce_svc.databases | map: "id" -%}
{%- assign ce_targets = ce_svc.connections | where: "from", include.component | where_exp: "e", "ce_db_ids contains e.to" | map: "to" | uniq -%}
{%- for env in ce_svc.environments %}
{%- assign ce_page = site.pages | where: "service", include.service | where: "env", env.id | first %}
{%- assign ce_hosts = env.components[include.component].hosts %}

### {% if ce_page %}[{{ env.name }}]({{ ce_page.url | relative_url }}){% else %}{{ env.name }}{% endif %}
{: .no_toc }

**Runs on:** {% include runs-on.md env=env component=include.component %}
{% if ce_targets.size > 0 %}
| Database | Role | Schema | Runs on |
|:---------|:-----|:-------|:--------|
{% for t in ce_targets -%}
{%- assign d = ce_svc.databases | where: "id", t | first -%}
{%- assign ce_loc = env.databases[t] -%}
| {{ d.name | default: d.id | escape }} | {% if d.owner == include.component %}owner{% else %}uses{% endif %} | `{{ ce_loc.schema }}` | {% if ce_loc.server %}{% assign ce_srv = env.db_servers[ce_loc.server] %}`{{ ce_loc.server }}` · `{{ ce_srv.host }}:{{ ce_srv.port }}`{% elsif ce_hosts contains ce_loc.host %}this host · port {{ ce_loc.port }}{% else %}{% assign ce_co = nil %}{% for c in ce_svc.components %}{% if env.components[c.id].hosts contains ce_loc.host %}{% assign ce_co = c %}{% endif %}{% endfor %}{% if ce_co %}{% include entity-name.md service=include.service id=ce_co.id %} host · {% endif %}`{{ ce_loc.host }}:{{ ce_loc.port }}`{% endif %} |
{% endfor %}
{%- endif %}
{%- endfor %}
