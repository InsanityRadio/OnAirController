require 'spec_helper'
require 'socket'
require 'oac'

class ServerTest < OAC::Server 
end

describe OAC::Server do

	before do
		@server = OAC::Server.new
	end

	after do 
		begin
			@server.close
		rescue Exception => e
			puts e
		end
	end

	describe ".listen" do

		context "given port #{RSpec.configuration.test_port}" do
			it "listens on #{RSpec.configuration.test_port}" do

				@server.listen RSpec.configuration.test_port
				expect { TCPSocket.new("127.0.0.1", RSpec.configuration.test_port) }.to_not raise_error

			end
		end

		context "given a random port" do 
			it "listens on that random port" do
				port = rand(2**15) + 1024
				@server.listen port
			end
		end

		context "given an in-use port" do 
			it "throws a OAC::Exceptions::BindError" do

				tmp_server = TCPServer.new "127.0.0.1", RSpec.configuration.test_port

				expect { @server.listen RSpec.configuration.test_port }.to raise_error OAC::Exceptions::BindError

				tmp_server.close rescue nil

			end
		end

	end

	describe ".close" do 

		context "when listening" do
			it "closes the server socket" do

				server = OAC::Server.new
				server.listen rand(2**15) + 1024

				expect { server.close }.not_to raise_error Exception

			end
		end

		context "when not listening" do
			it "throws a OAC::Exceptions::NoServer error" do 

				server = OAC::Server.new

				expect { server.close }.to raise_error OAC::Exceptions::NoServer

			end
		end

	end

end