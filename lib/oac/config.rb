require 'yaml'
require 'dig_rb'
require 'redis'

module OAC
	class Config

		def self.parse_yaml file
			self.new YAML::load(file) rescue raise OAC::Error::ConfigError, $!.message
		end

		def initialize data
			@data = data
		end

		def get key, default = nil

			value = @data.dig(*(key.split('.'))) rescue nil
			value.nil? ? default : value

		end

		def set_temp key, value
			redis = Redis.new
			redis.set key, value
			redis.quit
		end

		def get_temp key, default
			redis = Redis.new
			data = redis.get(key) || default
			redis.quit

			data
		end

		def to_h
			@data
		end


	end
end