$: << "./lib"
require 'oac'
require 'json'
require 'httparty'

$threads = []
controller = OAC::Controller.new OAC::Config.parse_yaml(File.read("config.yaml"))

controller.add_listener do | event, args, caller |

	# puts "#{event.class.to_s}, #{caller}"
	if event.is_a? OAC::Event::MetaEvent

		# send it up
		json = event.current_item.to_json

		HTTParty.post("http://localhost:3000/api/v1/users", body: JSON.parse(json)).body

	end

end

controller.run!
$threads.map(&:join)