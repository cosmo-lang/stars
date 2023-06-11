VALID_EMAIL_REGEX = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\z/

module Stars::CLI::Command::Register
  extend self

  # TODO: invalid usernames, minimum lengths, etc.
  def run : Nil
    username = Command.input("Enter your desired username: ")
    email = Command.validate_input("Enter your desired e-mail: ", "Invalid e-mail") do |email|
      !!(email =~ VALID_EMAIL_REGEX)
    end

    password = Command.input("Enter your desired password: ", no_echo: true)
    response = API.create_user(username, email, password)
    puts "Registered author '#{username}' successfully!"
  end
end
