require 'timeout'
require 'digest'
require 'socket'

module OAC
	module Switch
		# OCP switch will connect to Myriad Playout via TCP, and instruct it to go off air.
		class OCP < DummySwitch

			def initialize config, network
				super
			end

			# If we have a previous, take it off air. 
			def switch_control studio, previous = nil

				return if studio == previous

				if studio.active_connection?

					puts "It looks like #{studio.id} already has control of the network"

					current_log_reference = get_current_log_item(studio)

					if current_log_reference != nil 
						puts "It is playing a track... #{current_log_reference}. Letting it continue..."
						return
					else
						puts "Nothing is playing. Red herring? Continuing"
					end

				end

				# No idea why we'd try to change between playout systems, but ok. 
				# Obviously, we can't do anything if the new client isn't Myriad.

				unless studio.config['type'] == 'OAC::OCP'
					send_off_air_request(previous)
					return
				end

				has_sent_on_air = false

				@network.start_switch

				begin

					if previous != nil

						timeout(1) do
							current_log_reference = get_current_log_item(previous)
						end

						has_sent_on_air = send_on_air_request(studio, current_log_reference)
						send_off_air_request(previous) 

					else
						has_sent_on_air = send_on_air_request(studio)
					end

				rescue
					if $!.is_a? Timeout::Error
						puts "Timed out trying to get log ref from previous studio"
					end
					p $!
					p $?
					# We don't want to send it twice! If something actually goes wrong with the
					#  request, then we don't want to do it again because that could be devastating
					send_on_air_request(studio) unless has_sent_on_air
				end

				@network.end_switch

			end

			def get_current_log_item client

				socket = connect_to client
				pep = "<PEP_CURRENTLOGITEM_REFERENCESTRING>"
				socket << "GET VALUE #{pep}\r\n"

				loop do
					data = socket.gets
					next if data[0..8] != 'SET VALUE'
					socket.close
					reference = data[10..-1].strip
					return reference == pep ? nil : reference
				end

			end

			def send_off_air_request client

				socket = connect_to client

				socket << "ONAIR RELEASE\r\n"
				socket.gets "+Success"

				socket << "WAIT 1\r\n"
				socket.gets "+Success"

				socket << "LOG MODE STANDBY\r\n"
				socket.gets "+Success"

				socket.close

			end

			def send_on_air_request client, reference = nil

				socket = connect_to client

				socket << "LOG MODE STANDBY\r\n"
				socket.gets "+Success\r\n"

				socket << "ONAIR TAKE\r\n"
				socket.gets "\r\n"

				if reference
					socket << 'LOG VIEW JUMP,' + reference + "\r\n"
					socket.gets "+Success"
				else
					socket << "LOG VIEW HOME\r\n"
					socket.gets "+Success"
				end

				socket << "LOG MODE HOURMODE\r\n"
				socket.gets "+Success"

				socket << "LOG GO\r\n"
				socket.gets "+Success"

				socket.close

				# If we've got this far, then it probably worked. 
				return true
				
			end

			private
			def get_port client
				client.config['macro_port'] || 6950 
			end

			def connect_to client
				socket = TCPSocket.new client.config['ip'][0], get_port(client)
				socket.gets "\n"
				socket
			end

		end
	end
end