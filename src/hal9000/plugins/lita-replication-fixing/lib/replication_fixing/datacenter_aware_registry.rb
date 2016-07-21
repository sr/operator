module ReplicationFixing
  class DatacenterAwareRegistry
    NoSuchDatacenter = Class.new(StandardError)

    def initialize
      @registry = {}
    end

    def register(datacenter, client)
      @registry[datacenter] = client
    end

    def for_datacenter(datacenter)
      @registry.fetch(datacenter)
    rescue KeyError
      raise NoSuchDatacenter, "no such datacenter: #{datacenter}"
    end
  end
end
