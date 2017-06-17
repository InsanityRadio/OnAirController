module OAC
	module Switch
		class DummySwitch

			def initialize config, network

				@config = config
				@network = network
				@network.add_listener(OAC::Event::ControlEvent) { | event, networks, client | switch_control client }

			end

			def switch_control client

				p "SWITCHING CONTROL TO #{client.id}"

			end

		end
	end
end