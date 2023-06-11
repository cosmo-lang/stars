require "file_utils"
require "../api"
require "./commands/auth"
require "./commands/init"
require "./commands/run"

module Stars::CLI::Command
  def self.input(message : String, no_echo = false) : String
    result : String? = nil

    while result.nil? || result.empty?
      message += "\e[1;32m"
      result = no_echo ? STDIN.noecho { Readline.readline(message) } : Readline.readline(message)
      STDOUT.write "\e[0m".to_slice
    end

    result.strip
  end

  def self.validate_input(message : String, invalid_message : String, no_echo = false, fatal = false, &predicate : String -> Bool) : String
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
end
