module OAC
	class Network

		include OAC::Helper::Dispatch

		attr_reader :id, :name, :description, :on_air

		def initialize

		end

		def give_control client
			dispatch OAC::Events::OnAir, self, client
		end

		# remove_control technically takes the network off air. 
		def remove_control client
			@on_air = nil if @on_air == client
			dispatch OAC::Events::OffAir, self, client
		end

	end
end