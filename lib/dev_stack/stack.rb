require 'open-uri'

module DevStack
  class Stack
    attr_reader :services

    def initialize(stack_spec)
      @services = stack_spec.each_with_object({}) do |spec, hash|
        (name, config) = spec
        hash[name] = {
          service: DevStack::Service.new(name, open(config['template']).read),
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
  end
end