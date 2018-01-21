module OAC
	class Event
		# Executed when a studio goes on air. After TakeControl. 
		# When dispatched, will actually switch studios.
		class OfferControl < OAC::Event::ControlEvent

		end
	end
end