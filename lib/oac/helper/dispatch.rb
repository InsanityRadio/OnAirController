module OAC
	module Helper
		module Dispatch

			attr_reader :listeners

			def listen &listener

				@listeners = [] if !defined? @listeners
				@listeners << listener

			end

			def dispatch *args
				@listeners.each { | l | l.call(*args) }
			end

		end
	end
end