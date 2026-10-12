---
title: Example Service
nav_order: 2
has_children: true
has_toc: false
service: example-service
---

{%- assign service = site.data.services | where: "slug", page.service | first -%}
{%- assign svc = site.data[page.service] -%}

# {{ page.title }}
{: .no_toc }

{{ service.summary | escape }}
{: .fs-6 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Purpose

{{ service.purpose }}

{% for l in service.links -%}
- [{{ l.name | escape }}]({{ l.url }})
{% endfor %}

## Owners

{% include tables/owners.md service=page.service %}

## Architecture

All components, databases and external dependencies, with every network connection labeled
`protocol:port`.

{% include mermaid/architecture.md service=page.service %}

{% include mermaid/legend.md %}

{% include tables/connections.md service=page.service %}

## Traffic flow from the proxy

{% for env in svc.environments %}
### {{ env.name }}

{% include mermaid/ingress.md service=page.service env=env.id %}

{% include tables/proxy-routes.md service=page.service env=env.id %}
{% endfor %}

## Data

Solid edges point from a database's owning component; dashed edges are other components that
connect to the same database. Per-environment hosts and names are on the environment pages.

{% include mermaid/data.md service=page.service %}

## External dependencies

{% include tables/external.md service=page.service %}

## Components

{% include tables/components.md service=page.service %}

## Guides

{% include tables/guides.md service=page.service %}

## Environments

{% for env in svc.environments -%}
{%- assign env_page = site.pages | where: "service", page.service | where: "env", env.id | first -%}
- [{{ env.name }}]({{ env_page.url | relative_url }})
{% endfor %}
