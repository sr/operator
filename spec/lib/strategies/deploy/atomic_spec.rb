require "strategies"
require "environments"
require "deploy"

describe Strategies::Deploy::Atomic do
  let(:tempdir) { Dir.mktmpdir("pull-agent") }
  let(:environment) {
    Environments.build(:test).tap { |e|
      e.payload = "pardot"
      e.payload.options[:repo_path] = tempdir
    }
  }

  let(:strategy) { Strategies.build(:deploy, :atomic, environment) }

  after { FileUtils.rm_rf(tempdir) }

  describe "#deploy_to_server" do
    it "should deploy and link to the first choice when there is no current_link" do
      Tempfile.create("empty.tar.gz") do |f|
        f.write(empty_tar_gz_contents)
        f.flush

        strategy.deploy(f.path, Deploy.new)
        expect(File.readlink("#{tempdir}/current")).to eq("#{tempdir}/releases/A")
      end
    end

    it "in 3 deploys it should deploy to A/B/A" do
      Tempfile.create("empty.tar.gz") do |f|
        f.write(empty_tar_gz_contents)
        f.flush

        strategy.deploy(f.path, Deploy.new)
        expect(File.readlink("#{tempdir}/current")).to eq("#{tempdir}/releases/A")
        strategy.deploy(f.path, Deploy.new)
        expect(File.readlink("#{tempdir}/current")).to eq("#{tempdir}/releases/B")
        strategy.deploy(f.path, Deploy.new)
        expect(File.readlink("#{tempdir}/current")).to eq("#{tempdir}/releases/A")
      end
    end

    it "should do a rollback" do
      Tempfile.create("empty.tar.gz") do |f|
        f.write(empty_tar_gz_contents)
        f.flush

        strategy.deploy(f.path, Deploy.new)
        expect(File.readlink("#{tempdir}/current")).to eq("#{tempdir}/releases/A")
        strategy.deploy(f.path, Deploy.new)
        expect(File.readlink("#{tempdir}/current")).to eq("#{tempdir}/releases/B")
        strategy.rollback
        expect(File.readlink("#{tempdir}/current")).to eq("#{tempdir}/releases/A")
      end
    end

    it "should not roll back because there hasn't been a deploy" do
      expect(strategy.rollback?(Deploy.new)).to be_falsey
    end

    it "should roll back because the version matches" do
      build1 = BuildVersion.new(1, "abc123", "https://artifactory.example/build1.tar.gz")
      build2 = BuildVersion.new(2, "bcd345", "https://artifactory.example/build2.tar.gz")

      Tempfile.create("empty.tar.gz") do |f|
        f.write(empty_tar_gz_contents)
        f.flush

        strategy.deploy(f.path, Deploy.from_hash("artifact_url" => build1.artifact_url))
        File.write("#{tempdir}/current/build.version", build1.to_s)
        build1link = File.readlink("#{tempdir}/current")

        strategy.deploy(f.path, Deploy.from_hash("artifact_url" => build2.artifact_url))
        File.write("#{tempdir}/current/build.version", build2.to_s)

        is_rollback = strategy.rollback?(Deploy.from_hash("artifact_url" => build1.artifact_url))
        expect(is_rollback).to be_truthy

        allow(ShellHelper).to receive(:execute_shell).never
        strategy.rollback
        expect(File.readlink("#{tempdir}/current")).to eq(build1link)
      end
    end
  end

  describe "#pick_next_choice" do
    it "Basecase" do
      array = []
      current = nil
      pick = strategy.send(:pick_next_choice, array, current, :forward)
      expect(pick).to be_nil
    end

    it "Basecase with current" do
      array = []
      current = :a
      pick = strategy.send(:pick_next_choice, array, current, :forward)
      expect(pick).to be_nil
    end

    it "Singleton" do
      array = [:a]
      current = :a
      pick = strategy.send(:pick_next_choice, array, current, :forward)
      expect(pick).to eq(:a)
    end

    it "Singleton - Reverse" do
      array = [:a]
      current = :a
      pick = strategy.send(:pick_next_choice, array, current, :reverse)
      expect(pick).to eq(:a)
    end

    it "Middle" do
      array = [:a, :b, :c, :d]
      current = :b
      pick = strategy.send(:pick_next_choice, array, current, :forward)
      expect(pick).to eq(:c)
    end

    it "Middle - Reverse" do
      array = [:a, :b, :c, :d]
      current = :b
      pick = strategy.send(:pick_next_choice, array, current, :reverse)
      expect(pick).to eq(:a)
    end

    it "Wrap Around" do
      array = [:a, :b, :c, :d]
      current = :d
      pick = strategy.send(:pick_next_choice, array, current, :forward)
      expect(pick).to eq(:a)
    end

    it "Wrap Around - Reverse" do
      array = [:a, :b, :c, :d]
      current = :a
      pick = strategy.send(:pick_next_choice, array, current, :reverse)
      expect(pick).to eq(:d)
    end
  end
end
