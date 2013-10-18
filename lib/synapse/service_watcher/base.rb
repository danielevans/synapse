require 'digest'

module Synapse
  class BaseWatcher
    attr_reader :name, :backends, :haproxy

    def initialize(opts={}, synapse)
      super()

      @synapse = synapse

      # set required service parameters
      %w{name discovery haproxy}.each do |req|
        raise ArgumentError, "missing required option #{req}" unless opts[req]
      end

      @name = opts['name']
      @discovery = opts['discovery']

      # the haproxy config
      @haproxy = opts['haproxy']
      raise ArgumentError, "haproxy config for service #{name} must include a port" unless @haproxy.include?('port')

      @haproxy['listen'] ||= []
      @haproxy['server_options'] ||= ""
      @haproxy['server_port_override'] ||= nil

      # set initial backends to default servers, if any
      @default_servers = opts['default_servers'] || []
      @backends = @default_servers

      validate_discovery_opts
    end

    # this should be overridden to actually start your watcher
    def start
      log.info "synapse: starting stub watcher; this means doing nothing at all!"
    end

    # this should be overridden to do a health check of the watcher
    def ping?
      true
    end

    def construct_name(name, address, port)
      address_digest = Digest::SHA256.hexdigest(address)[0..7]
      return "#{name}:#{port}_#{address_digest}"
    end

    private
    def validate_discovery_opts
      raise ArgumentError, "invalid discovery method '#{@discovery['method']}' for base watcher" \
        unless @discovery['method'] == 'base'

      log.warn "synapse: warning: a stub watcher with no default servers is pretty useless" if @default_servers.empty?
    end
  end
end
