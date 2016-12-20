require 'spec_helper'
require 'socket'
require 'oac'

class FakeSocket

	def initialize label 
		@label = label
		@closed = false
	end

	def << message
	end

	def to_str
		"<FakeSocket:#{self.hash} #{@label}>"
	end

	def close
		raise "Tried to close a socket twice" if @closed
		@closed = true
		@label += " closed"
	end

end

class ServerTestWithAccept < OAC::Server

	attr_reader :socket, :queued, :network

	def listen port, host = nil
		@port = port
		@socket = FakeSocket.new "ACCEPTOR port:#{@port}"
		@queued = []
	end

	def accept
		on_new_client @queued.shift
	end

	def test_add_socket
		@queued << OAC::Client.new(FakeSocket.new("CLIENT"), self)
	end

end

class ServerTestWithoutAccept < ServerTestWithAccept

	def listen port, host = nil
		super
		(0..2).each { test_add_socket; accept }
	end

	def clients
		@clients
	end

	def bind_on_message &on_message
		@on_message = on_message
	end

	def on_message a
		@on_message.call a
	end

end

class ServerFactoryTest < OAC::ServerFactory

	def select_changed
		[@servers.map { | c | [c.socket] * c.queued.length }.flatten]
	end

end

describe OAC::ServerFactory do

	before do
		@factory = ServerFactoryTest.new
	end

	after do
		@factory.close
	end

	describe ".create_server" do
		context "when creating a server" do
			it "uses the correct type" do

				expect(@factory.create_server(ServerTestWithoutAccept, 0)).to be_a(ServerTestWithoutAccept)

			end
		end

	end

	describe ".changed" do 
		context "when generating the client/server maps" do
			it "correctly maps clients to servers" do
			
				servers = []
				(0..2).each { | i | servers << @factory.create_server(ServerTestWithoutAccept, i) }

				@factory.changed

				expect(@factory.clients).not_to be_empty
				expect(@factory.sockets).not_to be_empty

				expect(@factory.sockets).to match_array(servers.map { |x| x.sockets }.flatten)
				expect(@factory.clients).to match_array(servers.map { |x| x.clients }.flatten)
			
			end
		end
	end

	describe ".pump" do 

		context "when there are no servers running" do
			it "does not throw an exception" do
				expect { @factory.pump }.not_to raise_error
			end
		end

		context "when one server is running and there is a connection request" do 
			it "accepts the new connection" do

				test_server = @factory.create_server ServerTestWithAccept, 0
				test_server.test_add_socket

				a = 0
				@factory.pump do | b |
					a += 1
					expect { b }.not_to raise_error
					expect(b).not_to be_nil
					expect(b).to be_a(OAC::Client)
				end

				expect(a).to eq(1)

			end
		end

	end

end