module OAC; module TCP
	class Server < OAC::Server

		@network = nil
		attr_accessor :network
		
		CLIENT = OAC::TCP::Client

	end
end; end