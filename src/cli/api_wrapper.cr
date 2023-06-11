require "crest"
require "uri"
require "http/client"
require "crypto/bcrypt/password"

module Stars::API
  extend self

  def up? : Bool
    begin
      !HTTP::Client.get(API_URL).body?.nil?
    rescue Socket::ConnectError
      false
    end
  end

  private def begin_request(&) : Crest::Response
    begin
      yield
    rescue ex : Crest::RequestFailed
      abort "\nRequest failed. Status code: #{ex.http_code} #{Crest::STATUSES[ex.http_code]}\nResponse body: #{JSON.parse(ex.response.body)["error"]}", 1
    end
  end

  # Returns the response respective to the create user request
  def create_user(name : String, email : String, password : String) : Crest::Response
    begin_request {
      Crest.post API_URL, {
        "authorName" =>  name,
        "email" =>  email,
        "password" =>  password
      }, json: true
    }
  end
end
