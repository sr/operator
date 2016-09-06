require "uri"
require "net/http"

class Hipchat
  def self.notify_room(room, msg, production, color = nil)
    hipchat_host = "hipchat.dev.pardot.com"
    uri = URI.parse("https://#{hipchat_host}/v1/rooms/message")

    unless %w[yellow red green purple gray].include?(color)
      color = (production ? "purple" : "gray")
    end

    body = {
      format: "json",
      auth_token: ENV["HIPCHAT_AUTH_TOKEN"],
      room_id: room,
      from: "Canoe",
      color: color,
      message_format: "html",
      message: msg
    }
    # NOTE: from name has to be between 1-15 characters

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(body)

    if Rails.env.production? || ENV["CANOE_HIPCHAT_ENABLED"].to_s == "true"
      http.request(request)
    end

    Instrumentation.log(at: "hipchat", room: room, msg: msg)
  end
end
