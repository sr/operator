require "net/http"
require "uri"
require "json"

class BathroomHandler < ApplicationHandler
  route(/^poo$/i, :poo, command: true, help: { "poo" => "returns a parsed version of the current bathroom statuses" })
  route(/^bathroom(?: status)?$/i, :serious_poo, command: true, help: { "bathroom( status)" => "returns a parsed version of the current bathroom statuses" })

  def poo(request)
    request.reply bathroom_status_string(true)
  rescue => e
    request.reply "Something went wrong :( #{e}"
  end

  def serious_poo(request)
    request.reply bathroom_status_string()
  rescue => e
    request.reply "Something went wrong :( #{e}"
  end

  def bathroom_status_string(use_emojis = false)
    response = Net::HTTP.get(URI("https://pardot-pingpong.herokuapp.com/bathrooms.json"))
    json = JSON.parse(response)

    available = use_emojis ? "🚽 " : ""
    occupied = use_emojis ? "💩 " : ""
    response_string = "Bathroom Status:"

    json.each do |bathroom|
      name = bathroom["name"]
      stalls_string = ""
      stalls_in_use = 0
      stall_count = bathroom["stalls"].count
      bathroom["stalls"].each do |stall|
        if stall["state"] == true
          stalls_in_use += 1
          stalls_string += occupied
        else
          stalls_string += available
        end
      end
      available_stall_count = stall_count - stalls_in_use
      response_string += "\n#{name}: #{stalls_string}#{available_stall_count} stalls free"
    end
    response_string
  end
end
