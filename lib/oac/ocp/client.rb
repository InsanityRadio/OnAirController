module OAC; module OCP
	class Client < OAC::Client

		def initialize socket, server
			super
		end

		def eof?
			["\x0d", "\n"]
		end

		def ident
			'+Connected AppName="MyriadOCP4" Version="4.0.69"'
		end

		def on_open 
			self << ident
			if @server.network and @server.network.on_air == nil
				self << "NET_CONTROL_AVAILABLE"
			end
			@myriad_id = @id
		end

		def on_message message

			query = message.split(" ")

			case query[0]
				when "NET_CONTROL?"
					# This is ambiguous. We need to work out who's
					if @server.network.on_air
						if @server.network.on_air == self
							self << "NET_CONTROL MV4_" + @myriad_id
						else
							# Make Myriad happy because it thinks it's in control ;-)
							self << "NET_CONTROL MV4_" + @server.network.on_air.id
						end
					else
						self << "NET_CONTROL_AVAILABLE"
					end

				# NET_CONTROL_LOGON MV4_[PC-NAME] [force],[PC-ID] [PC-NAME/MYRIAD NAME]
				when "NET_CONTROL_LOGON"
					@myriad_id = message[1]
					force = message[2].split(",") == "2"
					take_control @server.network, force

				when "NET_CONTROL_LOGOFF"
					release_control @networks, false
					
				when "SET"
					# metadata update
					puts "<<metdata update>>"

			end

		end

		private
		def on_take_control *args
			self << "NET_CONTROL_START"
			self << "GET_INFORMATION"
			super *args
		end

		private
		def on_release_control *args
			self << "NET_CONTROL_ENDRT"
			super *args
		end

	end
end; end