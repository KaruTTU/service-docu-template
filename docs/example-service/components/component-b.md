---
title: Component B
parent: Components
grand_parent: Example Service
nav_order: 2
service: example-service
component: component-b
---

{%- assign comp = site.data[page.service].components | where: "id", page.component | first -%}

# {{ comp.name | escape }}
{: .no_toc }

{{ comp.description | escape }}
{: .fs-6 .fw-300 }

{% include component-repos.md service=page.service component=page.component %}

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Purpose

<!-- PLACEHOLDER: describe what this component does and why it exists. -->
Describe what this component is responsible for, its main workflows and anything a new team member
should know first.

## On-call

What to do when this component misbehaves. Keep it short and practical.

<!-- Fill in each line; remove the ones that don't apply. Never put secrets here, only where they are stored. -->
- **Health check:** _not documented yet_ (URL or command that shows it is up)
- **Logs:** _not documented yet_ (where to find them)
- **Restart:** _not documented yet_ (command or procedure, and whether it is safe during the day)
- **Common problems:** _not documented yet_ (symptom → cause → fix)
- **Escalation:** _not documented yet_ (who to call if this doesn't help, and how)

## Connections

What calls this component (left) and what it depends on (right). Every connection is labeled
`protocol:port`; proxy edges show the backend port.

{% include mermaid/component.md service=page.service component=page.component %}

{% include mermaid/legend.md focus=true %}

## Ports

{% include tables/component-ports.md service=page.service component=page.component %}

## Hosts and databases per environment

{% include tables/component-environments.md service=page.service component=page.component %}

## Dependencies

Outbound connections to other components, databases and external services:

{% include tables/connections.md service=page.service from=page.component %}

Inbound connections from other components:

{% include tables/connections.md service=page.service to=page.component %}

## External dependencies

{% include tables/external.md service=page.service component=page.component %}

## Proxy routes

{% for env in site.data[page.service].environments %}
### {{ env.name }}
{: .no_toc }

{% include tables/proxy-routes.md service=page.service env=env.id component=page.component %}
{% endfor %}

## Configuration notes

<!-- PLACEHOLDER: configuration that matters for operations. -->
- Config file location: `/etc/<component>/config.yml`
- Required environment variables / secrets: _list names only, never values_
- Feature flags, tuning parameters, log locations
