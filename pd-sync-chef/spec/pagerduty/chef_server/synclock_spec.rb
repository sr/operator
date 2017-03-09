require 'pagerduty/chef_server/synclock'

describe PagerDuty::ChefServer::SyncLock do
  let(:lock) do
    PagerDuty::ChefServer::SyncLock.new(
      '/tmp/ci_restore_chef.lock',
      'ci02',
      'ci02',
      'MyManJenkins',
      'master',
      'abc123'
    )
  end

  let(:lock_chefserver) do
    PagerDuty::ChefServer::SyncLock.new(
      '/tmp/ci_restore_chef.lock',
      'chef02',
      'chef02',
      'MyManJenkins',
      'master',
      'abc123'
    )
  end

  context '#new' do
    it 'should return an instance of PagerDuty::ChefServer::SyncLock' do
      expect(lock).to be_an_instance_of PagerDuty::ChefServer::SyncLock
    end
  end

  context '#local_chef_server?' do
    it 'should return true if the local_hostname contains chef' do
      expect(lock_chefserver.send(:local_chef_server?)).to eq(true)
    end

    it 'should return false if the local_hostname does not contain chef.' do
      expect(lock.send(:local_chef_server?)).to eql(false)
    end
  end

  context '#remote_chef_server?' do
    it 'should return true if the remote_hostname contains chef' do
      expect(lock_chefserver.send(:remote_chef_server?)).to eql(true)
    end

    it 'should return false if the remote_hostname does not contain chef' do
      expect(lock.send(:remote_chef_server?)).to eq(false)
    end
  end
end
