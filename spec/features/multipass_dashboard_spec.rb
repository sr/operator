require "rails_helper"

RSpec.describe "The multipass dashboard", :type => :feature do
  include AuthenticationHelpers

  before do
    login_with_oauth

    10.times do
      Fabricate(:multipass)
    end

    visit "/multipasses"
  end

  it "shows multipasses" do
    Multipass.all.each do |multipass|
      expect(page).to have_link(nil, href: multipass.reference_url)
    end
  end
end
