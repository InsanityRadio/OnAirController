module OAC
	class Client

		autoload :Disconnect, 'oac/client/disconnect'
		autoload :Disconnected, 'oac/client/disconnected'

		autoload :Request, 'oac/client/request'
		autoload :OfferControlRequest, 'oac/client/offer_control_request'
		autoload :TakeControlRequest, 'oac/client/take_control_request'
		autoload :ExecuteControlRequest, 'oac/client/execute_control_request'
		autoload :ReleaseControlRequest, 'oac/client/release_control_request'

		include OAC::Helper::Dispatch

		attr_reader :networks, :socket, :server, :controller
		attr_accessor :id, :studio, :autokill

		@@BLOCK_SIZE = 4096

		def initialize socket, server

			@id = nil
			@metadata = nil
			@socket = socket
			@server = server
			@buffer = ""
			@controller = @server.controller
			@networks = []

			@studio = nil

			@controller.add_listener OAC::Event::OfferControl, &method(:on_offer_control) if @controller
			@controller.add_listener OAC::Event::TakeControl, &method(:on_take_control) if @controller
			@controller.add_listener OAC::Event::ExecuteControl, &method(:on_execute_control) if @controller
			@controller.add_listener OAC::Event::OffAir, &method(:on_release_control) if @controller

		end

		def eof?
			["\n"]
		end

		def config
			@studio.config
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

			begin
				eof?.each do | eof |
					if @buffer.include? eof
						data = @buffer.slice!(0, @buffer.rindex(eof) + 1).split(eof, -1)[0..-2]
						data.each { | d | responses << handle_message(d) }
					end
				end
			rescue
				puts "There was an error handling a packet from #{self}"
				p $!
				p $!.backtrace
			end

			responses

		end

		def send message
			print  "[S] "
			p message
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

		def handle_message message
			print  "[R] "
			p message
			on_message message
		end

		def on_message
			raise NotImplementedError
		end

		def on_disconnect
			@socket.close rescue nil

			@studio.clients.delete self  if @studio

			dispatch OAC::Client::Disconnect.new, self
		end

		def offer_control networks, force = false 
			valid_networks = networks.select { | n | n.acceptor.id == self.studio.id }
			raise "Permission Denied" if networks.length != valid_networks.length and !force

			dispatch OAC::Client::OfferControlRequest.new, networks, force, self
		end

		def take_control networks, force = false
			raise "NoStudio" if !@studio
			@studio.clients << self 
			dispatch OAC::Client::TakeControlRequest.new, networks, force, self
		end

		def execute_control networks, force = false
			raise "NoStudio" if !@studio
			@studio.clients << self 
			dispatch OAC::Client::ExecuteControlRequest.new, networks, force, self
		end

		# network = nil  ==>  release control from all networks
		def release_control networks, force = false
			raise "NoStudio" if !@studio
			@studio.clients.delete self 
			dispatch OAC::Client::ReleaseControlRequest.new, networks, force, self
		end

		def song_change metadata
			@metadata = metadata
			@current_reference = metadata[:current_reference]
			dispatch OAC::Event::SongChange.new, metadata, @studio
		end


		private
		def on_offer_control event, networks
		end

		private
		def on_take_control event, networks, caller, old_acceptor
		end

		private
		def on_execute_control event, networks, caller, last_studio
		end

		private
		def on_release_control event, networks, caller, studio
		end
		
	end
end