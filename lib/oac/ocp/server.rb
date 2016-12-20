module OAC; module OCP
	class Server < OAC::Server

		@network = nil
		attr_accessor :network
		
		@@CLIENT = OAC::OCP::Client

	end
end; end