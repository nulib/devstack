require 'dev_stack'

DEFAULT_OPTIONS = { 'environment' => 'dev' }

module DevStack
  class CLI
    attr_reader :argv, :opts

    def initialize(opts, argv=ARGV)
      @argv = argv
      opts['stack'] = stack_arg unless stack_arg.nil?
      @opts = DEFAULT_OPTIONS.merge(load_defaults()).merge(opts)
    end

    def compose_file
      if @compose_file.nil?
        @compose_file = environment.file_path('docker-compose.yml').to_s
        File.open(@compose_file, 'w') do |file|
          file.write(stack.docker_compose_yaml(environment))
        end
      end
      @compose_file
    end

    def command_line
      (['docker-compose', '-f', compose_file] + argv).tap do |result|
        result << '-v' if argv[0] == 'down' && environment.destroy_volumes
      end
    end

    def environment
      @environment ||= DevStack::Environment.new YAML.load(environment_file(opts['environment']))
    end

    def stack
      if @stack.nil?
        stack_yaml = stack_file(opts['stack']) || 
          load_file(find_stack_file(File.expand_path('.'))) ||
          stack_file('_all')
        raise "Stack not found" if stack_yaml.nil?
        @stack = DevStack::Stack.new YAML.load(stack_yaml)
      end
      @stack
    end

    def trap_cmd
      return [] unless ['up', '-d'] & argv == ['up']
      ['docker-compose', '-f', compose_file, 'down'].tap do |result|
        result << '-v' if environment.destroy_volumes
      end
    end
  
    def exec!
      ENV['COMPOSE_PROJECT_NAME'] ||= "devstack"
      ENV['COMPOSE_PROJECT_NAME'] = [ENV['COMPOSE_PROJECT_NAME'], environment.name].join('_')
      begin
        Kernel.system(*command_line)
      rescue Interrupt # rubocop:disable Lint/HandleExceptions
        # Let it go
      ensure
        final_cmd = trap_cmd
        Kernel.system(*final_cmd) unless final_cmd.empty?
      end
    end
  
    def environment_file(val)
      return nil if val.nil?
      load_file(val, File.expand_path('environments', DevStack.root))
    end

    def stack_file(val)
      return nil if val.nil?
      load_file(val, File.expand_path('stacks', DevStack.root))
    end

    def load_file(val, default_location = '.')
      return nil if val.nil?
      return open(val).read if val.match?(/^https?:/)
      return open(val).read if File.file?(val)
      path = File.join(default_location, val)
      path += '.yml' if File.extname(path).empty?
      return open(path).read if File.exists?(path)
      nil
    end

    def load_defaults
      devstack_file = find_devstack_file(File.expand_path('.'))
      return {} if devstack_file.nil? || !File.exists?(devstack_file)
      YAML.load(File.read(devstack_file))
    end

    def find_devstack_file(path)
      find_file_upstream(path, '.devstack')
    end

    def find_stack_file(path)
      find_file_upstream(path, '.stack')
    end

    def find_file_upstream(path, filename)
      candidate = File.join(path, filename)
      return candidate if File.exists?(candidate)
      return nil if path == '/' or path == ENV['HOME']
      return find_file_upstream(File.expand_path('..', path), filename)
    end

    def stack_arg
      if @stack_arg.nil?
        first_non_switch = argv[1..-1].find_index { |x| ! x.start_with?('-') }
        if first_non_switch.nil? || (! DevStack.is_stack?(argv[first_non_switch+1]))
          @stack_arg = '__NIL__' 
        else
          @stack_arg = argv.slice!(first_non_switch+1)
        end
      end
      return nil if @stack_arg == '__NIL__'
      @stack_arg
    end
  end
end
