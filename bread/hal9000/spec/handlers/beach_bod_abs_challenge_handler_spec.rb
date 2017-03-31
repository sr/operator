require "spec_helper"

describe BeachBodAbsChallengeHandler, lita_handler: true do
  describe "!beach bod time" do
    it "returns beach bod command" do
      send_command("beach bod time")
      expect(replies[0]).to match(/.*30 reps. Do it!.*/)
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
