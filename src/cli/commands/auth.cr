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

  private def login : Nil
    username = input("Entire your username: ")
    password = input("Entire your password: ", no_echo: true)
  end

  private def register : Nil
    username = input("Entire your desired username: ")

    email = ""
    asked_email = false
    loop do
      got_email = input("Entire your desired e-mail: ")
      valid = !!(got_email =~ VALID_EMAIL_REGEX)
      puts "Invalid email" if asked_email && !valid
      if valid
        asked_email = true
        email = got_email
        break
      end
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
