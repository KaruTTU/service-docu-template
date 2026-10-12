{%- comment -%}
  Styles for subgraph boxes, applied with `style <subgraph-id> {{ box_server_style }}` etc.
  `style`, not `class`: Mermaid drops a class on a subgraph that an edge points at.
  Include once at the top of a diagram include; it sets the variables below.
{%- endcomment -%}
{%- assign box_server_style = "fill:#f7fcf9,stroke:#2e9d5b,color:#183d27,stroke-width:1.5px" -%}
{%- assign box_host_style = "fill:#f8f9fb,stroke:#8a94a6,color:#2b3240,stroke-width:1.5px,stroke-dasharray:5 4" -%}
{%- assign box_site_style = "fill:#fbfbfd,stroke:#5b6475,color:#2b3240,stroke-width:1.5px" -%}
