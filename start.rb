$: << "./lib"
require 'oac'

$threads = []
controller = OAC::Controller.new OAC::Config.parse_yaml(File.read("config.yaml"))

controller.add_listener do | event, args, caller |

	puts "#{event.class.to_s}, #{caller}"
	puts args.inspect if event.is_a? OAC::Event::MetaEvent

end

controller.run!
$threads.map(&:join)