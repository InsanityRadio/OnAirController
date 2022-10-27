module OAC
	module Switch
		class DummySwitch

			def initialize config, network

				@config = config
				@network = network
				@network.add_listener(OAC::Event::ExecuteControl) { | event, networks, studio, previous | switch_control_safe studio, previous }

			end

			def switch_control studio, previous

				p "SWITCHING CONTROL TO #{studio.id} (FROM #{previous})"

			end

			def switch_control_safe studio, previous

				Thread.new do
					begin
						switch_control studio, previous
					rescue
						puts "!!!!!!!"
						puts "FAILED TO SWITCH #{self}"
						p $!
						p $!.backtrace
						puts "!!!!!!!"
					end
				end

			end

		end
	end
end
