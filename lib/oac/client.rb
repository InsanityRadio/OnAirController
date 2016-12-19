module OAC
	class Client

		attr_reader :socket, :server, :controller

		BLOCK_SIZE = 4096
		EOF = "\n"

		def initialize socket, server
			@socket = socket
			@server = server
			@buffer = ""
			@controller = @server.controller
		end

		def on_data

			begin
				loop do 
					@buffer << @socket.read_nonblock(BLOCK_SIZE)
				end
			rescue Errno::EAGAIN
			rescue EOFError
			end

			responses = []
			if @buffer.include? EOF
				data = @buffer.slice!(0, @buffer.rindex(EOF) + 1).split(EOF, -1)[0..-2]
				data.each { | d | responses << on_message(d) }
			end

			responses

		end

		def on_message
			raise NotImplementedError
		end
		
	end
end