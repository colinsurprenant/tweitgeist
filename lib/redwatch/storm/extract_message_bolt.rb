require 'json'

module Redwatch
  class ExtractMessageBolt < RedStorm::SimpleBolt
    output_fields :message

    on_receive do |tuple| 
      json = tuple.getString(0)
      JSON.parse(json)["text"]
    end
  end
end
