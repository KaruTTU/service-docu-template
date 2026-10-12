{%- comment -%}
  Header line of a component page: team, code repository and deployment repository.
  Params: service - service slug; component - component id
  Repositories come from components.yml (`code_repo`, `deploy_repo`); the link text is the last
  two parts of the URL (usually <org>/<repo>). Missing ones show as "not set yet".
{%- endcomment -%}
{%- assign cr_c = site.data[include.service].components | where: "id", include.component | first -%}
**Team:** {{ cr_c.team | escape }} &nbsp;·&nbsp;
**Code:** {% if cr_c.code_repo %}{% assign cr_parts = cr_c.code_repo | split: "/" %}[{{ cr_parts[-2] }}/{{ cr_parts[-1] }}]({{ cr_c.code_repo }}){% else %}_not set yet_{% endif %} &nbsp;·&nbsp;
**Deployment:** {% if cr_c.deploy_repo %}{% assign cr_parts = cr_c.deploy_repo | split: "/" %}[{{ cr_parts[-2] }}/{{ cr_parts[-1] }}]({{ cr_c.deploy_repo }}){% else %}_not set yet_{% endif %}
