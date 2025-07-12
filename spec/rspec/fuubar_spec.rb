require "rspec/fuubar"
require "stringio"

RSpec.describe RSpec::Fuubar do
  let(:output)    { StringIO.new }
  let(:formatter) { described_class.new(output) }

  describe "#start" do
    it "creates and starts a progress bar" do
      notification = double("notification", count: 10)

      formatter.start(notification)

      expect(formatter.progress).to be_a(ProgressBar::Base)
      expect(formatter.progress.total).to eq(10)
      expect(formatter.progress).to be_started
    end

    it "resets all counts" do
      formatter.instance_variable_set(:@passed_count, 5)
      formatter.instance_variable_set(:@failed_count, 3)
      formatter.instance_variable_set(:@pending_count, 2)

      notification = double("notification", count: 10)
      formatter.start(notification)

      expect(formatter.passed_count).to eq(0)
      expect(formatter.failed_count).to eq(0)
      expect(formatter.pending_count).to eq(0)
    end
  end

  describe "#example_passed" do
    before do
      notification = double("notification", count: 10)
      formatter.start(notification)
    end

    it "increments the passed count" do
      expect { formatter.example_passed(double) }.to change(formatter, :passed_count).from(0).to(1)
    end
  end

  describe "#example_failed" do
    before do
      notification = double("notification", count: 10)
      formatter.start(notification)
    end

    it "increments the failed count" do
      failed_notification = double("notification", fully_formatted: "Failure message")

      expect { formatter.example_failed(failed_notification) }.to change(formatter, :failed_count).from(0).to(1)
    end

    it "outputs the failure message" do
      failed_notification = double("notification", fully_formatted: "Failure message")

      formatter.example_failed(failed_notification)

      output.rewind
      expect(output.read).to include("Failure message")
    end
  end

  describe "#example_pending" do
    before do
      notification = double("notification", count: 10)
      formatter.start(notification)
    end

    it "increments the pending count" do
      expect { formatter.example_pending(double) }.to change(formatter, :pending_count).from(0).to(1)
    end
  end

  describe "#message" do
    it "logs to progress bar when available" do
      notification = double("notification", count: 10)
      formatter.start(notification)

      message_notification = double("notification", message: "Test message")
      allow(formatter.progress).to receive(:respond_to?).with(:log).and_return(true)
      expect(formatter.progress).to receive(:log).with("Test message")

      formatter.message(message_notification)
    end

    it "outputs directly when progress bar is not available" do
      message_notification = double("notification", message: "Test message")

      formatter.message(message_notification)

      output.rewind
      expect(output.read).to include("Test message")
    end
  end

  describe "#dump_summary" do
    it "outputs the formatted summary" do
      summary = double("summary", fully_formatted: "Test summary")

      formatter.dump_summary(summary)

      output.rewind
      expect(output.read).to include("Test summary")
    end
  end

  describe "#seed" do
    it "outputs seed when used" do
      seed = double("seed", seed_used?: true, fully_formatted: "Randomized with seed 12345")

      formatter.seed(seed)

      output.rewind
      expect(output.read).to include("Randomized with seed 12345")
    end

    it "outputs nothing when seed is not used" do
      seed = double("seed", seed_used?: false)

      formatter.seed(seed)

      output.rewind
      expect(output.read).to be_empty
    end
  end

  describe "#dump_pending" do
    context "when configured to output pending results" do
      before do
        allow(RSpec.configuration).to receive(:fuubar_output_pending_results).and_return(true)
      end

      it "outputs pending examples when they exist" do
        notification = double("notification",
          pending_examples: [double],
          fully_formatted_pending_examples: "Pending examples output")

        formatter.dump_pending(notification)

        output.rewind
        expect(output.read).to include("Pending examples output")
      end

      it "outputs nothing when no pending examples" do
        notification = double("notification", pending_examples: [])

        formatter.dump_pending(notification)

        output.rewind
        expect(output.read).to be_empty
      end
    end

    context "when configured not to output pending results" do
      before do
        allow(RSpec.configuration).to receive(:fuubar_output_pending_results).and_return(false)
      end

      it "outputs nothing" do
        notification = double("notification",
          pending_examples: [double],
          fully_formatted_pending_examples: "Pending examples output")

        formatter.dump_pending(notification)

        output.rewind
        expect(output.read).to be_empty
      end
    end
  end

  describe "#dump_failures" do
    it "does not output anything (failures are output immediately)" do
      formatter.dump_failures(double)

      output.rewind
      expect(output.read).to be_empty
    end
  end

  describe "#close" do
    it "stops the progress bar if it exists" do
      notification = double("notification", count: 10)
      formatter.start(notification)

      expect(formatter.progress).to receive(:stop)
      formatter.close(double)
    end

    it "does not error when progress bar does not exist" do
      expect { formatter.close(double) }.not_to raise_error
    end
  end

  describe "color support" do
    before do
      notification = double("notification", count: 10)
      formatter.start(notification)
    end

    context "when colors are enabled" do
      before do
        allow(RSpec.configuration).to receive(:color_enabled?).and_return(true)
        allow(output).to receive(:tty?).and_return(true)
        allow(ENV).to receive(:[]).with("CI").and_return(nil)
        allow(ENV).to receive(:[]).with("CONTINUOUS_INTEGRATION").and_return(nil)
      end

      it "outputs color codes when incrementing" do
        allow(formatter.progress).to receive(:increment)

        expect(output).to receive(:print).with(/\e\[\d+m/)
        expect(output).to receive(:print).with("\e[0m")

        formatter.send(:increment)
      end
    end

    context "when in CI environment" do
      before do
        allow(ENV).to receive(:[]).with("CI").and_return("true")
      end

      it "does not use colors" do
        allow(formatter.progress).to receive(:increment)

        expect(output).not_to receive(:print)

        formatter.send(:increment)
      end
    end
  end
end
