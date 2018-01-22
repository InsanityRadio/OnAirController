require 'eventmachine'

module OAC
	class ServerFactory

		attr_reader :servers, :sockets, :clients, :controller
		def initialize controller = nil
			@controller = controller
			@servers = []
			@clients = []
			@sockets = []
		end

		def create_server type, port, host = "127.0.0.1"

			server = type.new @controller

			server.create_server(host, port) 
			server

		end

		def close 

			@servers.each { | s | begin; s.close; rescue OAC::Exceptions::NoServer; end }
			@servers = []

		end

	end
end