{%- comment -%}
  Ingress / traffic-flow diagram for one environment: clients -> proxies -> components.
  Params: service - service slug; env - environment id (key in proxy.yml)
  One source node per distinct `clients` value (e.g. Internet, Intranet), one node per proxy.
  Edge labels: proxy listeners, then public host+path -> backend port.
{%- endcomment -%}
{%- assign ing_svc = site.data[include.service] -%}
{%- assign ing_proxies = ing_svc.proxy[include.env] -%}
{%- assign ing_env = ing_svc.environments | where: "id", include.env | first -%}
{%- assign ing_routes = "" | split: "" -%}
{%- for px in ing_proxies -%}{%- assign ing_routes = ing_routes | concat: px.routes -%}{%- endfor -%}
{%- assign ing_targets = ing_routes | map: "component" | uniq -%}
{%- assign ing_clients = ing_proxies | map: "clients" | uniq -%}
```mermaid
flowchart LR
{%- for cl in ing_clients %}
  x_src_{{ cl | slugify | replace: "-", "_" }}(("{% include mermaid/label.md text=cl %}")):::net
{%- endfor %}
{%- for px in ing_proxies %}
  {%- capture ing_listen -%}
    {%- for l in px.listen -%}{{ l.protocol }}:{{ l.port }}{% unless forloop.last %}, {% endunless %}{%- endfor -%}
  {%- endcapture %}
  x_proxy_{{ px.id | slugify | replace: "-", "_" }}["{% include mermaid/label.md text=px.name %}<br/>{% include mermaid/label.md text=px.type %} @ {% include mermaid/label.md text=px.host %}"]:::net
  x_src_{{ px.clients | slugify | replace: "-", "_" }} -->|"{% include mermaid/label.md text=ing_listen %}"| x_proxy_{{ px.id | slugify | replace: "-", "_" }}
{%- endfor %}
{%- for cid in ing_targets %}
  {%- assign ing_c = ing_svc.components | where: "id", cid | first %}
  {%- assign ing_cl = ing_env.components[cid] %}
  {%- capture ing_ns %}{{ ing_cl.cluster }} · ns {{ ing_cl.namespace }}{% endcapture %}
  {% include mermaid/node-id.md id=cid %}["{% include mermaid/label.md text=ing_c.name %}
    {%- if ing_cl.cluster %}<br/>{% include mermaid/label.md text=ing_ns %}{% endif -%}
    {%- for h in ing_cl.hosts -%}
      <br/>{% include mermaid/label.md text=h %}
    {%- endfor -%}
  "]:::comp
{%- endfor %}
{%- comment -%} One edge per proxy and component, labelled by mermaid/route-label.md {%- endcomment -%}
{%- for px in ing_proxies %}
  {%- assign ing_px_targets = px.routes | map: "component" | uniq %}
  {%- for t in ing_px_targets %}
    {%- assign ing_px_routes = px.routes | where: "component", t %}
  x_proxy_{{ px.id | slugify | replace: "-", "_" }} -->|"{% include mermaid/route-label.md routes=ing_px_routes %}"| {% include mermaid/node-id.md id=t %}
  {%- endfor %}
{%- endfor %}
{% include mermaid/styles.md %}
```
