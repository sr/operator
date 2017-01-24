require "spec_helper"

describe BathroomHandler, lita_handler: true do
  before do
    expect(Net::HTTP).to receive(:get)
      .with(URI("https://pardot-pingpong.herokuapp.com/bathrooms.json"))
      .and_return('[{"id":1,"name":"34 Mens","stalls":[{"number":0,"state":true},{"number":1,"state":true}]}, {"id":2,"name":"34 Womens","stalls":[{"number":0,"state":true},{"number":1,"state":false},{"number":2,"state":true},{"number":3,"state":false}]}]')
  end
  describe "!poo" do
    it "returns the status of the bathrooms" do
      send_command("poo")
      expect(replies.last).to eq("Bathroom Status:\n34 Mens: 0 stalls free\n34 Womens: 2 stalls free")
    end
  end
  describe "!bathroom status" do
    it "returns the status of the bathrooms" do
      send_command("bathroom status")
      expect(replies.last).to eq("Bathroom Status:\n34 Mens: 0 stalls free\n34 Womens: 2 stalls free")
    end
    it "returns the status of the bathrooms" do
      send_command("bathroom")
      expect(replies.last).to eq("Bathroom Status:\n34 Mens: 0 stalls free\n34 Womens: 2 stalls free")
    end
  end
end
