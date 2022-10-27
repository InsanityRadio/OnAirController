require 'socket'

module OAC
	class Server

		module ServerShim

			attr_accessor :client, :server
			def receive_data data 
				@client.buffer << data
				begin
					@client.on_data
				rescue
					pp $!
					pp $!.backtrace
				end
			end

			def unbind
				@server.on_remove_client(self)
			end

		end

		attr_reader :clients, :socket, :controller, :config

		CLIENT = OAC::Client

		def create_server host, port, &block

			shim = ServerShim.clone

			EventMachine::start_server(host, port, shim) do | conn |
				conn.server = self
				client = self.on_new_client(conn)
				@controller.register_client(client) if @controller
				conn.client = client
			end

		end

		def initialize controller = nil, config = nil 
			@clients = []
			@changed = lambda { }
			@controller = controller
			@config = config
		end

		def close
		end

		def on_new_client socket
			@clients << (client = self.class::CLIENT.new(socket, self))
			@changed.call
			client
		end

		def on_remove_client socket
			d, @clients = @clients.partition { | c | c.socket == socket }
			d.map(&:on_disconnect)

			@changed.call
		end

	end

end