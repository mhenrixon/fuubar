# frozen_string_literal: true

require 'rspec/core'
require 'rspec/core/formatters/base_text_formatter'
require 'ruby-progressbar'
require 'fuubar/output'
require 'set'

RSpec.configuration.add_setting :fuubar_progress_bar_options,   :default => {}
RSpec.configuration.add_setting :fuubar_auto_refresh,           :default => false
RSpec.configuration.add_setting :fuubar_output_pending_results, :default => true

class Fuubar < RSpec::Core::Formatters::BaseTextFormatter
  DEFAULT_PROGRESS_BAR_OPTIONS = { :format => ' %c/%C |%w>%i| %e ' }.freeze

  ::RSpec::Core::Formatters.register self,
                                     :example_failed,
                                     :example_passed,
                                     :example_pending,
                                     :start

  attr_accessor :example_tick_lock,
                :progress,
                :passed_count,
                :pending_count,
                :failed_count

  def initialize(*args)
    super

    self.example_tick_lock = ::Mutex.new
    # Initialize counts to handle cases where example methods might be called before start
    self.passed_count  = 0
    self.pending_count = 0
    self.failed_count  = 0
    self.progress = ::ProgressBar.create(
                      DEFAULT_PROGRESS_BAR_OPTIONS.
                        merge(:throttle_rate => continuous_integration? ? 1.0 : nil).
                        merge(:total     => 0,
                              :output    => output,
                              :autostart => false)
    )
    @printed_examples = Set.new
  end

  def start(notification)
    progress_bar_options = DEFAULT_PROGRESS_BAR_OPTIONS.
                             merge(:throttle_rate => continuous_integration? ? 1.0 : nil).
                             merge(configuration.fuubar_progress_bar_options).
                             merge(:total     => notification.count,
                                   :output    => output,
                                   :autostart => false)

    self.progress      = ::ProgressBar.create(progress_bar_options)
    self.passed_count  = 0
    self.pending_count = 0
    self.failed_count  = 0
    @printed_examples  = Set.new

    super

    with_current_color { progress.start }
  end

  def close(notification)
    @example_tick_thread.kill if @example_tick_thread
    super
  end

  def example_passed(_notification)
    self.passed_count += 1

    increment
  end

  def example_pending(_notification)
    self.pending_count += 1

    increment
  end

  def example_failed(notification)
    self.failed_count += 1

    # Avoid printing the same failure multiple times
    example_id = "#{notification.example.location}:#{notification.example.description}"
    unless @printed_examples.include?(example_id)
      @printed_examples.add(example_id)

      progress.clear

      output.puts notification.fully_formatted(failed_count)
      output.puts
    end

    increment
  end

  def example_tick(_notification)
    example_tick_lock.synchronize do
      refresh
    end
  end

  def example_tick_thread
    @example_tick_thread ||= ::Thread.new do
      loop do
        sleep(1)

        if configuration.fuubar_auto_refresh
          example_tick(notification)
        end
      end
    end
  end

  def message(notification)
    if progress && progress.respond_to?(:log)
      progress.log(notification.message)
    else
      super
    end
  end

  def dump_failures(notification)
    # We output each failure as it happens in example_failed,
    # so we don't need to output them again at the end.
    # Overriding this prevents BaseTextFormatter from outputting them again.
  end

  def dump_pending(notification)
    return unless configuration.fuubar_output_pending_results
    super
  end

  def dump_summary(summary)
    super
  end

  def seed(notification)
    super
  end





  def output
    @fuubar_output ||= ::Fuubar::Output.new(super, configuration.tty?) # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  private

  def increment
    return unless progress
    # Don't increment if total is 0 to avoid "0 out of 0" progress bar errors
    return if progress.total == 0
    with_current_color { progress.increment }
  end

  def refresh
    return unless progress
    with_current_color { progress.refresh }
  end

  def with_current_color
    return yield unless color_enabled?
    output.print "\e[#{color_code_for(current_color)}m"
    yield
    output.print "\e[0m"
  end

  def color_enabled?
    configuration.color_enabled? && !continuous_integration?
  end

  def current_color
    if failed_count > 0
      configuration.failure_color
    elsif pending_count > 0
      configuration.pending_color
    else
      configuration.success_color
    end
  end

  def color_code_for(*)
    ::RSpec::Core::Formatters::ConsoleCodes.console_code_for(*)
  end

  def configuration
    ::RSpec.configuration
  end

  def continuous_integration?
    @continuous_integration ||=
      ![nil, '', 'false'].include?(ENV.fetch('CONTINUOUS_INTEGRATION', nil))
  end
end
