require "json"

module Stars::API
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
    getter password_hash : String?
    getter packages : Array(Package)
  end

  struct AuthenticationInfo
    include JSON::Serializable

    @[JSON::Field(key: "authenticationToken")]
    getter token : String
  end

  struct Response
    include JSON::Serializable

    @[JSON::Field(key: "success")]
    getter? success : Bool
    getter result : Package | Author | AuthenticationInfo
  end
end
