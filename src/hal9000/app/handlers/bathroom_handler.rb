require 'net/http'
require 'uri'
require 'json'

class BathroomHandler < ApplicationHandler
  route(/^poo$/i, :poo, command: false, help: { "poo" => "returns a parsed version of the current bathroom statuses" })
  route(/^bathroom status$/i, :poo, command: false, help: { "poo" => "returns a parsed version of the current bathroom statuses" })

  def poo(request)
    begin
      response = Net::HTTP.get(URI('https://pardot-pingpong.herokuapp.com/bathrooms.json'))
      json = JSON.parse(response)
      request.reply "#{parse_json(json)}"
    rescue => e 
      request.reply "Something went wrong :( #{e}"
    end
  end

  def parse_json(json)
    response_string = "Bathroom Status:"
    json.each do |bathroom|
      name = bathroom['name']
      stall_count = bathroom['stalls'].count
      stalls_in_use = bathroom['stalls'].select {|a| a['state'] == true}.count
      available_stall_count = stall_count - stalls_in_use
      response_string += "\n#{name}: #{available_stall_count} stalls free"
    end
    response_string
  end
end
