require 'guard'
require 'guard/guard'
require 'guard/notifier'
require 'jslint'

module Guard
  class JslintOnRails < Guard
    VERSION = '0.2.0'

    def initialize(watchers=[], options={})
      super
      @config_path = File.join(Dir.pwd, options[:config_path] || 'config/jslint.yml')
    end

    def start
      UI.info "Guard::JsLintOnRails started using config: #{@config_path}"
    end

    def run_all
      run_on_change(all_paths)
    end

    def run_on_change(paths)
      error = nil
      output = StringIO.new

      begin
        capture_output(output) do
          lint = ::JSLint::Lint.new(
            :paths => paths,
            :config_path => @config_path 
          )
          lint.run
        end
      rescue ::JSLint::LintCheckFailure => e
        error = e
      end
      Notifier.notify((error ? "Failed!\n\n#{output.string}" : "Passed."), :title => "JSLint results", :image => (error ? :failed : :success))
      true
    end

    private
    def all_paths
      patterns = watchers.map(&:pattern)
      files = Dir.glob("*/**/*.js").map { |file| File.expand_path(file) }
      matching_files = patterns.map { |pattern| files.grep(pattern) }
      matching_files.flatten
    end

    def capture_output(output)
      $stdout = output
      $stderr = output
      yield
    ensure
      $stdout = STDOUT
      $stderr = STDERR
    end
  end
end
