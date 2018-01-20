module OAC
	class Event
		# Executed when a studio goes on air. After TakeControl. 
		# When dispatched, will actually switch studios.
		class ExecuteControl < OAC::Event::ControlEvent

		end
	end
end