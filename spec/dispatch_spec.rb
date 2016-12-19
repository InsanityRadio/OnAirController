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

	describe ".listen" do
		context "when passed a block" do
			it "registers it as a listener" do

				block = proc { puts 1 }
				@alice.listen &block
				expect(@alice.listeners.include? block ).to eq(true)

			end
		end

		context "when passed garbage" do 
			it "rejects it" do 
				expect { @alice.listen 1234 }.to raise_error
			end
		end

	end

	describe ".dispatch" do 
		context "when given an event" do 
			it "calls all listeners" do 

				remain = rand(5) + 2
				block = proc { remain = remain - 1 }

				(1..remain).each { @alice.listen &block }

				@alice.dispatch 1

				expect(remain).to eq(0)

			end
			it "calls listeners with the correct data" do 

				called = false
				data = ["Test", "Another Test", 1234, rand(9999)]
				block = proc { |*args| called = (args == data) }

				@alice.listen &block
				@alice.dispatch *data # Squash it 

				expect(called).to eq(true)

			end
		end
	end

end