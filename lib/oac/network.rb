module OAC
	class Network

		include OAC::Helper::Dispatch

		attr_reader :id, :name, :description, :callsign, :on_air

		def initialize params = {}

			@id = @name = params["name"]
			@description = params["description"]
			@callsign = params["callsign"]
			@take_control_type = params["take_control"].to_sym
			@release_control_type = params["release_control"].to_sym

			@on_air = nil

		end

		def should_take_control client, force = false
			case @take_control_type
				when :none
					return false

				when :force
					return @on_air == nil || force

				when :always
					return true

				else
					raise OAC::Error::ConfigError, "Unrecognised control type #{@take_control_type}"
			end
		end

		def should_release_control client, force = false
			case @release_control_type
				when :none
					return force

				when :always
					return true

				else
					raise OAC::Error::ConfigError, "Unrecognised control type #{@crelease_ontrol_type}"
			end
		end

		def take_control client
			@on_air = client
			dispatch OAC::Event::OnAir.new, [self], client
			true
		end

		# release_control technically takes the network off air. 
		def release_control client
			puts "releasing"
			return false unless @on_air == client
			@on_air = nil 
			dispatch OAC::Event::OffAir.new, [self], client
			true
		end

	end
end