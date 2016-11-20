require "http/cookie"
require "base64"
require "json"
require "openssl/hmac"

module Kemalyst::Handler
  # The flash handler provides a mechanism to pass flash message between
  # requests.
  class Flash < Base
    property :key

    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def initialize
      @key = "kemalyst.flash"
    end

    def call(context)
      cookies = HTTP::Cookies.from_headers(context.request.headers)
      decode(context.flash, cookies[@key].value) if cookies.has_key?(@key)
      call_next(context)
      value = encode(context.flash.unread)
      cookies = HTTP::Cookies.from_headers(context.response.headers)
      cookies << HTTP::Cookie.new(@key, value)
      cookies.add_response_headers(context.response.headers)
      context
    end

    private def decode (flash, data)
      json = Base64.decode_string(data)
      values = JSON.parse(json)
      values.each do |key, value|
        flash[key.to_s] = value.to_s
      end
    end

    private def encode (flash)
      data = Base64.encode(flash.to_json)
      return data
    end
  end
end
