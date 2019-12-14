require 'open-uri'

module DevStack
  class Stack
    attr_reader :services

    def initialize(stack_spec)
      @services = stack_spec.each_with_object({}) do |spec, hash|
        (name, config) = spec
        hash[name] = {
          service: DevStack::Service.new(name, load_template(config['template'])),
          environment: config['environment'] || {},
          variables: config['variables'] || {}
        }
      end
    end

    def docker_compose_yaml(*args)
      render(*args).to_yaml
    end

    def render(environment, overrides = {})
      components = @services.map do |name, service|
        service[:service].render(environment, service[:variables]).tap do |result|
          result['name'] = name

          service_hash = environment_hash(result['service_definition']['environment'])
          stack_hash = environment_hash(service[:environment])

          result['service_definition']['environment'] = service_hash.merge(stack_hash)
          result['volumes'] = Hash[(result['volumes'] ||= {}).map do |k, v|
            [[service[:service].name, k, environment.suffix].join("_"), v]
          end]
        end
      end

      {
        'version' => '3.4',
        'volumes' => components.each_with_object({}) { |component, hsh| hsh.merge!(component['volumes']) },
        'services' => components.each_with_object({}) { |component, hsh| hsh[component['name']] = component['service_definition'] }
      }
    end

    private

    def environment_hash(src)
      case src
      when Hash
        src
      when Array
        Hash[src.map { |var| var.split(/=/,2) }]
      else
        {}
      end
    end

    def load_template(val)
      return open(val).read if val.match?(/^https?:/)
      return open(val).read if File.exists?(val)
      path = File.join(File.expand_path('../../services', __dir__), val)
      return open(path).read if File.exists?(path)
    end
  end
end