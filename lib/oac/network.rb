module OAC
	class Network

		include OAC::Helper::Dispatch

		attr_reader :id, :name, :description, :callsign, :acceptor, :on_air
		attr_reader :take_control_type, :release_control_type

		def initialize params = {}, controller

			@id = @name = params["name"]
			@description = params["description"]
			@callsign = params["callsign"]
			@take_control_type = params["take_control"].to_sym
			@release_control_type = params["release_control"].to_sym

			@config = controller.config

			@switches = []

			if params["switch"]
				params["switch"].each do | switch |
					@switches << Object.const_get(switch["type"]).new(switch, self)
				end
			end

			#@acceptor = nil
			#@on_air = nil
			@acceptor = @on_air = controller.studios[@config.get_temp("network-#{@id}-last", params["default"])]

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

		# Take control of network
		def take_control studio

			old_acceptor = @acceptor
			@acceptor = studio

			dispatch OAC::Event::TakeControl.new, [self], studio, old_acceptor

			old_acceptor.on_release_control nil, [self], nil if old_acceptor != nil
			studio.on_take_control nil, [self], nil, nil

		end

		# Switch network 
		def execute_control studio

			return unless studio == @acceptor

			last_studio = @on_air
			@on_air = studio

			dispatch OAC::Event::ExecuteControl.new, [self], studio, last_studio

			last_studio.on_release_network nil, [self], nil if last_studio != nil
			studio.on_execute_control nil, [self], nil, nil

			@config.set_temp "network-#{@id}-last", studio.id

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