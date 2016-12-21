module OAC
	class Metadata

		attr_accessor :current_item, :next_item

		def []
			return @current_item
		end

	end
end