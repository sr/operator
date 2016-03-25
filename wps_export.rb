# This file does a CSV export from webpasswordsafe
# To use it find the id of the last password by creating a new one, and adjust the MAX variable accordingly
# This script will then iterate through all the passwords
require 'io/console'
require 'json'
#require 'byebug'
WPS_HOST = "https://secrets.pardot.com/wps"
USERNAME = "jan.ulrich"
print "Please enter Jan's password: "
PASSWORD = STDIN.noecho(&:gets)
puts
MAX = 2
WPS_FIELDS = %w(title username currentPassword label notes)

def teampass_format(array)
  array.map{|s|"\"#{s}\""}.join(",")
end

def blank?(hash)
  return false unless hash.kind_of?(Hash)
  blank = true
  WPS_FIELDS.each do |f|
    blank = false unless hash[f].nil? || hash[f] == ""
  end
  blank
end

File.open("wps.csv", "w") do |f|
  f.puts(teampass_format(%w(Label Login Password Web\ Site Comments)))
  (1..MAX).each do |id|
    pw_info = `curl -s -H "X-WPS-Username: #{USERNAME}" -H "X-WPS-Password: #{PASSWORD}" #{WPS_HOST}/rest/passwords/#{id}`
    json = JSON.parse(pw_info)
    next if blank?(json['password'])
    password = `curl -s -H "X-WPS-Username: #{USERNAME}" -H "X-WPS-Password: #{PASSWORD}" #{WPS_HOST}/rest/passwords/#{id}/currentValue`
    json['password'].merge!(JSON.parse(password))
    f.puts(teampass_format(WPS_FIELDS.map{|field|json['password'][field]}))
  end
end