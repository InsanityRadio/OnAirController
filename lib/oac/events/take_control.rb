module OAC
	class Event
		# TakeControl occurs when a studio takes control of a network, but before it becomes on air.
		# Occurs before ExecuteControl, where the studio actually goes on air. 
		class TakeControl < OAC::Event::ControlEvent

		end
	end
end