{%- comment -%}
  Resolves where a database lives in one environment and outputs `host:port`.
  Params: env - environment object (from environments.yml); db - database id
  A database either has its own host/port, or points to a shared entry in env.db_servers.
{%- endcomment -%}
{%- assign dl_db = include.env.databases[include.db] -%}
{%- if dl_db.server -%}
  {%- assign dl_loc = include.env.db_servers[dl_db.server] -%}
{%- else -%}
  {%- assign dl_loc = dl_db -%}
{%- endif -%}
{{ dl_loc.host }}:{{ dl_loc.port -}}
