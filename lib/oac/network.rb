module OAC
	class Network

		include OAC::Helper::Dispatch

		attr_reader :id, :name, :description, :callsign, :on_air
		attr_reader :take_control_type, :release_control_type

		def initialize params = {}

			@id = @name = params["name"]
			@description = params["description"]
			@callsign = params["callsign"]
			@take_control_type = params["take_control"].to_sym
			@release_control_type = params["release_control"].to_sym

			@switches = []

			if params["switch"]
				params["switch"].each do | switch |
					@switches << Object.const_get(switch["type"]).new(switch, self)
				end
			end

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

			# Don't allow just anyone to send a release control request
			return false if @on_air != client

			case @release_control_type
				when :none
					return force

				when :always
					return true

				else
					raise OAC::Error::ConfigError, "Unrecognised control type #{@release_control_type}"
			end
		end

		def take_control client
			last_studio = @on_air

			studio = client.is_a?(OAC::Client) ? client.studio : client
			@on_air = studio

			unless @switching
				dispatch OAC::Event::OnAir.new, [self], studio, last_studio
			end

			last_studio.on_release_control nil, [self], nil if last_studio != nil
			studio.on_take_control nil, [self], nil, nil

			true
		end

		# release_control technically takes the network off air. 
		def release_control client

			studio = client.is_a?(OAC::Client) ? client.studio : client

			return false unless @on_air == studio

			puts "Releasing network control - off air? "
			last_studio = @on_air
			@on_air = nil 

			dispatch OAC::Event::OffAir.new, [self], studio

			true
		end

		def start_switch
			@switching = true
		end

		def end_switch
			@switching = false
		end

	end
end