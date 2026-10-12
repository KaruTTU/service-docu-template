# service-docu

Service documentation site for **&lt;ORG NAME&gt;**, built with [Jekyll](https://jekyllrb.com/) and the
[Just the Docs](https://just-the-docs.com/) theme and published with GitHub Pages:
`https://<ORG>.github.io/service-docu/` (replace `<ORG>` with your GitHub organization)

The repository contains only documentation. Hostnames, ports, databases, connections and proxy routes
live **once** in YAML files under `_data/`. Every table and Mermaid diagram on the site is generated
from them with Liquid, so they can't drift apart. Edit the data, not the rendered tables.

> All values in `_data/` and the `<...>` names are **placeholders**. Replace them before publishing.

**Step-by-step instructions for filling in, checking and publishing the docs:** see the
[Editing guide](docs/guide.md) (published at `/docs/guide.html` on the site).

## Layout

```
_config.yml                    site settings (title, baseurl, search, Mermaid version)
index.md                       Home: organization overview + service list
_data/
  services.yml                 registry of services (title, summary, purpose, owners, links)
  <service>/
    components.yml             components: id, name, description, team, code/deploy repos, listening ports
    databases.yml              logical databases: id, name, engine, owning component
    environments.yml           per environment: sites, Kubernetes clusters, where each component
                               runs (hosts or cluster + namespace), shared database servers (with
                               cluster nodes per site), and where each database lives + schema
    connections.yml            network edges: from -> to (component, database or external), protocol, port
    external.yml               external dependencies: id, name, url, vendor, notes
    proxy.yml                  per environment: list of proxies (e.g. internet, intranet), each with
                               clients, type, host, listeners and routes host+path -> component:port
_includes/
  mermaid/                     diagram generators (architecture, ingress, data, per-component),
                               shared styles/legend and label/id helpers
  tables/                      table generators
  entity-name.md               id -> display name (links components to their pages)
docs/<service>/
  index.md                     service page (purpose, owners, architecture, traffic, data, externals)
  components/index.md          "Components" section page
  components/<component>.md    one page per component
  <env>.md                     one page per environment (test.md, prod.md)
  guides/index.md              "Guides" section page (lists the guides)
  guides/<guide>.md            one page per guide (hand-written how-tos)
scripts/check_data.rb          data consistency check (also run in CI)
```

Sidebar: **Home** › **&lt;Service&gt;** › **Components** (one page each), **Test**, **Prod**,
**Guides** (one page each).

## Run locally

Requires Ruby 3.3+ and Bundler.

```sh
bundle install
ruby scripts/check_data.rb          # validate the data files
bundle exec jekyll serve --livereload
```

Open <http://127.0.0.1:4000/service-docu/>.

Without a local Ruby, use Docker:

```sh
docker run --rm -it -p 4000:4000 -v "$PWD":/srv -w /srv ruby:3.4 \
  sh -c "bundle install && ruby scripts/check_data.rb && bundle exec jekyll serve --host 0.0.0.0"
```

## Common changes

Run `ruby scripts/check_data.rb` after every change. It reports missing pages, unknown ids,
environments that miss a component, proxy routes to ports a component doesn't listen on, and so on.

### Change a hostname, port or database

Edit the matching file in `_data/<service>/`. All tables and diagrams update automatically.

### Add a component

1. Add an entry to `_data/<service>/components.yml` (unique `id`).
2. Add its hosts under every environment in `_data/<service>/environments.yml`.
3. If it owns a database, add it to `databases.yml` (with `owner`) and to every environment's
   `databases:` in `environments.yml`.
4. Add its connections to `connections.yml` and any public routes to `proxy.yml`.
5. Copy `docs/<service>/components/component-a.md` to `docs/<service>/components/<id>.md`. Set
   `title` (= the component's `name`), `component` (= `id`) and `nav_order`, then rewrite the
   *Purpose*, *On-call* and *Configuration notes* sections.

### Put several databases on one database server

In `_data/<service>/environments.yml`, declare the server once per environment under `db_servers`
and point the databases at it. A database can still have its own `host`/`port` instead:

```yaml
- id: prod
  db_servers:
    pg-main: { host: pg-cluster.prod.example.internal, port: 5432, notes: Primary + 2 replicas }
  databases:
    db-a: { server: pg-main, schema: example_a }
    db-c: { server: pg-main, schema: example_c }
    db-b: { host: redis-01.prod.example.internal, port: 6379, schema: "db 0" }
```

Placement is per environment, so test can share one server while prod splits them. Environment
pages draw each server as a box around its databases and list servers and databases in tables.

### Run a component on Kubernetes

Declare the cluster under the environment's `clusters` and give the component `cluster` and
`namespace` instead of `hosts`:

```yaml
- id: prod
  clusters:
    k8s-prod: { type: Kubernetes, api: "https://k8s-prod.example.internal:6443", sites: [dc1, dc2] }
  components:
    component-a: { cluster: k8s-prod, namespace: example, replicas: 3 }
```

### Database cluster over several sites

Declare the sites once per environment and list the cluster members as `nodes` of the
`db_servers` entry (`host` stays the address applications connect to):

```yaml
- id: prod
  sites:
    dc1: { name: DC1 North }
    dc2: { name: DC2 South }
  db_servers:
    pg-main:
      host: pg-cluster.prod.example.internal
      port: 5432
      nodes:
        - { host: pg-01.dc1.example.internal, site: dc1, role: primary }
        - { host: pg-03.dc2.example.internal, site: dc2, role: replica }
```

The environment page gets a **Sites and clusters** section with a diagram per site and tables.
With one `primary` (or `leader`) node the diagram draws replication arrows from it; for a cluster
that is active in all sites at once, mark every node `role: primary` and it draws two-way "sync"
edges between the nodes instead.

### Add a guide

Copy `docs/<service>/guides/<existing>.md` to `docs/<service>/guides/<new>.md` and set `title`,
`nav_order` and `description`. Keep `parent: Guides` and `grand_parent: <Service title>`. The
Guides page and the service page list it automatically.

### Add an environment

1. Add an entry to `_data/<service>/environments.yml` with hosts for every component and database.
2. Add a key for it to `_data/<service>/proxy.yml` with that environment's list of proxies.
3. Copy `docs/<service>/test.md` to `docs/<service>/<env-id>.md`. Set `title`, `env` and `nav_order`.

### Add a proxy (e.g. a separate intranet proxy)

Add an entry to the environment's list in `_data/<service>/proxy.yml`:

```yaml
prod:
  - id: intranet              # same id in every environment
    name: Intranet proxy
    clients: Intranet         # proxies with the same clients share one source node
    type: nginx
    host: proxy.example.internal
    listen: [{ protocol: https, port: 443 }]
    routes:
      - { public_host: reports.example.internal, path: /, component: component-c, port: 8090, tls: Terminated at proxy, notes: "" }
```

The traffic-flow diagrams, proxy tables and component pages pick it up automatically.

### Add a service

1. Add an entry to `_data/services.yml` (`slug` = folder name).
2. Copy `_data/example-service/` to `_data/<slug>/` and replace the data.
3. Copy `docs/example-service/` to `docs/<slug>/`. In every page's front matter:
   - set `service: <slug>`
   - set the service page `title` to the `title` from `services.yml`, and its `nav_order`
   - set `parent:` (environment pages, `components/index.md`, `guides/index.md`) and
     `grand_parent:` (component pages and guides)
     to that same title. Just the Docs builds the sidebar from these titles.

### Data notes

- `id`s must be unique across a service's components, databases and external dependencies, because
  connections refer to any of them by id.
- Which components use an external dependency, and which components touch a database, are derived
  from `connections.yml`, so they are never listed twice.
- Text fields are HTML-escaped when rendered, so `<`, `&` and `|` are safe in names and descriptions.
  `services.yml` → `purpose` is the exception: it's rendered as Markdown.

## Publish with GitHub Pages

1. Push to `main`.
2. In the repository on GitHub, open **Settings → Pages** and set **Source** to **GitHub Actions**.
3. The workflow `.github/workflows/pages.yml` validates the data, builds the site and deploys it on
   every push to `main`. Pull requests are built and validated but not deployed. To redeploy
   manually, use **Actions → Build and deploy to GitHub Pages → Run workflow**.

If the repository is renamed or the site moves to a custom domain, update `url` and `baseurl` in
`_config.yml`.
