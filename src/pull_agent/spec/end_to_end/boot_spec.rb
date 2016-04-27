require "spec_helper"

describe "pull-agent executable" do
  BIN = File.expand_path("../../../bin/pull-agent", __FILE__).freeze

  it "exits non-zero and when environment is not given" do
    r, w = IO.pipe
    pid = Process.spawn(ENV.to_hash.merge("PULL_AGENT_ENV" => "test"), BIN, out: w, err: w)
    w.close
    _, status = Process.wait2(pid)

    expect(status.exitstatus).to eq(1)
  end

  it "exits successfuly and shows usage when app is not given" do
    r, w = IO.pipe
    pid = Process.spawn(ENV.to_hash.merge("PULL_AGENT_ENV" => "test"), BIN, "dev", out: w, err: w)
    w.close
    _, status = Process.wait2(pid)

    expect(r.read.start_with?("# pull_agent")).to eq(true)
    expect(status.exitstatus).to eq(0)
  end

  it "exits successfully when both environment and app are given" do
    r, w = IO.pipe
    pid = Process.spawn(ENV.to_hash.merge("PULL_AGENT_ENV" => "test"), BIN, "dev", "pardot", out: w, err: w)
    w.close
    _, status = Process.wait2(pid)

    expect(status.exitstatus).to eq(0)
  end
end
