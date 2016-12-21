module OAC
	class Client

		autoload :Disconnect, 'oac/client/disconnect'
		autoload :Disconnected, 'oac/client/disconnected'

		autoload :Request, 'oac/client/request'
		autoload :TakeControlRequest, 'oac/client/take_control_request'
		autoload :ReleaseControlRequest, 'oac/client/release_control_request'

		include OAC::Helper::Dispatch

		attr_reader :networks, :socket, :server, :controller
		attr_accessor :id

		@@BLOCK_SIZE = 4096

		def initialize socket, server

			@id = nil
			@metadata = nil
			@socket = socket
			@server = server
			@buffer = ""
			@controller = @server.controller
			@networks = []

			@controller.add_listener OAC::Event::OnAir, &method(:on_take_control) if @controller
			@controller.add_listener OAC::Event::OffAir, &method(:on_release_control) if @controller

		end

		def eof?
			["\n"]
		end

		def ip
			Socket.unpack_sockaddr_in(@socket.getpeername)[1]
		end

		def on_data

			begin
				loop do 
					@buffer << @socket.read_nonblock(@@BLOCK_SIZE)
				end
			rescue Errno::EAGAIN
			rescue EOFError
			end

			responses = []
			eof?.each do | eof |
				if @buffer.include? eof
					data = @buffer.slice!(0, @buffer.rindex(eof) + 1).split(eof, -1)[0..-2]
					data.each { | d | responses << on_message(d) }
				end
			end

			responses

		end

		def send message
			@socket << message + eof?.first rescue nil
		end

		def disconnect
			# We can't call socket.close, it causes issues.
			@server.on_remove_client self.socket
		end

		def << message
			send message
		end

		def on_open
			raise NotImplementedError
		end

		def on_message
			raise NotImplementedError
		end

		def on_disconnect
			@socket.close rescue nil
			release_control nil, true
			dispatch OAC::Client::Disconnect.new, self
		end

		def take_control networks, force = false
			dispatch OAC::Client::TakeControlRequest.new, networks, force, self
		end

		# network = nil  ==>  release control from all networks
		def release_control networks, force = false
			dispatch OAC::Client::ReleaseControlRequest.new, networks, force, self
		end

		def song_change metadata
			@metadata = metadata
			@current_reference = metadata.[:current_reference]
			dispatch OAC::Event::SongChange.new, metadata, self
		end


		private
		def on_take_control event, networks, caller
			@networks |= networks
		end

		private
		def on_release_control event, networks, caller
			@networks -= networks
		end
		
	end
end