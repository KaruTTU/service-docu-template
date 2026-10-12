---
title: Deploy a new version
parent: Guides
grand_parent: Example Service
nav_order: 1
service: example-service
description: Roll out a new release of the components that run on Kubernetes, and roll it back.
---

{%- assign svc = site.data[page.service] -%}
{%- assign prod = svc.environments | where: "id", "prod" | first -%}

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
A new release of a component has been tested in Test and is approved for Prod.

## Before you start

- Access to the cluster API (`kubectl` context for the cluster below).
- The release tag, and the change approved in the issue tracker.

Where each component runs in Prod (from `_data/`, so it is always current):

| Component | Runs on |
|:----------|:--------|
{% for c in svc.components -%}
| {% include entity-name.md service=page.service id=c.id %} | {% include runs-on.md env=prod component=c.id %} |
{% endfor %}

## Steps

1. Update the image tag in the component's deployment repository and merge the change.
2. Watch the rollout:

   ```sh
   kubectl --context <cluster> -n <namespace> rollout status deployment/<name>
   ```

3. Check the health endpoint through the proxy (see the component page, **Proxy routes**).

## Check that it worked

- All pods are `Running` and ready: `kubectl -n <namespace> get pods`.
- No new errors in the logs for 10 minutes.

## Roll back

```sh
kubectl --context <cluster> -n <namespace> rollout undo deployment/<name>
```
