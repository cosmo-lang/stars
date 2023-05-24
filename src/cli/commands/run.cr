module Stars::CLI::Command::Run
  extend self

  def run(path : String) : Nil
    star_path = File.join path, "star.yml"
    unless File.exists?(star_path)
      puts "fatal: missing star.yml"
      exit
    end
    unless `cosmo -v`.starts_with?("Cosmo")
      puts "fatal: missing 'cosmo' binary"
      exit
    end

    raw_yaml = File.read(star_path)
    star_yaml = YAML.parse(raw_yaml)
    entry_point = star_yaml["entry_point"]?
    if entry_point.nil?
      puts "fatal: missing 'entry_point' field in star.yml"
      exit
    end

    puts `cosmo #{File.join path, star_yaml["entry_point"].to_s}`
  end
end
