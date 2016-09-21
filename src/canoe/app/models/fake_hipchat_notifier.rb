class FakeHipchatNotifier
  Message = Struct.new(:room_id, :message)

  attr_reader :messages

  def initialize
    @messages = []
  end

  def notify_room(room_id, message, _opts = {})
    @messages << Message.new(room_id, message)
  end
end
