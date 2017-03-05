require "spec_helper"

describe "pull-agent executable" do
  BIN = File.expand_path("../../../bin/pull-agent", __FILE__).freeze

  it "exits non-zero and shows usage when environment is not given" do
    _r, w = IO.pipe
    pid = Process.spawn(ENV.to_hash.merge("PULL_AGENT_NO_SLEEP" => "1", "PULL_AGENT_ENV" => "test"), BIN, out: w, err: w)
    w.close
    _, status = Process.wait2(pid)

    expect(status.exitstatus).to eq(1)
  end

  it "exits non-zero and shows usage when app is not given" do
    _r, w = IO.pipe
    pid = Process.spawn(ENV.to_hash.merge("PULL_AGENT_NO_SLEEP" => "1", "PULL_AGENT_ENV" => "test"), BIN, "dev", out: w, err: w)
    w.close
    _, status = Process.wait2(pid)

    expect(status.exitstatus).to eq(1)
  end

  it "exits successfully when both environment and app are given" do
    _r, w = IO.pipe
    pid = Process.spawn(ENV.to_hash.merge("PULL_AGENT_NO_SLEEP" => "1", "PULL_AGENT_ENV" => "test"), BIN, "dev", "pardot", out: w, err: w)
    w.close
    _, status = Process.wait2(pid)

    expect(status.exitstatus).to eq(0)
  end

  it "exists non-zero if PULL_AGENT_CONFIG_FILE is set and points to a non-existing file" do
    r, w = IO.pipe
    env = ENV.to_hash.merge(
      "PULL_AGENT_NO_SLEEP" => "1",
      "PULL_AGENT_ENV" => "test",
      "PULL_AGENT_CONFIG_FILE" => "/boom/town.yml"
    )
    pid = Process.spawn(env, BIN, "dev", "pardot", out: w, err: w)
    w.close
    _, status = Process.wait2(pid)

    expect(status.exitstatus).to eq(1)
    expect(r.read.include?("/boom/town.yml")).to eq(true)
  end
end
