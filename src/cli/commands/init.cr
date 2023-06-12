module Stars::CLI::Command::Init
  extend self

  def run : Nil
    unless File.exists?(CLI.path)
      puts "Created project folder."
    end
    FileUtils.mkdir_p(CLI.path)

    star_name = File.basename(CLI.path)
    File.open(File.join(CLI.path, "star.yml"), "w") do |file|
      output = IO::Memory.new
      git_user = Process.run("git", args: ["config", "--get", "user.name"], output: output).success? ? output.to_s.strip : "(could not find GitHub username)"
      file << <<-STAR_YML
      name: #{star_name}
      version: 0.1.0

      entry_point: #{star_name}.⭐
      repository: #{git_user}/#{star_name}
      authors:
        - #{git_user}

      cosmo: ^0.9.8
      STAR_YML

      file.close
    end
    puts "Created star.yml."

    entry_point = File.join CLI.path, "#{star_name}.⭐"
    File.open(entry_point, "w") do |file|
      file << <<-COSMO
      public int fn main(string[] args) {
        puts("Hello, world!")
        0
      }
      COSMO
      file.close
    end

    puts "Created #{File.basename(entry_point)}."
    puts "Initializing git repository..."
    puts `git init #{CLI.path}`
  end
end
