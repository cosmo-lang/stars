module Stars::CLI::Command::Version
  extend self

  def run(path : String) : Nil
    star_path = File.join path, "star.yml"
    unless File.exists?(star_path)
      puts "fatal: missing star.yml"
      exit
    end

    raw_yaml = File.read(star_path)
    star_yaml = YAML.parse(raw_yaml)
    entry_point = star_yaml["version"]?
    if entry_point.nil?
      puts "fatal: missing 'version' field in star.yml"
      exit
    end

    puts star_yaml["version"]
  end
end
