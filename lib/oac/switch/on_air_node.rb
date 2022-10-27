require 'timeout'
require 'digest'

module OAC
	module Switch
		class OnAirNode < DummySwitch

			def initialize config, network

				super

			end

			def switch_control client, previous 

				puts "hello"
				puts client.id
				id = @config['inputs'].key client.id

				raise "Invalid ID" if id == nil

				send_packet "sw", id

			end

			def send_packet type, arg

				e = nil
				(0..5).each do
					begin
						timeout(5) do 
							socket = TCPSocket.new @config['host'], @config['port']

							nonce = socket.gets("\0").split("%")[0]
							message = "#{nonce}%#{type}%#{arg}%"

							message += Digest::SHA256.hexdigest "#{message}#{@config['secret_key']}"
							message += "\0"

							socket << message

							sleep 0.01
							socket.close
						end
						return
					rescue

						#raise $!
						e = $!
						# do some kind of reporting here to show that something has gone horribly wrong
						sleep 0.5

					end
				end

				# raise e
				p e

			end

		end
	end
end
