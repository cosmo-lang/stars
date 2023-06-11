require "crest"
require "uri"
require "http/client"
require "crypto/bcrypt/password"
require "./api/structs"

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
      response = Crest.get(API_URL + username)
      unless response.status_code == 200
        raise
      end
    rescue Crest::NotFound
      false
    rescue Crest::InternalServerError
      false
    end
  end

  def user_authorized?(username : String, password : String) : Bool
    return false unless user_exists?(username)
    author = fetch_user(username)
    hashed = Crypto::Bcrypt::Password.new(password)
    hashed.verify(author.password_hash)
  end

  def fetch_user(username : String) : Author
    response = ::API::Response.from_json Crest.get(API_URL + username).body
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
