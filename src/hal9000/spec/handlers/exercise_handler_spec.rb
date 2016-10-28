require "spec_helper"

describe ExerciseHandler, lita_handler: true do
  describe "!exercise time" do
    it "returns a link to this commit for pardot" do
      send_command("exercise time")
      expect(check_validity(replies.last)).to be_truthy
      expect(replies.last.split.last.to_i).to be > 0
    end
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
    "Drop and give me",
    "Plank! Hold it for",
    "Squats! Give me",
    "Pullups! Go to failure or"
  ]
end
