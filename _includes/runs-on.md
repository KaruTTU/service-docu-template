{%- comment -%}
  Where a component runs in one environment, as Markdown: its hosts, or the Kubernetes cluster
  and namespace it is deployed to.
  Params: env - environment object (from environments.yml); component - component id;
          sep - separator between hosts (default ", ")
{%- endcomment -%}
{%- assign ro_c = include.env.components[include.component] -%}
{%- if ro_c.cluster -%}
  `{{ ro_c.cluster }}` · namespace `{{ ro_c.namespace }}`{% if ro_c.replicas %} · {{ ro_c.replicas }} replicas{% endif %}
{%- else -%}
  {%- for h in ro_c.hosts %}`{{ h }}`{% unless forloop.last %}{{ include.sep | default: ", " }}{% endunless %}{% endfor -%}
{%- endif -%}
