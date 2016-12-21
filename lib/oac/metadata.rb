module OAC
	class Metadata

		attr_accessor :current_item, :next_item

		def [] a
			return @current_item[a]
		end

	end
end