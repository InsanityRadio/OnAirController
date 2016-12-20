$: << "./lib"

require 'oac'
$threads = []

controller = OAC::Controller.new OAC::Config.parse_yaml(File.read("config.yaml"))

require 'pp'

controller.add_listener do | event, args, caller |

	#puts "#{event.class.to_s}, #{caller}"
	#pp args

end

controller.run!
$threads.map(&:join)