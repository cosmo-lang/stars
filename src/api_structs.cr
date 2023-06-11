require "json"

struct Stars::API::Package
  include JSON::Serializable

  getter id : String
  getter name : String
  getter repository : String
  getter author : Author
  @[JSON::Field(key: "authorId")]
  getter author_id : String
end

struct Stars::API::Author
  include JSON::Serializable

  getter id : String
  getter name : String
  getter email : String

  @[JSON::Field(key: "passwordHash")]
  getter password_hash : String
  getter packages : Array(Package)
end

struct Stars::API::Response
  include JSON::Serializable

  @[JSON::Field(key: "success")]
  getter? success : Bool
  getter result : Package | Author
end
