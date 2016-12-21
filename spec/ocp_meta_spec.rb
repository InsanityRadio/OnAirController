require 'socket'
require 'securerandom'
require 'oac'

TEST_STRING = 'SET LOG CURRENTITEMS,Ref="85BBBBBB9B37B840" SchHour="2016122014" AppVer="v4.0.25" SerVer="4.000002" IType="7" ExtSchRef="12" MyrSchRef="12" IStatus="2" PlyLoc="10" IEndType="1" IDt="42724" EstStDtTm="2016-12-20T14:30:52" INo="6" ITitle="Sunflower" ITNo="15" AName1="Paul Weller" ANo1="15" Inf1="6" Inf2="8" InfStr2="Charts" HDRef="15002" EstLn="242.44" SchLn="242.44" SchCat="8" SchEra="2" SchSty="YY                                                              " SchYear="1993" HDInEn="9.06" HDEnType="0",Ref="B1933EE99B37B840" SchHour="2016122014" AppVer="v4.0.25" SerVer="4.000002" IType="7" IStatus="2" SchEndType="50" ActEndType="50" IDt="42724" EstStDtTm="2016-12-20T14:34:54" ITitle="test{22}" AName1="test" HDRef="2" HDInEn="0" HDEnType="0"'

describe OAC::OCP::Metadata do

	describe "::parse" do 

		metadata = OAC::OCP::Metadata.parse(TEST_STRING)
		context "when passed a valid response" do 
			it "returns a Metadata object" do 
				expect(metadata).to be_a OAC::Metadata
			end
			it "has the correct current song information" do
				current_item = metadata.current_item
				expect(current_item[:playout_id]).to eq "12"
				expect(current_item[:title]).to eq "Sunflower"
				expect(current_item[:artist]).to eq "Paul Weller"
				expect(current_item[:cart_id]).to eq "15002"
			end
			it "has the correct next song information" do
				next_item = metadata.next_item
				expect(next_item[:playout_id]).to eq "C2"
				expect(next_item[:title]).to eq "test\""
				expect(next_item[:artist]).to eq "test"
				expect(next_item[:cart_id]).to eq "2"
			end
		end 
	end

	describe ".deserialize" do
		context "when passed a data object with escaped characters" do
			it "correctly un-escapes that character" do
				item = OAC::OCP::Metadata.deserialize 'Ref="me{40}example"'
				expect(item["Ref"]).to eq "me@example"
			end
		end		
	end
end