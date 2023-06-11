require "readline"

VALID_EMAIL_REGEX = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\z/

module Stars::CLI::Command::Auth
  extend self

  private def input(message : String, no_echo = false) : String
    result : String? = nil

    while result.nil? || result.empty?
      message += "\e[1;32m"
      result = no_echo ? STDIN.noecho { Readline.readline(message) } : Readline.readline(message)
      STDOUT.write "\e[0m".to_slice
    end

    result.strip
  end

  private def validate_input(message : String, invalid_message : String, no_echo = false, fatal = false, &predicate : String -> Bool) : String
    result = ""

    loop do
      got = input(message, no_echo)
      valid = predicate.call(got)

      if valid
        result = got
        break
      else
        abort invalid_message, 1 if fatal
        puts invalid_message
      end
    end

    result
  end

  private def prompt_login_or_register : Bool
    case input("Are you trying to login or register? ").downcase
    when "login"
      puts "Logging in to account..."
      true
    when "register"
      puts "Registering account..."
      false
    else
      prompt_login_or_register
    end
  end

  # TODO: store logged in userinfo somewhere (env variable?)
  private def login : Nil
    username = validate_input("Entire your username: ", "That user does not exist") do |username|
      API.user_exists?(username)
    end

    validate_input(
      "Entire your password: ",
      "Invalid password",
      no_echo: true,
      fatal: true
    ) do |password|

      matches = false

      begin
        author = API.fetch_user(username)
        encrypted = Crypto::Bcrypt::Password.new(author.password_hash)
        matches = encrypted.verify(password)
      rescue ex : Exception
        puts "Failed to fetch user: #{ex.message}"
      end

      matches
    end

    puts "Successfully logged in as '#{username}'!"
  end

  private def register : Nil
    username = input("Entire your desired username: ")
    email = validate_input("Entire your desired e-mail: ", "Invalid e-mail") do |email|
      !!(email =~ VALID_EMAIL_REGEX)
    end

    password = input("Entire your desired password: ", no_echo: true)
    response = API.create_user(username, email, password)
    puts "Registered author '#{username}' successfully!"
  end

  def run : Nil
    puts "Starting authorization..."
    abort "Failed to connect to registry. The registry is currently offline, please try again later.", 1 unless API.up?

    logging_in = prompt_login_or_register
    if logging_in
      login
    else register
    end
  end
end
