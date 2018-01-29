require 'csv'
require 'rexml/document'
require 'time'

module OAC; module OCP
	class Metadata < OAC::Metadata

		def self.parse string

			cc, data = string.split(",", 2)
			cc = cc.split(" ", 2)

			# cc[0] is "SET"
			case cc[1]
				when "LOG CURRENTITEMS"

					items = []
					# Myriad uses windows-1252 charset. Make it UTF-8 to avoid buggering everything up
					data = data.force_encoding("windows-1252").encode("UTF-8") rescue data

					CSV.parse(data, :quote_char => "\x00").flatten.each do | len |
						items << parse_log(deserialize(len))
					end

					obj = OAC::OCP::Metadata.new
					obj.current_item = items[0]
					obj.next_item = items[1]

					return obj

				when "PRESENTER"

				else
					# huh? we don't want to crash the program, but still, huh?
			end
		end

		def self.deserialize data

			kv = {}
			xml = REXML::Document.new("<a #{data} />")
			inject = proc { $1.to_i(16).chr }
			xml.root.attributes.each { | a, b | kv[a] = b.gsub(/\{([0-9]+)\}/, &inject) }

			kv

		end

		def self.parse_log logs

			{
				:reference => logs["Ref"],
				:playout_id => logs["ExtSchRef"],
				:cart_id => logs["HDRef"],
				:title => logs["ITitle"],
				:artist => logs["AName1"],
				:start_time => (Time.parse(logs['EstStDtTm']) rescue nil),
				:log_hour => (Time.strptime(logs['SchHour'] + '0000', '%Y%M%d%H%M%S') rescue nil)
			}

		end

	end
end; end
