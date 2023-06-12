module Stars::CLI::Color
  extend self

  private def encode(text : String, code : Int, reset_code = 0) : String
    "\e[#{code}m#{text}\e[#{reset_code}m"
  end

  def bold(text : String)
    encode(text, 1, 22)
  end

  def faint(text : String)
    encode(text, 2, 22)
  end

  def red(text : String)
    encode(text, 31)
  end

  def green(text : String)
    encode(text, 92)
  end
end
