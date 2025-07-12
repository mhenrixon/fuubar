require "rspec/core"
require "rspec/core/formatters/base_formatter"
require "ruby-progressbar"

RSpec.configuration.add_setting :fuubar_progress_bar_options, default: {}
RSpec.configuration.add_setting :fuubar_auto_refresh, default: false
RSpec.configuration.add_setting :fuubar_output_pending_results, default: true

module RSpec
  class Fuubar < Core::Formatters::BaseFormatter
    Core::Formatters.register self,
      :start,
      :example_passed,
      :example_failed,
      :example_pending,
      :message,
      :dump_pending,
      :dump_failures,
      :dump_summary,
      :seed,
      :close

    DEFAULT_PROGRESS_BAR_OPTIONS = { format: " %c/%C |%w>%i| %e " }.freeze

    attr_reader :progress, :passed_count, :pending_count, :failed_count

    def initialize(output)
      super
      @passed_count = 0
      @pending_count = 0
      @failed_count = 0
    end

    def start(notification)
      @passed_count = 0
      @pending_count = 0
      @failed_count = 0

      progress_options = DEFAULT_PROGRESS_BAR_OPTIONS
                         .merge(throttle_rate: continuous_integration? ? 1.0 : nil)
                         .merge(RSpec.configuration.fuubar_progress_bar_options)
                         .merge(total: notification.count,
                           output:,
                           autostart: false)

      @progress = ProgressBar.create(progress_options)

      with_current_color { @progress.start }
    end

    def example_passed(_notification)
      @passed_count += 1
      increment
    end

    def example_pending(_notification)
      @pending_count += 1
      increment
    end

    def example_failed(notification)
      @failed_count += 1

      # Clear progress bar and output failure immediately
      @progress&.clear

      output.puts
      output.puts notification.fully_formatted(@failed_count)
      output.puts

      increment
    end

    def message(notification)
      if @progress.respond_to?(:log)
        @progress.log(notification.message)
      else
        output.puts notification.message
      end
    end

    def dump_pending(notification)
      return unless RSpec.configuration.fuubar_output_pending_results
      return if notification.pending_examples.empty?

      output.puts
      output.puts notification.fully_formatted_pending_examples
    end

    def dump_failures(_notification)
      # We output failures immediately as they happen
    end

    def dump_summary(notification)
      output.puts
      output.puts notification.fully_formatted
    end

    def seed(notification)
      return unless notification.seed_used?

      output.puts notification.fully_formatted
    end

    def close(_notification)
      @progress&.stop
    end

    private

    def increment
      return unless @progress

      with_current_color { @progress.increment }
    end

    def with_current_color
      return yield unless color_enabled?

      output.print "\e[#{color_code_for(current_color)}m"
      yield
      output.print "\e[0m"
    end

    def color_enabled?
      RSpec.configuration.color_enabled? && output.tty? && !continuous_integration?
    end

    def current_color
      if @failed_count.positive?
        :failure
      elsif @pending_count.positive?
        :pending
      else
        :success
      end
    end

    def color_code_for(symbol)
      Core::Formatters::ConsoleCodes.console_code_for(symbol)
    end

    def continuous_integration?
      ENV["CI"] == "true" || ENV["CONTINUOUS_INTEGRATION"] == "true"
    end
  end
end
