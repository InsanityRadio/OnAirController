module OAC; module TCP
	class Client < OAC::Client

		def initialize socket, server
			super
		end

		def eof?
			["\n"]
		end

		def ident
			'THIS IS SOME BASIC PROTO'
		end

		def on_open 
			self << ident
		end

		def on_message message

			message = message.strip

			# GIVE CONTROL OF insanity TO studio1
			if message[0..15] == 'GIVE CONTROL OF '

				network_name, studio_id = message[16..-1].split(" TO ")

				@studio = @controller.studios[studio_id]
				dispatch OAC::Client::TakeControlRequest.new, [@server.network], true, @studio

			elsif message[0..6] == 'EXECUTE'

				dispatch OAC::Client::ExecuteControlRequest.new, [@server.network], @server.network.acceptor

			end

		end

	end
end; end