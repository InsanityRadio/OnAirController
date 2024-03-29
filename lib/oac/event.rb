module OAC
	class Event
		autoload :ControlEvent, 'oac/events/control_event'
		autoload :MetaEvent, 'oac/events/meta_event'

		autoload :TakeControl, 'oac/events/take_control'
		autoload :ExecuteControl, 'oac/events/execute_control'
		autoload :OffAir, 'oac/events/off_air'
		autoload :OfferControl, 'oac/events/offer_control'

		autoload :CartChange, 'oac/events/cart_change'
		autoload :SongChange, 'oac/events/song_change'

		attr_accessor :args, :caller
	end
end
