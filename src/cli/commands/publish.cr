require "readline"

VALID_EMAIL_REGEX = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\z/

module Stars::CLI::Command::Publish
  extend self

  def run : Nil
    puts "Authorizing..."
    unless API.up?
      abort "Failed to connect to registry. The registry is currently offline, please try again later.", 1
    end

    username = ::Command.validate_input("Enter your username: ", "That user does not exist") do |username|
      API.user_exists?(username)
    end

    ::Command.validate_input(
      "Enter your password: ",
      "Invalid password",
      no_echo: true,
      fatal: true
    ) { |password| API.user_authorized?(username, password) }

    puts "Successfully logged in as '#{username}'!"
  end
end
