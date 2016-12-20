require 'spec_helper'
require 'socket'
require 'oac'

class DummyClass

	include OAC::Helper::Dispatch

end

describe OAC::Helper::Dispatch do

	before do
		@alice = DummyClass.new
		@bob = DummyClass.new
	end

	after do
		@client = @parent = nil
	end

	describe ".add_listener" do
		context "when passed a block" do
			it "registers it as a listener" do

				block = proc { puts 1 }
				@alice.add_listener &block
				expect(@alice.listeners.include? [nil, block] ).to eq(true)

			end
		end

		context "when passed an event and a block" do
			it "registers it as a listener" do

				event = OAC::Event
				block = proc { puts 1 }
				@alice.add_listener event, &block
				expect(@alice.listeners.include? [OAC::Event, block] ).to eq(true)

			end
		end

		context "when passed garbage" do 
			it "rejects it" do 
				expect { @alice.add_listener 1234 }.to raise_error
			end
		end

		context "when passed a non-event" do 
			it "rejects it" do 
				expect { @alice.add_listener(String) {} }.to raise_error(OAC::Error::InvalidEventError)
			end
		end

	end

	describe ".dispatch" do 
		context "when given an event" do 
			it "calls all relevant listeners" do 

				remain = rand(5) + 2
				remain2 = rand(5) + 2
				remain3 = 0

				block = proc { remain = remain - 1 }
				block2 = proc { remain2 = remain2 - 1 }
				block3 = proc { remain3 = remain3 - 1}

				(1..remain).each { @alice.add_listener &block }
				(1..remain2).each { @alice.add_listener OAC::Event, &block2 }
				(1..5).each { @alice.add_listener OAC::Event::OffAir, &block3 }

				@alice.dispatch OAC::Event.new, 1

				expect(remain).to eq(0)
				expect(remain2).to eq(0)
				expect(remain3).to eq(0)

			end

			it "calls listeners with inheritance" do

				called = false
				block = proc { called = true }

				@alice.add_listener OAC::Event::ControlEvent, &block
				@alice.dispatch OAC::Event::OnAir.new, self

				expect(called).to eq(true)

			end

			it "calls listeners with the correct data" do 

				called = [false, false]
				data = [OAC::Event.new, "Another Test", 1234, rand(9999), self]
				block = proc { |*args| called[0] = (args == data) }
				block2 = proc { |*args| called[1] = (args == data) }

				@alice.add_listener &block
				@alice.add_listener OAC::Event, &block2

				@alice.dispatch *data # Squash it 

				expect(called[0]).to eq(true)
				expect(called[1]).to eq(true)

			end
		end
	end

end