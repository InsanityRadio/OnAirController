module OAC; module OCP
	class Server < OAC::Server

		@network = nil
		attr_accessor :network
		
		CLIENT = OAC::OCP::Client

		def forward message
			return unless @config['forward']

			tries = 0

			begin
				puts "a"
				raise "Not connected" unless @client
				raise "Reconnect required" if message[0] == '+' and tries == 0

				puts "sending to client " + message
				@client << message + "\r\n"
			rescue
				p "got error forwarding"
				p $!
				tries += 1
				begin
					@client = TCPSocket.new @config['forward']['host'], @config['forward']['port']
					@client << "+Connected AppName=\"BroadcastRadio.Common5\" Version=\"5.5.20164\""
				rescue
					puts "Got an error connecting " 
					p $!
					
				end
				puts "lets retry?"
				retry unless tries > 5
			end
		end

	end
end; end
