{%- comment -%}
  Colour key for diagrams using _includes/mermaid/styles.md (keep the colours in sync).
  Params: focus - optional; set to true on pages whose diagram highlights one component
{%- endcomment -%}
{%- capture lg_box -%}display:inline-block;width:0.9em;height:0.9em;vertical-align:-0.1em;border:1.5px solid{%- endcapture -%}
{% if include.focus %}<span style="{{ lg_box }} #1b2a4a;background:#3b6fd8"></span> this component &nbsp;
{% endif -%}
<span style="{{ lg_box }} #3b6fd8;background:#eef4ff"></span> component &nbsp;
<span style="{{ lg_box }} #2e9d5b;background:#ecfaf1"></span> database &nbsp;
<span style="{{ lg_box }} #d9822b;background:#fff4e6;border-style:dashed"></span> external dependency &nbsp;
<span style="{{ lg_box }} #7253c9;background:#f3f0ff"></span> clients / proxy
{: .fs-2 }
