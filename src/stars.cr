require "option_parser"
require "yaml"

module Stars
  extend self

  @@path = Dir.current
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

  def parse_args(args) : Tuple(Array(String), Array(String))
    targets = [] of String
    options = [] of String

    args.each do |arg|
      (arg.starts_with?('-') ? options : targets) << arg
    end

    {targets, options}
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

      opts.unknown_args do |args, options|
        case args[0]?
        when "init"
          # Commands::Init.run(@@path)
        when "install"
          # Commands::Install.run(@@path)
        when "list"
          # Commands::List.run(@@path, tree: args.includes?("--tree"))
        when "lock"
          # Commands::Lock.run(
          #   @@path,
          #   args[1..-1].reject(&.starts_with?("--")),
          #   update: args.includes?("--update")
          # )
        when "update"
          # Commands::Update.run(
          #   @@path,
          #   args[1..-1].reject(&.starts_with?("--"))
          # )
        when "version"
          # Commands::Version.run(args[1]? || @@path)
        else
          help(opts)
        end

        exit
      end
    end
  rescue ex : OptionParser::InvalidOption
    puts ex.message
  end
end
