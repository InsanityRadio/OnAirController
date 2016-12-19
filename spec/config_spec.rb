require 'oac'

CONFIG_DATA_1 = <<end
studios:
  - name: STUDIO-69
    description: My Studio
    ip: 
        - 127.0.0.1
    type: OAC::OCP
    networks:
        insanity: 1

networks:
  - name: radio1
    description: Radio 1
    control: force

settings:
    handover_tail: 5
end


describe OAC::Config do

	describe "::parse_yaml" do 
		context "when passed nil" do 
			it "throws a ConfigError" do
				expect { OAC::Config.parse_yaml(nil) }.to raise_error(OAC::Error::ConfigError)
			end
		end

		context "when actually passed YAML" do
			it "parses the YAML" do
				expect( OAC::Config.parse_yaml("test: 1").get("test") ).to be(1)
			end
		end
	end

	describe ".get" do 
		before do
			@config = OAC::Config.parse_yaml CONFIG_DATA_1
		end
		context "when the key does not exist, and there is no default" do 
			key = "stupid.key"
			it "returns nil" do
				expect( @config.get(key) ).to be(nil)
			end
		end

		context "when the key does not exist, and a default is provided" do 
			key = "stupid.key"
			default = rand()
			it "returns that default" do
				expect( @config.get(key, default) ).to be(default)
			end
		end

		context "when the key exists, it returns the value" do 
			key = "settings.handover_tail"
			it "returns the value" do
				expect( @config.get(key) ).to be(5)
			end
		end

		context "when retrieving an array" do
			key = "networks"
			it "returns the array" do
				expect( @config.get(key) ).to be_a(Array)
				expect( @config.get(key)[0] ).to be_a(Hash)
				expect( @config.get(key)[0]["name"] ).to be("radio1")
			end
		end

	end

end