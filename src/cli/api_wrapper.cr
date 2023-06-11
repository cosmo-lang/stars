require "crest"
require "uri"
require "http/client"
require "crypto/bcrypt/password"

module Stars::API
  extend self

  def up? : Bool
    begin
      !HTTP::Client.get(URI.new "http", "localhost", 3030).body?.nil?
    rescue Socket::ConnectError
      false
    end
  end

  # Returns the response respective to the create user request
  def create_user(name : String, email : String, password : String) : Crest::Response
    Crest.post(API_URL, {
      "authorName" => name,
      "email" => email,
      "password" => password
    })
  end
end
