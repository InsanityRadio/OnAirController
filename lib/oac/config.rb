require 'yaml'
require 'dig_rb'

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

		def to_h
			@data
		end


	end
end