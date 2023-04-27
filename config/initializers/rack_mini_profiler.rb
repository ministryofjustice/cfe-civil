# frozen_string_literal: true

# :nocov:
if Rails.env.development?
  require "rack-mini-profiler"

  # Rack::MiniProfiler.config.authorization_mode = :allow_authorized
  # Rack::MiniProfiler.config.storage_options = { path: Rails.root.join("tmp/miniprofiler") }
  # Rack::MiniProfiler.config.storage = Rack::MiniProfiler::FileStore

  # The initializer was required late, so initialize it manually.
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
# :nocov:
