module OAC; module OCP
	class Client < OAC::Client

		def initialize socket, server
			super
		end

		def eof?
			["\x0d", "\n"]
			#["\n"]
		end

		def ident
			'+Connected AppName="MyriadOCP4" Version="4.0.69"'
		end

		def on_open 
			self << ident
			if @server.network.on_air == @studio
				self << "NET_CONTROL_AVAILABLE"
			end
			@myriad_id = @id
		end

		def on_message message

			query = message.split(" ", 2)

			case query[0]
				when "NET_CONTROL?"
					# This is ambiguous. We need to work out who's
					if @server.network.on_air
						if @server.network.on_air == @studio
							puts "sending available"
							self << "NET_CONTROL_AVAILABLE"
							#self << "NET_CONTROL MV4_" + @myriad_id
						else
							# Make Myriad happy because it thinks it's in control ;-)
							self << "NET_CONTROL MV4_00000" # + @server.network.on_air.id
						end
					else
						#self << "NET_CONTROL_AVAILABLE"
					end

				# NET_CONTROL_LOGON MV4_[PC-NAME] [force],[PC-ID] [PC-NAME/MYRIAD NAME]
				when "NET_CONTROL_LOGON"
					q = query[1].split(" ")
					@myriad_id = query[0]
					#force = query[1].split(",") == "2"
					force = false

					@studio.clients << self

					# We're already on air!
					if @server.network.on_air == @studio
						send_on_air_response
					else
						#take_control @server.network, force
					end

				when "NET_CONTROL_LOGOFF"
					#release_control @networks, false
					
				when "SET"
					# metadata update - we don't care if we're not on air.
					return if !@networks.length

					update = Metadata.parse message
					return if !@metadata.nil? and @metadata[:reference] == update.current_item[:reference]

					song_change update

			end

		end

		def send_on_air_response
			self << "NET_CONTROL_START"
			self << "GET_INFORMATION"
		end

		private
		def on_take_control *args
			send_on_air_response
			super *args
		end

		private
		def on_release_control *args
			self << "NET_CONTROL_ENDRT"
			super *args
		end

	end
end; end