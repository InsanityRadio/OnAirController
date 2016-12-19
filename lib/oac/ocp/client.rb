module OAC; module OCP
	class Client < OAC::Client

		def initialize
			register NetControlRequest
			register 
		end

		def on_message message

			query = message.split(" ")

			case query[0]
				when "NET_CONTROL?"
					@controller
					break

				when "NET_CONTROL_LOGON"

					break

				when "NET_CONTROL_LOGOFF"

					break

			end

		end

	end
end; end