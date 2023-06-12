require "json"

module Stars::API
  struct Package
    include JSON::Serializable

    getter id : String

    @[JSON::Field(key: "fullName")]
    getter full_name : String
    getter name : String
    getter repository : String

    @[JSON::Field(key: "authorName")]
    getter author_name : String
    @[JSON::Field(key: "authorId")]
    getter author_id : String
    @[JSON::Field(key: "timeCreated")]
    getter time_created : Float32
  end

  struct Author
    include JSON::Serializable

    getter id : String
    getter name : String
    getter email : String

    @[JSON::Field(key: "passwordHash")]
    getter password_hash : String?
    getter packages : Array(Package)
    @[JSON::Field(key: "timeCreated")]
    getter time_created : Float32
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
