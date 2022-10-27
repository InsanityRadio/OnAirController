module OAC
	class Metadata

		attr_accessor :current_item, :next_item, :all

		def [] a
			return @current_item[a]
		end

		def inspect
			"<OAC::Metadata(object_id: #{"0x00%x" % (object_id << 1)}, current_item: #{@current_item}, next_item: #{@next_item})>"
		end

	end
end
