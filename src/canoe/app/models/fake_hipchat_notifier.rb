class FakeHipchatNotifier
  Message = Struct.new(:room_id, :message, :color)

  attr_reader :messages

  def initialize
    @messages = []
  end

  def notify_room(room_id, message, opts = {})
    @messages << Message.new(room_id, message, opts[:color])
  end
end
