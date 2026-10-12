---
title: Fail over the database
parent: Guides
grand_parent: Example Service
nav_order: 2
service: example-service
description: Move the primary of the pg-main cluster to the other site, planned or after a site outage.
---

{%- assign prod = site.data[page.service].environments | where: "id", "prod" | first -%}
{%- assign prod_page = site.pages | where: "service", page.service | where: "env", "prod" | first -%}

# {{ page.title }}
{: .no_toc }

{{ page.description }}
{: .fs-6 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
- TOC
{:toc}
</details>

## When to use this

<!-- PLACEHOLDER: replace with your real procedure. -->
- **Planned:** maintenance at the primary site.
- **Unplanned:** the primary site is down and the cluster manager didn't fail over by itself.

## Cluster nodes in Prod

Generated from `_data/`, so it always matches the [Prod]({{ prod_page.url | relative_url }}) page.

{% include tables/db-nodes.md env=prod server="pg-main" %}

## Steps

1. Check the cluster state:

   ```sh
   patronictl -c /etc/patroni/patroni.yml list
   ```

2. Planned switchover to a replica in the other site:

   ```sh
   patronictl -c /etc/patroni/patroni.yml switchover --candidate <replica-host>
   ```

3. Applications connect through the cluster address, so they need no change. Check that they
   reconnected (health endpoints on the component pages).

## Check that it worked

- `patronictl list` shows the new leader and the replicas streaming with no lag.
- Update the `role` of the nodes in `_data/example-service/environments.yml` if the new primary is
  meant to stay.

## Roll back

Run the switchover again with the original primary as `--candidate`.
