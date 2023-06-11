require "crest"
require "uri"
require "http/client"
require "crypto/bcrypt/password"
require "./api_structs"

module Stars::API
  extend self
  private URL = "http://localhost:3030/api/packages/"

  def up? : Bool
    begin
      !HTTP::Client.get(URL).body?.nil?
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
      response = begin_request { Crest.get(URL + username) }
      response.success? && API::Response.from_json(response.body).success?
    rescue Crest::NotFound
      false
    rescue Crest::InternalServerError
      false
    end
  end

  def user_authorized?(username : String, password : String) : Bool
    return false unless user_exists?(username)
    # TODO: fix invalid hash string? (check password and password_hash)
    Crypto::Bcrypt::Password
      .new(fetch_user(username).password_hash)
      .verify(password)
  end

  def fetch_user(username : String) : Author
    response = begin_request { Crest.get(URL + username) }
    API::Response.from_json(response.body).result.as Author
  end

  def auth_token(username : String) : String
    response = begin_request { Crest.get(URL + "auth/" + username) }
    info = API::Response.from_json(response.body).result.as(AuthenticationInfo)
    info.token
  end

  def create_user(name : String, email : String, password : String) : Crest::Response
    begin_request {
      Crest.post URL, {
        "authorName" =>  name,
        "email" =>  email,
        "password" =>  password
      }, json: true
    }
  end

  def create_package(
    username : String,
    password : String,
    packageName : String,
    repository : String,
    authenticationToken : String
  ) : Crest::Response

    begin_request {
      Crest.post "#{URL}/#{username}", {
        "packageName" =>  packageName,
        "repository" =>  repository,
        "authorPassword" =>  password,
        "authenticationToken" =>  password
      }, json: true
    }
  end
end
