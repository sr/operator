require "rails_helper"

RSpec.describe Stream::Event do
  let(:heroku_release_create_event) do
    JSON.parse(fixture_data("tonitrus/release_create_heroku_app"))
  end
  let(:non_heroku_release_create_event) do
    JSON.parse(fixture_data("tonitrus/release_create_non_heroku_app"))
  end
  let(:dyno_create_event) do
    JSON.parse(fixture_data("tonitrus/dyno_create_heroku_data_warehouse"))
  end

  it "process release:create events for our apps" do
    stream = Stream::Event.new(heroku_release_create_event)

    expect(stream).to be_release_create
    expect(stream).to be_heroku_employee
    expect(StreamEventJob).to receive(:perform_later)
    stream.call
  end

  it "does not process non release:events events" do
    stream = Stream::Event.new(dyno_create_event)

    expect(stream).to_not be_release_create
    expect(stream).to_not be_heroku_employee
    expect(StreamEventJob).to_not receive(:perform_later)
    stream.call
  end

  it "does not process events if the email address is not from heroku.com" do
    stream = Stream::Event.new(non_heroku_release_create_event)

    expect(stream).to be_release_create
    expect(stream).to_not be_heroku_employee
    expect(StreamEventJob).to_not receive(:perform_later)
    stream.call
  end
end
