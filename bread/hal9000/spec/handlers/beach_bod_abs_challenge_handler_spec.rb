require "spec_helper"

describe BeachBodAbsChallengeHandler, lita_handler: true do
  describe "!beach bod time" do
    it "returns a link to this commit for pardot" do
      send_command("beach bod time")
      expect(check_validity(replies.last)).to be_truthy
      expect(replies.last.split.last.to_i).to be > 0
    end
  end

  def check_validity(input)
    allowed_phrases.each do |phrase|
      return true if input.include? phrase
    end
    false
  end

  def allowed_phrases
    [
      "Standard Crunches",
      "Reverse Crunches",
      "Raise Leg Crunches",
      "Frog Crunches",
      "Bicycle Crunches",
      "Side Crunches",
      "Full Sit Ups",
      "Wide Leg Sit Ups",
      "Running Man Sit Ups",
      "Reverse Crunch Pulse",
      "V Ups",
      "Russion Twists",
      "Scissor Kicks",
      "Side Plank Crunches"
    ]
  end
end
