---
title: Home
layout: home
nav_order: 1
description: Service documentation for <ORG NAME>.
permalink: /
---

# {{ site.org_name | escape }} service documentation
{: .fs-9 }

Architecture, components, environments and traffic flow for the services run by {{ site.org_name | escape }}.
{: .fs-6 .fw-300 }

## Organization overview

<!-- PLACEHOLDER: replace with a short description of the organization, its teams and how services are operated. -->
Replace this paragraph with a short overview of the organization: what it does, which teams
run the services documented here, and where to go for support.

## Services

{% include tables/services.md %}

## How this site works

Hostnames, ports, databases, connections and proxy routes for each service live in YAML files under
`_data/<service>/`. Every table and diagram on this site is generated from those files, so update the
data rather than the pages. See the
[README]({{ site.gh_edit_repository }}#readme) for how to add a service, component or environment.

## Links

- [Source repository]({{ site.gh_edit_repository }})
- <!-- PLACEHOLDER --> [Status page](https://status.example.org)
- <!-- PLACEHOLDER --> [Support / on-call](https://support.example.org)
