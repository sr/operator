require "uri"
require "net/http"

class HipchatNotifier
  def notify_room(room_id, msg, opts = {})
    hipchat_host = "hipchat.dev.pardot.com"
    uri = URI.parse("https://#{hipchat_host}/v1/rooms/message")

    color = opts.fetch(:color, "purple")
    body = {
      format: "json",
      auth_token: ENV["HIPCHAT_AUTH_TOKEN"],
      room_id: room_id,
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

    Instrumentation.log(at: "hipchat", room_id: room_id, msg: msg)
  end
end
