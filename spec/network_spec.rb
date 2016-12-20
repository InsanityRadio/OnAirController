require 'spec_helper'
require 'socket'
require 'oac'


describe OAC::Network do

	describe ".should_take_control" do

		context "todo" do
			it "throws a OAC::Exceptions::NoServer error" do 

				server = OAC::Server.new

				expect { server.close }.to raise_error OAC::Exceptions::NoServer

			end
		end

	end

end
