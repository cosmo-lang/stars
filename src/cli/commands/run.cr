module Stars::CLI::Command::Run
  extend self

  def run : Nil
    star_path = File.join CLI.path, "star.yml"
    unless File.exists?(star_path)
      puts "fatal: missing star.yml"
      exit
    end
    unless `cosmo -v`.starts_with?("Cosmo")
      puts "fatal: missing 'cosmo' binary"
      exit
    end

    puts `cosmo #{File.join CLI.path, CLI.get_star_yml_field("entry_point").to_s}`
  end
end
