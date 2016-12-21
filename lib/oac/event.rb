module OAC
	class Event
		autoload :ControlEvent, 'oac/events/control_event'
		autoload :MetaEvent, 'oac/events/meta_event'

		autoload :OnAir, 'oac/events/on_air'
		autoload :OffAir, 'oac/events/off_air'

		autoload :SongChange, 'oac/events/song_change'

		attr_accessor :args, :caller
	end
end