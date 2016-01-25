require "nokogiri"
require "builder"

module Canoe
  class DeployOptionsForm
    def initialize(schema:, values: {})
      @schema = schema
      @values = values
    end

    def render
      Nokogiri::XML::Builder.new { |html|
        options.each do |property, config|
          html.div class: "form-group" do
            if config['enum']
              render_enum(html, property, config)
            end
          end
        end
      }.to_xml.html_safe
    end

    private
    def options
      @schema['properties']
    end

    def render_enum(html, property, config)
      enum = config['enum']

      html.label property.humanize, for: "options[#{property}]", class: "col-sm-2 control-label"
      html.div class: "col-sm-10" do
        html.select name: "options[#{property}]", class: "form-control" do
          enum.each do |enum_value|
            human_value = enum_value.split(':').first

            attributes = {value: enum_value}
            attributes[:selected] = "1" if enum_value == @values[property]

            html.option human_value, attributes
          end
        end
      end
    end
  end
end
