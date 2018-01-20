module OAC
	class Studio

		include OAC::Helper::Dispatch

		attr_reader :networks, :socket, :server, :controller
		attr_accessor :id, :config, :clients

		def initialize config

			@config = config
			@id = config['name']
			@networks = []

			# Keeps track of client connections FROM THE STUDIO. 
			# Theoretically, we should have one - this indicates playout is OK/taking to us
			@clients = []

		end

		def on_take_control event, networks, caller, last_studio

			network_names = networks.map { |n| n.id }
			puts "#{@id} is taking control of #{network_names}"

		end

		def on_execute_control event, networks, caller, last_studio

			network_names = networks.map { |n| n.id }
			puts "#{@id} is executing control of #{network_names}"

			@networks |= networks

		end

		def on_release_control event, networks, caller

			network_names = networks.map { |n| n.id }
			puts "#{@id} is releasing control of #{network_names}"

		end

		def on_release_network event, networks, caller

			network_names = networks.map { |n| n.id }
			puts "#{@id} is releasing audio of #{network_names}"

			@networks -= networks

		end

		def on_air? network = nil 
			network ? @networks.include?(network) : @networks.length > 0
		end

		def active_connection?
			@clients.length > 0
		end

	end
end