# service-docu

Template for a service documentation site, built with [Jekyll](https://jekyllrb.com/) and the
[Just the Docs](https://just-the-docs.com/) theme and published with GitHub Pages.

Hostnames, ports, databases, connections and proxy routes live in YAML files under `_data/`. All
tables and diagrams on the site are generated from them, so you edit the data, not the pages.

## First-time setup

Do these once after creating your repository from this template. Steps 1–3 are needed for the
site to build and link correctly; step 4 replaces the example content.

### 1. `_config.yml`: site and repository

| Setting | Replace with | Example |
|:--------|:-------------|:--------|
| `title` | Site title | `Acme Service Docs` |
| `org_name` | Organization name, shown on the home page | `Acme Ltd` |
| `url` | `https://<github-org>.github.io` | `https://acme.github.io` |
| `baseurl` | `/<repository-name>` | `/service-docu` |
| `aux_links` → `Source on GitHub` | `https://github.com/<github-org>/<repository-name>` | `https://github.com/acme/service-docu` |
| `gh_edit_repository` | Same repository URL | `https://github.com/acme/service-docu` |
| `gh_edit_branch` | Default branch, if not `main` | `main` |

On a custom domain, set `url` to it (e.g. `https://docs.acme.com`) and `baseurl` to `""`.

### 2. `index.md`: home page

- Replace the paragraph under **Organization overview**.
- Replace the **Status page** and **Support / on-call** links under **Links**.

### 3. GitHub settings

- **Settings → Pages → Source**: choose **GitHub Actions**. Every push to `main` then builds and
  deploys the site. Without this, the build still runs and the built site can be downloaded from
  the run as the `example-site` artifact, but nothing is published.
- Optional: in `docs/guide.md`, replace `your-org` in the `git clone` command and the site link
  with your organization.

### 4. Your services

Everything in `_data/` and `docs/example-service/` is placeholder data. Rename the example
service to your first service and fill in its data: follow sections 3.2–3.10 of the
[Editing guide](docs/guide.md). Then run the data check (below) until it reports no errors.

## Run locally

Requires Ruby 3.3+ and Bundler.

```sh
bundle install
ruby scripts/check_data.rb          # validate the data files
bundle exec jekyll serve --livereload
```

Open <http://127.0.0.1:4000/service-docu/> (use your `baseurl`).

Without Ruby, use Docker:

```sh
docker run --rm -it -p 4000:4000 -v "$PWD":/srv -w /srv ruby:3.4 \
  sh -c "bundle install && ruby scripts/check_data.rb && bundle exec jekyll serve --host 0.0.0.0"
```

## More

The [Editing guide](docs/guide.md) (also published on the site) explains every data file and how
to add services, components, environments, proxies and guides.
