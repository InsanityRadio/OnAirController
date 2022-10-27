require 'em-websocket'

module OAC; module WebSocket
	class Server < OAC::Server

		@network = nil

		attr_reader :clients, :socket, :controller
		attr_accessor :network 

		CLIENT = WebSocket::Client

		def create_server host, port, &block

			EM::WebSocket.run(:host => host, :port => port) do | conn |

				client = nil

				conn.onopen { | handshake |
					client = self.on_new_client(conn)
					@controller.register_client(client) if @controller
				}

				conn.onclose { 
					on_remove_client(conn)
				}

				conn.onmessage { | message |
					client.buffer << message
					client.on_data
				}

			end

		end

	end
end; end