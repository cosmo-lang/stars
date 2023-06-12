module Stars::CLI::Command::Publish
  extend self

  def run : Nil
    puts "Authorizing..."
    unless API.up?
      CLI.fatal "Failed to connect to registry. The registry is currently offline, please try again later."
    end

    username = Command.validate_input("Enter your username: ", "That user does not exist") do |username|
      API.user_exists?(username)
    end
    password = Command.validate_input(
      "Enter your password: ",
      "Invalid password",
      no_echo: true,
      fatal: true
    ) { |password| API.user_authorized?(username, password) }

    puts "Successfully logged in as '#{username}'!"
    packageName = CLI.get_star_yml_field("name").to_s
    repository = CLI.get_star_yml_field("repository").to_s
    authenticationToken = API.auth_token(username)

    # TODO: if package exists use API.update_package (currently unimplemented)
    API.create_package(username, password, packageName, repository, authenticationToken)
    puts "Successfully created package '#{username}/#{packageName}'!"
  end
end
