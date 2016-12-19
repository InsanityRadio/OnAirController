require 'socket'
require 'securerandom'
require 'oac'

class ClientTest < OAC::Client 
	attr_reader :packets, :last_packet
	def on_message message
		@packets = 0 if !defined? @packets
		@packets += 1
		@last_packet = message

		"MESSAGE_OK"
	end
end

class ServerTest < OAC::Server

	CLIENT = ClientTest
	def on_new_client socket
		raise "ServerTest can only have one client" if @clients.length > 0
		@clients << (client = CLIENT.new(socket, self))
		@changed.call
		client
	end
	def get_client
		return @clients[0]
	end
end

describe OAC::Client do

	before do

		@factory = OAC::ServerFactory.new
		@server = @factory.create_server ServerTest, RSpec.configuration.test_port

		@remote = TCPSocket.new "127.0.0.1", RSpec.configuration.test_port
		@factory.pump 
		@client = @server.get_client		

	end

	after do 
		begin
			@server.close
		rescue Exception => e
			puts e
		end
	end

	describe ".on_data" do 
		context "when there is no data" do 
			it "does nothing" do
				expect(@client.on_data.length).to eq(0)
			end
		end
		context "when there is data" do 
			it "returns data" do 
				@remote << "test\n"
				@factory.pump
				expect(@client.packets).to be > 0
			end
			it "returns the correct data" do 
				@remote << (data = SecureRandom.hex) + "\n"
				@factory.pump
				expect(@client.last_packet).to eq(data)
			end
		end
		COUNT = rand(3) + 2
		context "when there are #{COUNT} packets" do 
			it "calls on_message #{COUNT} times" do 
				@remote << "Packet\n" * COUNT
				@factory.pump
				expect(@client.packets).to be COUNT
			end
		end 
	end

end