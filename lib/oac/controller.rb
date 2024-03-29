module OAC
	class Controller

		include OAC::Helper::Dispatch

		attr_reader :networks, :clients, :factory, :studios, :config

		def initialize config

			@config = config
			@clients = {}
			@networks = {}
			@studios = {}
			@factory = ServerFactory.new self

			@ips = {}

			load_studios
			load_networks
			load_controllers

		end

		def exit
			@factory.close
		end

		def on_offer_control_request event, networks = []

			networks = [networks] if networks.is_a? OAC::Network
			networks.select do | network |
				network.offer_control
				true
			end

		end

		def on_take_control_request event, networks = [], force, client

			studio = client.is_a?(OAC::Client) ? client.studio : client

			networks = [networks] if networks.is_a? OAC::Network
			networks.select do | network |
				if !network.should_take_control(studio, force)
					next false 
				end
				network.take_control studio
				true
			end

		end

		def on_execute_control_request event, networks = [], client

			studio = client.is_a?(OAC::Client) ? client.studio : client
			networks = [networks] if networks.is_a? OAC::Network

			networks.select do | network |
				next false if network.acceptor != studio
				network.execute_control studio
				true
			end

		end

		def on_release_control_request event, networks = [], force, client_or_studio

			networks = [networks] if networks.is_a? OAC::Network

			# Return the networks as an array
			networks = @networks.map { | a, b | b } if networks == nil

			networks.select do | network |
				next false unless network.should_release_control(client_or_studio, force)
				network.release_control client_or_studio
				true
			end

		end

		# Bubble control events up
		def on_control_event *args
			dispatch *args
		end

		def on_meta_event *args
			dispatch *args
		end

		def on_disconnect event, client
			@clients[client.id] = OAC::Client::Disconnected
			client.studio.clients.delete(client) if client.studio
		end

		def register_network network 
			register network
			@networks << network
		end

		def register_client client

			ip = client.ip

			id = ip_to_id ip

			return client.disconnect if id == nil
			client.id = id

			studio = @studios[id]
			raise "Studio does not exist" if !studio

			client.studio = studio

			client.on_open
			listen_to client

			# Clean up the previous person with this client slot

		end

		def run!
			@factory.run!
		end

		private

		def load_networks
			raise OAC::Error::ConfigError unless @config.get("networks").is_a? Array

			@config.get("networks").each do | settings |

				network = OAC::Network.new(settings, self)
				id = settings["name"]
				@networks[id] = network
				listen_to network

			end
		end

		def load_studios
			raise OAC::Error::ConfigError unless @config.get("studios").is_a? Array

			@config.get("studios").each do | studio |
				
				id = studio["name"]
				@clients[id] = OAC::Client::Disconnected

				[studio["ip"]].flatten.each do | ip |
					raise OAC::Error::ConfigError, "Playout systems sharing IP" if !@ips[id].nil?
					@ips[ip] = id
				end

				studio = OAC::Studio.new studio
				@studios[id] = studio

			end
		end

		def load_controllers
			raise OAC::Error::ConfigError unless @config.get("controllers").is_a? Array

			@config.get("controllers").each do | controller |

				type = Object.const_get(controller["type"])::Server
				server = @factory.create_server(type, controller["port"], controller["host"], controller)

				# Some interfaces only support one network each
				server.network = @networks[controller["network"]] if controller["network"]

			end
		end

		def listen_to object

			#raise "Object must use OAC::Helper::Dispatch" \
			#	unless object.class.included_modules.include? OAC::Helper::Dispatch

			object.add_listener OAC::Client::Disconnect, &method(:on_disconnect)
			object.add_listener OAC::Client::OfferControlRequest, &method(:on_offer_control_request)
			object.add_listener OAC::Client::TakeControlRequest, &method(:on_take_control_request)
			object.add_listener OAC::Client::ExecuteControlRequest, &method(:on_execute_control_request)
			object.add_listener OAC::Client::ReleaseControlRequest, &method(:on_release_control_request)

			object.add_listener OAC::Event::ControlEvent, &method(:on_control_event)
			object.add_listener OAC::Event::MetaEvent, &method(:on_meta_event)

		end

		def ip_to_id ip

			# We only support one IP per playout system. Splits are out of our scope currently
			@ips[ip]

		end


	end
end
