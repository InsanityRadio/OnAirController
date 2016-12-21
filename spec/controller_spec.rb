require 'spec_helper'
require 'oac'

# Some random configuration (it's the same as the one we had before)
CONFIG_STUDIOS = <<end
studios:
  - name: STUDIO-69
    description: My Studio
    ip: 
        - 127.0.0.1
    type: Fake
    networks:
        insanity: 1

end

CONFIG_CONTROLLERS = <<end
controllers:
controllers:
  - type: Fake
    network: radio1
    host: 127.0.0.1
    port: 6901

end

CONFIG_NETWORKS = <<end
networks:
  - name: radio1
    description: Radio 1
    take_control: always
    release_control: always

end

module Fake
	class Server < OAC::Server
		attr_accessor :network
	end
	class MultiNetServer < OAC::Server
		attr_accessor :networks
	end
	class Client < OAC::Client
		def initialize
			@id = "FakeClient"
		end

	end
end

describe OAC::Controller do

	config = OAC::Config.parse_yaml CONFIG_STUDIOS + CONFIG_CONTROLLERS + CONFIG_NETWORKS

	before do
		@controller = OAC::Controller.new config
		yes = @controller.networks['yes'] = instance_double("Fake::Network")
		allow(yes).to receive(:id).and_return "YesNetwork"
		allow(yes).to receive(:should_take_control).and_return true

		no = @controller.networks['no'] = instance_double("Fake::Network")
		allow(no).to receive(:id).and_return "NoNetwork"
		allow(no).to receive(:should_take_control).and_return false

	end

	after do 
		@controller.exit
	end

	describe ".initialize" do 
		context "when the config is ok" do
			it "creates the networks we want" do 
				# we're fucking with it.
				#expect( @controller.networks.length ).to be(1)
				expect( @controller.networks["radio1"].id ).to eq("radio1")
				expect( @controller.networks["radio1"].description ).to eq("Radio 1")
			end
		end

		context "when the config is missing a section" do
			c = [
				OAC::Config.parse_yaml(CONFIG_STUDIOS),
				OAC::Config.parse_yaml(CONFIG_STUDIOS + CONFIG_CONTROLLERS),
				OAC::Config.parse_yaml(CONFIG_NETWORKS + CONFIG_CONTROLLERS)]

			it "fails horrendously" do 
				expect { OAC::Controller.new c[0] }.to raise_error(OAC::Error::ConfigError)
				expect { OAC::Controller.new c[1] }.to raise_error(OAC::Error::ConfigError)
				expect { OAC::Controller.new c[2] }.to raise_error(OAC::Error::ConfigError)
			end
		end
	end

	it "implements Dispatch" do 
		expect( OAC::Controller.included_modules ).to include OAC::Helper::Dispatch
	end

	describe ".on_take_control_request" do

		context "when the parameters are ok" do
			it "checks if it can take control" do
				c = Fake::Client.new
				allow(@controller.networks['yes']).to receive(:take_control)
				expect(@controller.networks['yes']).to receive(:id)
				expect(@controller.networks['yes']).to receive(:should_take_control).with(c, false)

				@controller.on_take_control_request nil, [@controller.networks['yes']], false, c
			end
		end

		context "when it can take control" do 
			it "f--kin' does, and returns the network(s)" do
				c = Fake::Client.new
				expect(@controller.networks['yes']).to receive(:take_control)

				r = @controller.on_take_control_request nil, [@controller.networks['yes']], false, c

				expect(r.length).to be 1
				expect(r[0]).to eq @controller.networks['yes']
			end
		end

		context "when it can't take control" do
			it "does and returns nothing" do
				c = Fake::Client.new
				r = @controller.on_take_control_request nil, [@controller.networks['no']], false, c
				expect(r.length).to be 0
			end
		end
	end

	describe ".ip_to_id" do 
		it "returns the first IP" do 
			expect( @controller.instance_eval { ip_to_id "127.0.0.1" } ).to eq("STUDIO-69")
		end
	end

	describe ".register_client" do 
		context "when passed a client with the wrong IP" do 
			it "disconnects them" do 
				c = instance_double("Fake::Client")
				allow(c).to receive(:ip).and_return("0.0.0.0")
				expect(c).to receive(:disconnect)

				@controller.register_client c
			end
		end
		context "when passed a client with a matching IP" do
			it "registers them" do
				c = instance_double("Fake::Client")

				allow(c).to receive(:ip).and_return("127.0.0.1")
				allow(c).to receive(:on_open)
				allow(c).to receive(:add_listener)
				allow(c).to receive(:id).and_return("STUDIO-69")

				expect(c).to receive(:id=).with("STUDIO-69")


				@controller.register_client c
			end
		end

	end



end
