require "payload"

describe Payload do
  it "should pull id from passed options hash" do
    id = :pardot
    payload = Payload.new(id: id)
    expect(payload.id).to eq(id)
  end

  it "should derive name from id" do
    id = :pardot
    payload = Payload.new(id: id)
    expect(payload.name).to eq("Pardot")
  end

  it "should make name camelcase of id" do
    id = :pardot_stuff
    payload = Payload.new(id: id)
    expect(payload.name).to eq("PardotStuff")
  end

  it "should default to the current symlink if not given" do
    id = :pardot
    payload = Payload.new(id: id)
    expect(File.basename(payload.current_link)).to eq("current")
  end

  it "should use to the current symlink given" do
    id = :pardot
    payload = Payload.new(id: id, current_link: '/current-pi')
    expect(File.basename(payload.current_link)).to eq("current-pi")
  end

  it "should default to the path_choices if not given" do
    id = :pardot
    repo_path = File.expand_path(File.dirname(File.dirname(__FILE__)))
    payload = Payload.new(id: id, repo_path: repo_path)
    expect(payload.path_choices).to eq(['releases/A', 'releases/B'].map{ |p| File.expand_path(p, repo_path) })
  end
end
