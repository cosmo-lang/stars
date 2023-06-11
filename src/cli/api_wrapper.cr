require "crypto/bcrypt/password"

module Stars::API
  extend self

  # Returns the response respective to the create user request
  def create_user(name : String, email : String, password : String) : Crest::Response
    Crest.post(API_URL, {
      "authorName" => name,
      "email" => email,
      "password" => password
    })
  end
end
