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
  let(:example) { double('example', location: 'spec/example_spec.rb:10', description: 'test example').as_null_object }
  let(:notification) { double('notification', example: example, fully_formatted: 'Failed example output').as_null_object }
  let(:start_notification) { double('start_notification', count: 10) }

  before(:each) do
    formatter.start(start_notification)
    output.rewind
  end

  context 'when handling duplicate failure notifications' do
    it 'only prints the failure output once when example_failed is called multiple times' do
      # Call example_failed multiple times with the same notification
      3.times { formatter.example_failed(notification) }

      output.rewind
      output_content = output.read

      # Should only contain the failure output once
      expect(output_content.scan('Failed example output').count).to eq(1)
    end

    it 'still increments the failed count for duplicate notifications' do
      # Call example_failed multiple times
      3.times { formatter.example_failed(notification) }

      # Failed count should still be 3
      expect(formatter.failed_count).to eq(3)
    end

    it 'prints different failures separately' do
      example1 = double('example1', location: 'spec/example_spec.rb:10', description: 'first test').as_null_object
      example2 = double('example2', location: 'spec/example_spec.rb:20', description: 'second test').as_null_object
      notification1 = double('notification1', example: example1, fully_formatted: 'First failure').as_null_object
      notification2 = double('notification2', example: example2, fully_formatted: 'Second failure').as_null_object

      formatter.example_failed(notification1)
      formatter.example_failed(notification2)

      output.rewind
      output_content = output.read

      expect(output_content).to include('First failure')
      expect(output_content).to include('Second failure')
    end

    it 'handles mixed duplicate and unique failures correctly' do
      example1 = double('example1', location: 'spec/example_spec.rb:10', description: 'first test').as_null_object
      example2 = double('example2', location: 'spec/example_spec.rb:20', description: 'second test').as_null_object
      notification1 = double('notification1', example: example1, fully_formatted: 'First failure').as_null_object
      notification2 = double('notification2', example: example2, fully_formatted: 'Second failure').as_null_object

      # Call with mixed duplicates
      formatter.example_failed(notification1)
      formatter.example_failed(notification1)  # duplicate
      formatter.example_failed(notification2)
      formatter.example_failed(notification1)  # duplicate
      formatter.example_failed(notification2)  # duplicate

      output.rewind
      output_content = output.read

      # Each unique failure should appear only once
      expect(output_content.scan('First failure').count).to eq(1)
      expect(output_content.scan('Second failure').count).to eq(1)

      # But failed count should reflect all calls
      expect(formatter.failed_count).to eq(5)
    end

    it 'resets printed examples when start is called again' do
      # First run
      formatter.example_failed(notification)

      output.rewind
      first_run_output = output.read

      # Start again (simulating a new test run)
      formatter.start(start_notification)
      output.rewind

      # Same failure in second run should be printed again
      formatter.example_failed(notification)

      output.rewind
      second_run_output = output.read

      # Should contain the failure output (not empty)
      expect(second_run_output).to include('Failed example output')
    end
  end
end
