#!/usr/bin/env ruby
# frozen_string_literal: true

# Validates _data/ against itself and against the pages in docs/.
# Run from the repository root: ruby scripts/check_data.rb
# Exits non-zero and lists every problem found.

require "yaml"

ROOT = File.expand_path("..", __dir__)

def load_yaml(path)
  YAML.safe_load_file(path) || []
rescue Errno::ENOENT
  nil
end

def front_matter(path)
  text = File.read(path)
  match = text.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  match ? YAML.safe_load(match[1]) || {} : {}
end

def rel_path(path)
  path.delete_prefix("#{ROOT}/")
end

def check_service(svc, errors)
  slug = svc["slug"]
  data_dir = File.join(ROOT, "_data", slug)
  docs_dir = File.join(ROOT, "docs", slug)
  err = ->(msg) { errors << "#{slug}: #{msg}" }

  files = %w[components databases environments connections external proxy].to_h do |name|
    [name, load_yaml(File.join(data_dir, "#{name}.yml"))]
  end
  files.each { |name, value| err.call("missing _data/#{slug}/#{name}.yml") if value.nil? }
  return if files.values.any?(&:nil?)

  components = files["components"]
  databases = files["databases"]
  external = files["external"]
  environments = files["environments"]
  proxy = files["proxy"]

  component_ids = components.map { |c| c["id"] }
  database_ids = databases.map { |d| d["id"] }
  external_ids = external.map { |x| x["id"] }
  all_ids = component_ids + database_ids + external_ids
  env_ids = environments.map { |e| e["id"] }

  (all_ids.tally.select { |_, n| n > 1 }.keys).each { |id| err.call("id '#{id}' is not unique across components/databases/external") }
  (env_ids.tally.select { |_, n| n > 1 }.keys).each { |id| err.call("environment id '#{id}' is duplicated") }

  # Service page
  index = File.join(docs_dir, "index.md")
  if File.exist?(index)
    fm = front_matter(index)
    err.call("docs/#{slug}/index.md title '#{fm['title']}' != services.yml title '#{svc['title']}'") if fm["title"] != svc["title"]
    err.call("docs/#{slug}/index.md must set service: #{slug}") if fm["service"] != slug
  else
    err.call("missing docs/#{slug}/index.md")
  end

  # Components
  components.each do |c|
    err.call("component '#{c['id']}' has no ports") if Array(c["ports"]).empty?
    %w[code_repo deploy_repo].each do |k|
      next if c[k].nil?
      err.call("component '#{c['id']}' #{k} must be an http(s) URL") unless c[k].to_s.match?(%r{\Ahttps?://\S+\z})
    end
    Array(c["ports"]).each do |p|
      err.call("component '#{c['id']}' port #{p.inspect} needs integer port and protocol") unless p["port"].is_a?(Integer) && p["protocol"]
    end
    page = File.join(docs_dir, "components", "#{c['id']}.md")
    unless File.exist?(page)
      err.call("missing component page docs/#{slug}/components/#{c['id']}.md")
      next
    end
    fm = front_matter(page)
    err.call("#{rel_path(page)}: component '#{fm['component']}' != '#{c['id']}'") if fm["component"] != c["id"]
    err.call("#{rel_path(page)}: title '#{fm['title']}' != name '#{c['name']}'") if fm["title"] != c["name"]
    err.call("#{rel_path(page)}: grand_parent must be '#{svc['title']}'") if fm["grand_parent"] != svc["title"]
  end

  # Databases
  databases.each do |d|
    err.call("database '#{d['id']}' has no name") if d["name"].to_s.strip.empty?
    err.call("database '#{d['id']}' owner '#{d['owner']}' is not a component") unless component_ids.include?(d["owner"])
  end

  # Connections
  connections = files["connections"]
  connections.each do |e|
    label = "connection #{e['from']} -> #{e['to']}"
    err.call("#{label}: 'from' must be a component id") unless component_ids.include?(e["from"])
    err.call("#{label}: 'to' is not a known component/database/external id") unless all_ids.include?(e["to"])
    err.call("#{label}: needs integer port and protocol") unless e["port"].is_a?(Integer) && e["protocol"]
  end
  databases.each do |d|
    unless connections.any? { |e| e["from"] == d["owner"] && e["to"] == d["id"] }
      err.call("database '#{d['id']}': add a connection from its owner '#{d['owner']}'")
    end
  end
  external.each do |x|
    err.call("external '#{x['id']}' is not used by any connection") unless connections.any? { |e| e["to"] == x["id"] }
  end

  # Environments
  environments.each do |env|
    id = env["id"]
    env_components = env["components"] || {}
    env_databases = env["databases"] || {}
    (component_ids - env_components.keys).each { |c| err.call("environment '#{id}' is missing component '#{c}'") }
    (env_components.keys - component_ids).each { |c| err.call("environment '#{id}' has unknown component '#{c}'") }
    (database_ids - env_databases.keys).each { |d| err.call("environment '#{id}' is missing database '#{d}'") }
    (env_databases.keys - database_ids).each { |d| err.call("environment '#{id}' has unknown database '#{d}'") }
    sites = env["sites"] || {}
    clusters = env["clusters"] || {}
    sites.each { |s, v| err.call("environment '#{id}' site '#{s}' has no name") if v.nil? || v["name"].to_s.strip.empty? }
    clusters.each do |cl, v|
      Array(v && v["sites"]).each do |s|
        err.call("environment '#{id}' cluster '#{cl}': unknown site '#{s}'") unless sites.key?(s)
      end
    end
    env_components.each do |c, v|
      v ||= {}
      if v["cluster"]
        err.call("environment '#{id}' component '#{c}': set either hosts or cluster, not both") if v["hosts"]
        err.call("environment '#{id}' component '#{c}': unknown cluster '#{v['cluster']}'") unless clusters.key?(v["cluster"])
        err.call("environment '#{id}' component '#{c}' is missing namespace") if v["namespace"].to_s.strip.empty?
      elsif Array(v["hosts"]).empty?
        err.call("environment '#{id}' component '#{c}' needs hosts or a cluster")
      end
    end
    used_clusters = env_components.values.compact.map { |v| v["cluster"] }
    (clusters.keys - used_clusters).each { |cl| err.call("environment '#{id}' cluster '#{cl}' runs no component") }
    db_servers = env["db_servers"] || {}
    db_servers.each do |s, v|
      %w[host port].each { |k| err.call("environment '#{id}' db server '#{s}' is missing #{k}") if v.nil? || v[k].nil? }
      Array(v && v["nodes"]).each do |n|
        err.call("environment '#{id}' db server '#{s}': node #{n.inspect} is missing host") if n["host"].nil?
        err.call("environment '#{id}' db server '#{s}' node '#{n['host']}': unknown site '#{n['site']}'") if n["site"] && !sites.key?(n["site"])
      end
    end
    env_databases.each do |d, v|
      v ||= {}
      err.call("environment '#{id}' database '#{d}' is missing schema") if v["schema"].nil?
      if v["server"]
        err.call("environment '#{id}' database '#{d}': unknown db server '#{v['server']}'") unless db_servers.key?(v["server"])
        err.call("environment '#{id}' database '#{d}': set either server or host/port, not both") if v["host"] || v["port"]
      else
        %w[host port].each { |k| err.call("environment '#{id}' database '#{d}' needs server, or host and port (missing #{k})") if v[k].nil? }
      end
    end
    used_servers = env_databases.values.compact.map { |v| v["server"] }
    (db_servers.keys - used_servers).each { |s| err.call("environment '#{id}' db server '#{s}' hosts no database") }

    page = File.join(docs_dir, "#{id}.md")
    if File.exist?(page)
      fm = front_matter(page)
      err.call("docs/#{slug}/#{id}.md must set env: #{id}") if fm["env"] != id
      err.call("docs/#{slug}/#{id}.md parent must be '#{svc['title']}'") if fm["parent"] != svc["title"]
    else
      err.call("missing environment page docs/#{slug}/#{id}.md")
    end
  end

  # Guides: docs/<service>/guides/index.md plus one page per guide
  guides_dir = File.join(docs_dir, "guides")
  if Dir.exist?(guides_dir)
    guides_index = File.join(guides_dir, "index.md")
    if File.exist?(guides_index)
      fm = front_matter(guides_index)
      err.call("#{rel_path(guides_index)}: title must be 'Guides'") if fm["title"] != "Guides"
      err.call("#{rel_path(guides_index)}: parent must be '#{svc['title']}'") if fm["parent"] != svc["title"]
      err.call("#{rel_path(guides_index)} must set service: #{slug}") if fm["service"] != slug
    else
      err.call("missing docs/#{slug}/guides/index.md")
    end
    Dir.glob(File.join(guides_dir, "*.md")).sort.each do |page|
      next if page == guides_index || File.basename(page).start_with?("_")
      fm = front_matter(page)
      err.call("#{rel_path(page)}: missing title") if fm["title"].to_s.strip.empty?
      err.call("#{rel_path(page)}: parent must be 'Guides'") if fm["parent"] != "Guides"
      err.call("#{rel_path(page)}: grand_parent must be '#{svc['title']}'") if fm["grand_parent"] != svc["title"]
      err.call("#{rel_path(page)} must set service: #{slug}") if fm["service"] != slug
    end
  end

  # Proxy
  (env_ids - proxy.keys).each { |e| err.call("proxy.yml has no entry for environment '#{e}'") }
  (proxy.keys - env_ids).each { |e| err.call("proxy.yml has unknown environment '#{e}'") }
  proxy.each do |env, proxies|
    unless proxies.is_a?(Array)
      err.call("proxy.yml #{env}: must be a list of proxies")
      next
    end
    proxies.map { |px| px["id"] }.tally.select { |_, n| n > 1 }.each_key do |id|
      err.call("proxy.yml #{env}: proxy id '#{id}' is duplicated")
    end
    proxies.each do |px|
      %w[id name clients type host listen].each do |k|
        err.call("proxy.yml #{env}: proxy '#{px['id']}' is missing #{k}") if px[k].nil?
      end
      Array(px["routes"]).each do |r|
        label = "proxy.yml #{env}/#{px['id']}: route #{r['public_host']}#{r['path']}"
        comp = components.find { |c| c["id"] == r["component"] }
        if comp.nil?
          err.call("#{label}: unknown component '#{r['component']}'")
        elsif Array(comp["ports"]).none? { |p| p["port"] == r["port"] }
          err.call("#{label}: port #{r['port']} is not a port of '#{r['component']}'")
        end
      end
    end
  end
end

errors = []
services = load_yaml(File.join(ROOT, "_data", "services.yml")) || []
errors << "_data/services.yml is missing or empty" if services.empty?
slugs = services.map { |s| s["slug"] }
services.each { |svc| check_service(svc, errors) }

Dir.children(File.join(ROOT, "_data")).select { |d| File.directory?(File.join(ROOT, "_data", d)) }.each do |dir|
  errors << "_data/#{dir}/ has no entry in _data/services.yml" unless slugs.include?(dir)
end

if errors.empty?
  puts "Data OK: #{services.size} service(s) checked."
else
  warn errors.map { |e| "ERROR #{e}" }
  warn "#{errors.size} problem(s) found."
  exit 1
end
