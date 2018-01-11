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
		json = args.current_item.to_json

		HTTParty.post("http://webapi.private/update.php", body: json, :headers => { 'Content-Type' => 'application/json' }).body

	end

end

controller.run!
$threads.map(&:join)