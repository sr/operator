module FeatureHelpers
  def login_as(name, email)
    visit "/"

    fill_in "name", with: name
    fill_in "email", with: email
    click_button "Sign In"

    expect(page).to have_text("Welcome to Canoe")
  end
end
