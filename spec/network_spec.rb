require 'securerandom'
require 'spec_helper'
require 'socket'
require 'oac'

module Fake
	class Client < OAC::Client
		attr_accessor :studio
		def initialize studio = Fake::Studio.new
			@id = "FakeClient"
			@studio = studio
		end
	end
	class Studio < OAC::Studio
		def initialize
			@id = "FakeStudio"
		end
	end
end
describe OAC::Network do

	describe ".initialize" do 
		context "when initializing a Network" do 
			name = SecureRandom.hex
			description = SecureRandom.hex
			callsign = SecureRandom.hex
			tc = ["always", "none"].sample
			rc = ["always", "none"].sample

			network = OAC::Network.new ({
				"name" => name, "description" => description, "callsign" => callsign, 
				"take_control" => tc, "release_control" => rc })

			it "fills the variables" do
				expect(network.name).to be(name)
				expect(network.description).to be(description)
				expect(network.callsign).to be(callsign)
				expect(network.take_control_type).to be(tc.to_sym)
				expect(network.release_control_type).to be(rc.to_sym)
			end
		end
	end

	describe ".should_take_control" do

		context "when called" do
			it "returns an appropriate value" do 

				s = Fake::Studio.new 
				c = Fake::Client.new(s)
				networks = []
				networks << OAC::Network.new({ "take_control" => "always", "release_control" => "always" })
				networks << OAC::Network.new({ "take_control" => "none", "release_control" => "always" })
				networks << OAC::Network.new({ "take_control" => "force", "release_control" => "always" })

				networks[2].instance_variable_set("@on_air", c)

				expect( networks[0].should_take_control(c, false) ).to be true
				expect( networks[1].should_take_control(c, true) ).to be false
				expect( networks[1].should_take_control(c, false) ).to be false
				expect( networks[2].should_take_control(c, false) ).to be false
				expect( networks[2].should_take_control(c, true) ).to be true

			end
		end


	end

	describe ".should_release_control" do
		OAC::Network.new({ "take_control" => "always", "release_control" => "always" }).
			should_release_control nil
	end

	describe ".take_control" do
		it "should dispatch an event" do
			c = Fake::Client.new Fake::Studio.new
			called = false

			network = OAC::Network.new({ "take_control" => "always", "release_control" => "none"})
			network.add_listener OAC::Event::OnAir, & proc { called = true}
			network.take_control c

			expect(network.on_air).to eq(c)
			expect(called).to eq(true)
		end
		it "should call the switch method" do
			c = Fake::Client.new Fake::Studio.new
			called = false

			network = OAC::Network.new({ "take_control" => "always", "release_control" => "none", "switch" => [{ "type" => "OAC::Switch::DummySwitch" }]})
			network.add_listener OAC::Event::OnAir, & proc { called = true}
			network.take_control c

			expect(network.on_air).to eq(c)
			expect(called).to eq(true)
		end
	end

	describe ".release_control" do
		context "when client isn't in control" do
			it "does nothing" do
				c = Fake::Client.new Fake::Studio.new
				network = OAC::Network.new({ "take_control" => "always", "release_control" => "none"})
				expect(network.release_control c).to eq(false)
			end
		end
		context "when client is in control" do
			c = Fake::Client.new Fake::Studio.new
			network = OAC::Network.new({ "take_control" => "always", "release_control" => "none"})
			network.take_control c

			it "should dispatch an event" do
				called = false

				network.add_listener OAC::Event::OffAir, & proc { called = true}
				network.release_control c

				expect(network.on_air).to eq(nil)
				expect(called).to eq(true)
			end
		end
	end


end
