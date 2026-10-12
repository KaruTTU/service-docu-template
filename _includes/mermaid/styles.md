{%- comment -%}
  Shared Mermaid node classes. Include at the end of a flowchart, then tag nodes with
  :::comp, :::db, :::ext, :::net or :::focus (the component a page is about). Boxes (subgraphs)
  are styled from mermaid/box-styles.md instead. Keep the legend text in _includes/mermaid/legend.md in sync.
{%- endcomment %}
  classDef comp fill:#eef4ff,stroke:#3b6fd8,color:#1b2a4a
  classDef db fill:#ecfaf1,stroke:#2e9d5b,color:#183d27
  classDef ext fill:#fff4e6,stroke:#d9822b,color:#4a2c0b,stroke-dasharray:4 3
  classDef net fill:#f3f0ff,stroke:#7253c9,color:#2a1d52
  classDef focus fill:#3b6fd8,stroke:#1b2a4a,color:#ffffff,stroke-width:2px
