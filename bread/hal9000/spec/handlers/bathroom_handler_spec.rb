require "spec_helper"

describe BathroomHandler, lita_handler: true do
  before do
    @poop_emoji = "\u{1F4A9}"
    @toilet_emoji = "\u{1F6BD}"
    @emoji_string = "<a href=\"https://pardot-pingpong.herokuapp.com/bathrooms\">Bathroom Status</a>:\nMens: #{@poop_emoji} #{@poop_emoji} 0 stalls free\nWomens: #{@poop_emoji} #{@toilet_emoji} #{@poop_emoji} #{@toilet_emoji} 2 stalls free"
    @no_emoji_string = "<a href=\"https://pardot-pingpong.herokuapp.com/bathrooms\">Bathroom Status</a>:\nMens: 0 stalls free\nWomens: 2 stalls free"
  end

  describe "online" do
    before do
      expect(Net::HTTP).to receive(:get)
        .with(URI("https://pardot-pingpong.herokuapp.com/bathrooms.json"))
        .and_return('[{"id":1,"name":"Mens","offline":false,"stalls":[{"number":0,"state":true},{"number":1,"state":true}]}, {"id":2,"name":"Womens","stalls":[{"number":0,"state":true},{"number":1,"state":false},{"number":2,"state":true},{"number":3,"state":false}]}]')
    end
    describe "!poo" do
      it "returns the status of the bathrooms" do
        send_command("poo")
        expect(replies.last).to eq(@emoji_string)
      end
    end

    describe "!bathroom status" do
      it "returns the status of the bathrooms" do
        send_command("bathroom status")
        expect(replies.last).to eq(@no_emoji_string)
      end
      it "returns the status of the bathrooms" do
        send_command("bathroom")
        expect(replies.last).to eq(@no_emoji_string)
      end
    end
  end

  describe "offline" do
    before do
      expect(Net::HTTP).to receive(:get)
        .with(URI("https://pardot-pingpong.herokuapp.com/bathrooms.json"))
        .and_return('[{"id":1,"name":"Mens","offline":true,"stalls":[{"number":0,"state":true},{"number":1,"state":true}]}, {"id":2,"name":"Womens","stalls":[{"number":0,"state":true},{"number":1,"state":false},{"number":2,"state":true},{"number":3,"state":false}]}]')
      @offline_no_emoji_string = "<a href=\"https://pardot-pingpong.herokuapp.com/bathrooms\">Bathroom Status</a>:\nMens: OFFLINE - Please check sensor 0 stalls free\nWomens: 2 stalls free"
    end
    describe "!bathroom status" do
      it "returns the status of the bathrooms" do
        send_command("bathroom status")
        expect(replies.last).to eq(@offline_no_emoji_string)
      end
      it "returns the status of the bathrooms" do
        send_command("bathroom")
        expect(replies.last).to eq(@offline_no_emoji_string)
      end
    end
  end
end
