# /lib/barclay/v1.rb
require "net/http"
require "uri"
require "json"

module Barclay
  class V1
    class << self

      # def auth
      #   return {  "subscriber_id" => Settings.barclay_subscriber_id,
      #             "subscriber_token" => Settings.barclay_subscriber_token }
      # end

      def customers(query)
        post('search', { "m" => "autocomplete", "s" => query })
        self
      end



      def response
        @response
      end

      def parsed_response
        JSON.parse(@response.body)
      end

      private
        def post(uri, options)
          uri = URI.parse(Settings.barclay_base_url + uri)
          # options.merge!(self.auth)
          @response = Net::HTTP.post_form(uri, options)
          self
        end
    end
  end
end

