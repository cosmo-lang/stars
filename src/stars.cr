require "option_parser"
require "yaml"

module Stars
  extend self

  @@subcommands = ["version", "install", "init", "list", "lock", "update"]

  # Returns `shard.yml` as a `YAML::Any`
  def get_shard : YAML::Any
    raw_yaml = File.read File.join File.dirname(__FILE__), "..", "shard.yml"
    YAML.parse(raw_yaml)
  end

  def help(opts)
    puts <<-HELP
      Thank you for using Stars!
      Usage: stars [<options>...] [<command>]

      Commands:
        init                               - Initialize a `star.yml` file.
        install                            - Install dependencies, creating or using the `star.lock` file.
        list                               - List installed dependencies.
        lock [--update] [<shards>...]      - Lock dependencies in `star.lock` but doesn't install them.
        update [<shards>...]               - Update dependencies and `star.lock`.
        version [<path>]                   - Print the current version of the star.

      General options:
      HELP

    puts opts
    exit
  end

  # Parse options
  @@options = {} of Symbol => Bool
  begin
    OptionParser.parse(ARGV) do |opts|
      opts.on("-h", "--help", "Outputs help menu for Stars") do
        help(opts)
      end
      opts.on("-v", "--version", "Outputs the current version of Stars") do
        puts "Stars v#{get_shard["version"]}"
        exit
      end
      opts.on("--no-dev", "Does not install development dependencies.") do
        @@options[:no_dev] = true
      end
    end.parse(ARGV)
  rescue ex : OptionParser::InvalidOption
    puts ex.message
  end
end
