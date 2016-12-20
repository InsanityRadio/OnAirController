module OAC
	class Event
		autoload :ControlEvent, 'oac/events/control_event'

		autoload :OnAir, 'oac/events/on_air'
		autoload :OffAir, 'oac/events/off_air'

		attr_accessor :args, :caller
	end
end