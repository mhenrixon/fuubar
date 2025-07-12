# frozen_string_literal: true

require 'fuubar'
require 'stringio'

describe Fuubar do
  let(:output) do
    io = StringIO.new
    allow(io).to receive(:tty?).and_return(true)
    io
  end

  let(:formatter) { Fuubar.new(output) }
  let(:example) { double('example').as_null_object }
  let(:notification) { double('notification', example: example).as_null_object }

  context 'when example methods are called before start' do
    it 'does not raise errors when example_passed is called' do
      expect { formatter.example_passed(notification) }.not_to raise_error
      expect(formatter.passed_count).to eq(1)
    end

    it 'does not raise errors when example_failed is called' do
      allow(notification).to receive(:fully_formatted).and_return('Failed example')
      expect { formatter.example_failed(notification) }.not_to raise_error
      expect(formatter.failed_count).to eq(1)
    end

    it 'does not raise errors when example_pending is called' do
      expect { formatter.example_pending(notification) }.not_to raise_error
      expect(formatter.pending_count).to eq(1)
    end

    it 'does not increment the progress bar when total is 0' do
      expect(formatter.progress).not_to receive(:increment)
      formatter.example_passed(notification)
    end

    it 'accumulates counts correctly when multiple examples are processed' do
      formatter.example_passed(notification)
      formatter.example_passed(notification)
      formatter.example_failed(notification)
      formatter.example_pending(notification)

      expect(formatter.passed_count).to eq(2)
      expect(formatter.failed_count).to eq(1)
      expect(formatter.pending_count).to eq(1)
    end
  end

  context 'when start is called after examples have been processed' do
    it 'resets the counts' do
      formatter.example_passed(notification)
      formatter.example_failed(notification)
      formatter.example_pending(notification)

      expect(formatter.passed_count).to eq(1)
      expect(formatter.failed_count).to eq(1)
      expect(formatter.pending_count).to eq(1)

      start_notification = double('start_notification', count: 10)
      formatter.start(start_notification)

      expect(formatter.passed_count).to eq(0)
      expect(formatter.failed_count).to eq(0)
      expect(formatter.pending_count).to eq(0)
    end
  end
end
