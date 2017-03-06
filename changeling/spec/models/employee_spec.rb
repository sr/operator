require "rails_helper"

describe Employee do
  it "has all employees" do
    expect(Employee.all.length).to be > 175
  end

  it "maps from file employees.csv" do
    yannick = Employee.find_by_github("ys")
    expect(yannick.email).to eql "yannick@heroku.com"
    expect(yannick).to be_remote
    expect(yannick.name).to eql "Yannick Schutz"
    expect(yannick.id).to eql "yannick"
  end
end
