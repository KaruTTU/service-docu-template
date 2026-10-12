---
title: Test
parent: Example Service
nav_order: 2
service: example-service
env: test
---

# {{ page.title }} environment
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## Overview

Everything in this environment in one picture: clients and proxies on the left, then the
components, their databases and external services. Every edge is labeled with protocol and port
(proxy edges with the path and backend port; full hosts are in the proxy routes table). Dashed
edges are databases used by a component that doesn't own them; an edge to a box means every
database in it. Click any diagram to see it full size.

{% include mermaid/env-overview.md service=page.service env=page.env %}

{% include mermaid/legend.md %}

## Components

{% include tables/environment.md service=page.service env=page.env %}

## Databases

Each box is where databases run: green boxes are database servers, grey dashed boxes are
application hosts (with the component that runs there). Solid edges come from a database's owning
component, dashed edges from other components that use it; an edge to a box means every database
in it.

{% include mermaid/db-placement.md service=page.service env=page.env %}

{% include tables/db-locations.md service=page.service env=page.env %}

{%- assign pg_env = site.data[page.service].environments | where: "id", page.env | first %}
{% if pg_env.sites or pg_env.clusters %}
## Sites and clusters

Where things physically run: each box is a site (data centre) with the database-cluster nodes and
Kubernetes clusters located there. Dashed edges are replication from a primary to its replicas.

{% include mermaid/sites.md service=page.service env=page.env %}

{% include tables/sites.md service=page.service env=page.env %}
{% endif %}

## Proxy routes

{% include mermaid/ingress.md service=page.service env=page.env %}

{% include tables/proxy-routes.md service=page.service env=page.env %}
