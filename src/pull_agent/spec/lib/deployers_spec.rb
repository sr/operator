module Pardot
  module PullAgent
    describe "deployers" do
      specify "all deployers files are required" do
        Dir[File.join(File.dirname(__FILE__), "..", "..", "lib", "pardot", "pull_agent", "deployers", "*.rb")].each do |deployer|
          if require deployer
            fail "#{File.realpath(deployer)} was not required in lib/pardot/pull_agent.rb"
          end
        end
      end
    end
  end
end
