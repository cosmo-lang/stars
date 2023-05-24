require "./cli/commands"
require "option_parser"
require "yaml"

module Stars::CLI
  extend self

  @@options = {} of Symbol => Bool
  @@path = Dir.current

  def run
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
          path = args[1]?.nil? ? @@path : File.expand_path(args[1])
          case args[0]?
          when "init"
            Command::Init.run(path)
          when "run"
            Command::Run.run(path)
          when "install"
            # Command::Install.run(@@path, no_dev: @@options[:no_dev])
          when "list"
            # Command::List.run(@@path, tree: args.includes?("--tree"))
          when "lock"
            # Command::Lock.run(
            #   @@path,
            #   args[1..-1].reject(&.starts_with?("--")),
            #   update: args.includes?("--update")
            # )
          when "update"
            # Command::Update.run(
            #   @@path,
            #   args[1..-1].reject(&.starts_with?("--"))
            # )
          when "version"
            # Command::Version.run(args[1]? || @@path)
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

  private def help(opts)
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

  private def parse_args(args) : Tuple(Array(String), Array(String))
    targets = [] of String
    options = [] of String

    args.each do |arg|
      (arg.starts_with?('-') ? options : targets) << arg
    end

    {targets, options}
  end

  # Returns `shard.yml` as a `YAML::Any`
  private def get_shard : YAML::Any
    raw_yaml = File.read File.join File.dirname(__FILE__), "..", "shard.yml"
    YAML.parse(raw_yaml)
  end
end
