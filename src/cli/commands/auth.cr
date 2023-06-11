module Stars::CLI::Command::Auth
  extend self

  private def input(message : String, no_echo = false) : String
    STDOUT.write(message.to_slice)
    if no_echo
      STDIN.noecho
    else
      STDIN.gets.chomp
    end
  end

  private def prompt_login_or_register : Bool
    case input("Are you trying to login or register? ").lower
    when "login"
      puts "Chose to log in to account..."
      true
    when "register"
      puts "Chose to register account..."
      false
    else
      prompt_login_or_register
    end
  end

  def run : Nil
    puts "Starting authorization..."

    logging_in = prompt_login_or_register
    if logging_in
      username = input("Entire your username: ")
      password = input("Entire your password: ", no_echo: true)
    else # registering
      username = input("Entire your desired username: ")
      email = input("Entire your desired e-mail: ")
      password = input("Entire your desired password: ", no_echo: true)
      response = API.create_user(username, email, password)

      unless response.status_code == 200
        abort "Registration failed: #{JSON.parse(response.body)["message"]}", 1
      end
      puts "Successfully registered author '#{username}'!"
    end
  end
end
