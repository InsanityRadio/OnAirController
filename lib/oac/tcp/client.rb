module OAC; module TCP
	class Client < OAC::Client

		def initialize socket, server
			super
		end

		def eof?
			["\n"]
		end

		def ident
			'WOW SUCH PROTOCOL MANY PACKETS'
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

			elsif message[0..4] == 'OFFER'

				dispatch OAC::Client::OfferControlRequest.new, [@server.network]

			elsif message[0..6] == 'EXECUTE'

				dispatch OAC::Client::ExecuteControlRequest.new, [@server.network], @server.network.acceptor

			end

		end

		private
		def on_offer_control event, networks
			network_ids = networks.map {|n| n.id}.join(",")
			self << "OFFERED CONTROL OF #{network_ids}"
		end

		private
		def on_take_control event, networks, caller, old_acceptor
			network_ids = networks.map {|n| n.id}.join(",")
			self << "#{caller.id} ACCEPTED CONTROL OF #{network_ids}"
		end

		private
		def on_execute_control event, networks, caller, last_studio
			network_ids = networks.map {|n| n.id}.join(",")
			self << "#{caller.id} EXECUTED CONTROL OF #{network_ids}"
		end

		private
		def on_release_control event, networks, caller, studio
			#network_ids = networks.map {|n| n.id}.join(",")
			#self << "#{caller.id} RELEASED CONTROL OF #{network_ids}"
		end
		

	end
end; end