require 'erb'
require 'fileutils'
require 'yaml'
require 'pry'

module DevStack
  class RenderContext
    def initialize(service, environment, vars)
      @service = service
      @environment = environment
      @vars = vars
    end

    def get_binding
      binding
    end

    def file_path(*args)
      @environment.file_path(@service.name, *args)
    end

    def method_missing(sym, *args)
      if @vars.has_key?(sym)
        @vars[sym]
      elsif @vars.has_key?(sym.to_s)
        @vars[sym.to_s]
      elsif @environment.respond_to?(sym)
        @environment.send(sym, @service, *args)
      else
        super
      end
    end
  end

  class Service
    attr_reader :name

    def initialize(name, template)
      @name = name
      @template = template
    end

    def render(environment, overrides = {})
      context = RenderContext.new(self, environment, template_vars.merge(overrides))
      YAML.load(ERB.new(@template).result(context.get_binding)).tap do |result|
        if result['files']
          result['files'].each_pair do |filename, content|
            full_path = environment.file_path(name, filename)
            FileUtils.mkdir_p(File.dirname(full_path))
            File.open(full_path, 'w') do |file|
              file.write(content)
            end
          end
        end
      end
    end

    private

    def template_vars
      YAML.load(@template)['variables'] || {}
    end
  end
end
