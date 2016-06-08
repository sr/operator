class FakeHipchatNotifier
  def initialize
    @messages = []
  end

  attr_reader :messages

  Message = Struct.new(:room_id, :message)

  def notify_room(room_id, message, color = nil)
    @messages << Message.new(room_id, message)
  end
end
