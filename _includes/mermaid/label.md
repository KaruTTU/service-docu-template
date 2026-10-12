{%- comment -%}
  Escapes text for a Mermaid label. Params: text; nowrap - optional, true keeps the label on one
  line (non-breaking spaces and hyphens), for long edge labels such as proxy routes.
{%- endcomment -%}
{%- if include.nowrap -%}
{{ include.text | replace: "#", "#35;" | replace: "&", "#38;" | replace: '"', "#quot;" | replace: "<", "#lt;" | replace: ">", "#gt;" | replace: "|", "#124;" | replace: "`", "#96;" | replace: " ", "#nbsp;" | replace: "-", "#8209;" -}}
{%- else -%}
{{ include.text | replace: "#", "#35;" | replace: "&", "#38;" | replace: '"', "#quot;" | replace: "<", "#lt;" | replace: ">", "#gt;" | replace: "|", "#124;" | replace: "`", "#96;" -}}
{%- endif -%}
