module Stars::CLI::Command::Init
  extend self

  def run(path : String) : Nil
    unless File.exists?(path)
      puts "Created project folder."
    end
    FileUtils.mkdir_p(path)

    star_name = File.basename(path)
    File.open(File.join(path, "star.yml"), "w") do |file|
      output = IO::Memory.new
      git_user = Process.run("git", args: ["config", "--get", "user.name"], output: output)
      file << <<-STAR_YML
      name: #{star_name}
      version: 0.1.0

      entry_point: src/#{star_name}.⭐
      authors:
        - #{git_user.success? ? output.to_s.strip : "(could not find GitHub username)"}

      cosmo: ^0.6.4
      STAR_YML

      file.close
    end
    puts "Created star.yml."

    FileUtils.mkdir_p(File.join path, "src")
    puts "Created source directory."

    entry_point = File.join(path, "src", "#{star_name}.⭐")
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
    puts `git init #{path}`
  end
end
