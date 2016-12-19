require 'socket'

module OAC
	class Server

		attr_reader :clients, :socket, :controller

		CLIENT = OAC::Client
		BLOCK_SIZE = 4096
		EOF = "\n"

		def initialize controller = nil
			@socket = nil
			@clients = []
			@changed = lambda { }
			@controller = controller
		end

		def listen port, host = "127.0.0.1"
			raise "I'm already listening" if @socket
			begin
				@socket = TCPServer.new host, port
			rescue
				raise OAC::Exceptions::BindError, $!.to_s
			end
			@changed.call
		end

		def sockets
			@clients.map { | c | c.socket } + [@socket]
		end

		def close
			raise OAC::Exceptions::NoServer unless @socket
			@socket.close
		end

		def accept
			on_new_client @socket.accept
		end

		def changed &block
			@changed = block
		end

		def on_new_client socket
			@clients << (client = CLIENT.new(socket, self))
			@changed.call
			client
		end

		def on_remove_client socket
			client = @clients.delete { | c | c.socket == socket }
			@changed.call
			client
		end

	end

end