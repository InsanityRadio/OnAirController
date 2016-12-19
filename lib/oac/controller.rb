module OAC
	class Controller

		def initialize config
			@config = config
			@clients = []
			@networks = []
			@factory = ServerFactory.new self
		end

		# Bubble events up
		def on_event *args
			dispatch *args
		end

		def register_network network 
			register network
			@networks << network
		end

		def register_client client
			register client
			@clients << client
		end

		def register object
			raise "Object must include OAC::Helper::Dispatch" unless object.method_defined? "listen"
			object.listen &self.on_event
		end

	end
end