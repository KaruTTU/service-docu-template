{%- comment -%}
  Escaped edge label for proxy routes that share an edge (same proxy and component): one line
  per route, "/path/ → :port" (full hosts are in the proxy routes table). Each line is kept from
  wrapping, so a path is never split across lines.
  Params: routes - the routes on the edge
{%- endcomment -%}
{%- capture rl_lines -%}{%- for r in include.routes -%}{{ r.path }} → :{{ r.port }}§{%- endfor -%}{%- endcapture -%}
{%- assign rl_lines = rl_lines | split: "§" | uniq -%}
{%- for l in rl_lines -%}
  {%- include mermaid/label.md text=l nowrap=true -%}{%- unless forloop.last -%}<br/>{%- endunless -%}
{%- endfor -%}
