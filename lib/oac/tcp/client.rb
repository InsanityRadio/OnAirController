require 'timeout'
require 'digest'
require 'json'
require 'base64'

module OAC; module TCP
	class Client < OAC::Client

		def initialize socket, server
			super
		end

		def eof?
			["\0"]
		end

		def ident
			json_data = {
				studios: @controller.studios.map { | _, s |
					{
						id: s.id,
						name: s.description,
						networks: s.networks.map { |n| n.id }
					}
				},
				networks: @controller.networks.map { | _, s |
					{
						id: s.id,
						name: s.name,
						description: s.description,
						studio: s.on_air != nil ? s.on_air.id : nil,
						acceptor: s.acceptor != nil ? s.acceptor.id : nil,
						offered: false
					}
				}
			}.to_json
			['hello', json_data]
		end

		def on_open 
			send_nonce
			send_packet *ident
		end

		def send_nonce

			@nonce = SecureRandom.hex(32)

			send_packet "nonce", @nonce

		end

		def send_packet cmd, *args

			packet = "%#{cmd}%#{args.join('%')}%"

			# Yup, our server to client packets can be replayed in this direction. But not in the other. :-)
			packet += Digest::SHA256.hexdigest(packet + secret_key)
			self << (packet + "\0")

		end

		def secret_key
			@studio.config['secret_key']
		end

		def on_message message

			#%nonce%cmd%arg%arg%signature

			begin

				parts = message.split("%")

				signature = parts[-1]
				parts = parts[0..-2]

				calc_nonce = "#{ parts.join("%") }%#{ secret_key }"
				calc_nonce = Digest::SHA256.hexdigest calc_nonce

				raise "Bad nonce" if parts[0] != @nonce
				raise "Bad HMAC" if signature != calc_nonce

				receive_message *parts[1..-1]

			rescue

				p $!
				p $!.backtrace

			end
			
			send_nonce

		end

		def receive_message cmd, *args

			# GIVE CONTROL OF insanity TO studio1
			if cmd == 'ACCEPT'

				studio = @controller.studios[args[0]]
				network = @controller.networks[args[1]]
				raise "Invalid studio" if !studio
				raise "Invalid network" if !network

				dispatch OAC::Client::TakeControlRequest.new, [network], true, studio

			elsif cmd == 'OFFER'

				studio = @controller.studios[args[0]]
				network = @controller.networks[args[1]]
				raise "Invalid studio" if !studio
				raise "Invalid network" if !network

				dispatch OAC::Client::OfferControlRequest.new, [network]

			elsif cmd == 'EXECUTE'

				studio = @controller.studios[args[0]]
				network = @controller.networks[args[1]]
				raise "Invalid studio" if !studio
				raise "Invalid network" if !network

				dispatch OAC::Client::ExecuteControlRequest.new, [network], studio

			elsif cmd == 'TAKE'

				studio = @controller.studios[args[0]]
				network = @controller.networks[args[1]]
				raise "Invalid studio" if !studio
				raise "Invalid network" if !network

				dispatch OAC::Client::TakeControlRequest.new, [network], true, studio
				dispatch OAC::Client::ExecuteControlRequest.new, [network], @studio

			end

		end

		private
		def on_offer_control event, networks
			network_ids = networks.map {|n| n.id}
			send_packet 'OFFER', *network_ids
			#self << "OFFERED CONTROL OF #{network_ids}"
		end

		private
		def on_take_control event, networks, caller, old_acceptor
			network_ids = networks.map {|n| n.id}
			send_packet 'ACCEPT', caller.id, *network_ids
		end

		private
		def on_execute_control event, networks, caller, last_studio
			network_ids = networks.map {|n| n.id}
			send_packet 'EXECUTE', caller.id, *network_ids
		end

		private
		def on_release_control event, networks, caller, studio
			#network_ids = networks.map {|n| n.id}.join(",")
			#self << "#{caller.id} RELEASED CONTROL OF #{network_ids}"
		end
		

	end
end; end