$: << "./lib"
require 'oac'
require 'json'
require 'httparty'
require 'eventmachine'

$threads = []

EM.run {
	controller = OAC::Controller.new OAC::Config.parse_yaml(File.read("config.yaml"))

	controller.add_listener do | event, args, caller |

		# puts "#{event.class.to_s}, #{caller}"
		if event.is_a? OAC::Event::MetaEvent

			# send it up
			json = args.current_item.to_json

			items = args.all.dup

			is_now = items[0][:type] == 4
			items = items[1..-1] unless is_now

			reftime = Time.now.to_f
			# Check for an advert break. 
			if items[0][:type] == 4
				# trigger an opt of whatever length the ad break is 

				break_items = items.index{|t| t[:type] != 4} - 1
				break_length = items[0..break_items].inject(0) {|sum, i| sum + i[:length].to_f}

				est_start_time = items[0][:start_time]
				est_end_time = items[break_items + 1][:start_time]

				break_length = est_end_time.to_f - reftime if break_items == 0

				seconds_until_break = is_now ? 0 : est_start_time.to_f - reftime
				puts ""
				puts ""
				puts is_now ? "In break" : "Break coming up"
				puts "items: #{break_items} length: #{break_length} in: #{seconds_until_break}"	
				puts ""

				json = {
					:reference => "0000000000000000",
					:playout_id => 0,
					:type => 4,
					:title => "Advert break (#{break_length.floor.to_i}s)",
					:artist => "",
					:start_time => est_start_time,
					:trigger_time => reftime,
					:end_time => est_end_time,
					:log_hour => items[0][:log_hour]
				}.to_json

			end

			networks = caller.networks.map {|n| n.id }

			networks.each do | net |
				puts "Updating network #{net} \n #{json}"
				HTTParty.post("http://webapi.private/update.php?network=#{net}", body: json, :headers => { 'Content-Type' => 'application/json' }).body
			end

		end

	end
}
#controller.run!
#$threads.map(&:join)
