require "spec_helper"

describe CommitHandler, lita_handler: true do
  describe "!commit 1234" do
    it "returns a link to this commit for pardot" do
      send_command("commit 1234")
      expect(replies.last).to match("https://git.dev.pardot.com/Pardot/pardot/commit/1234")
    end
  end
end
