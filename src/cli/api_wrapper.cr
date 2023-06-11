require "crest"
require "uri"
require "json"
require "http/client"
require "crypto/bcrypt/password"

struct Package
  include JSON::Serializable

  getter id : String
  getter name : String
  getter repository : String
  getter author : Author
  @[JSON::Field(key: "authorId")]
  getter author_id : String
end

struct Author
  include JSON::Serializable

  getter id : String
  getter name : String
  getter email : String

  @[JSON::Field(key: "passwordHash")]
  getter password_hash : String
  getter packages : Array(Package)
end

struct APIResponse
  include JSON::Serializable

  @[JSON::Field(key: "success")]
  getter? success : Bool
  getter result : Package | Author
end

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

  def user_exists?(username : String) : Bool
    begin
      Crest.get(API_URL + username).status_code == 200
    rescue Crest::NotFound
      false
    rescue Crest::InternalServerError
      false
    end
  end

  def fetch_user(username : String) : Author
    response = APIResponse.from_json Crest.get(API_URL + username).body
    response.result.as Author
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
