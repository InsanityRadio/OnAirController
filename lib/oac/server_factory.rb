module OAC
	class ServerFactory

		attr_reader :servers, :sockets, :clients, :controller
		def initialize controller = nil
			@controller = controller
			@servers = []
			@clients = []
			@sockets = []
		end

		def create_server type, port, host = "127.0.0.1"

			server = type.new(@controller)

			server.changed { changed }
			server.listen port, host

			@servers << server
			changed
			server

		end

		def close 

			@servers.each { | s | begin; s.close; rescue OAC::Exceptions::NoServer; end }
			@servers = []

		end

		def changed

			@clients = @servers.map { | s | s.clients }.flatten
			@sockets = @servers.map { | s | s.sockets }.flatten

			@server_sockets = @servers.map { | s | s.socket }

		end

		def select_changed
			begin
				changed = select(@sockets, nil, nil, 1)
			rescue IOError
				# Dirty socket closure.
				changed
				retry
			end
		end

		def pump

			changed = select_changed
			return if !changed or !changed[0] or !changed[0].kind_of?(Array)
			changed = changed[0]

			changed.each do | socket |
				begin
					if @server_sockets.include? socket
						server = @servers.select { |s| s.socket == socket }[0]
						client = server.accept
						@controller.register_client(client) if @controller
						yield client if block_given?

					elsif socket.eof?
						client = @clients.select { |s| s.socket == socket }[0]
						client.server.on_remove_client socket
					else
						client = @clients.select { |s| s.socket == socket }[0]
						server = client.server
						client.on_data
					end
				rescue
					puts "Socket error!"
					socket.close rescue nil
					p $!
				end
			end

		end

		def run!

			$threads << Thread.new { loop { pump } }

		end

	end
end