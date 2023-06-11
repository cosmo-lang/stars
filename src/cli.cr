require "./cli/commands"
require "option_parser"
require "yaml"

module Stars::CLI
  extend self

  @@options = {} of Symbol => Bool
  @@path = Dir.current

  def get_star_yml_field(path : String, optional = false)
    star_path = File.join path, "star.yml"
    unless File.exists?(star_path)
      abort "fatal: missing star.yml", 1
    end

    raw_yaml = File.read(star_path)
    star_yaml = YAML.parse(raw_yaml)
    value = star_yaml["version"]?
    if value.nil?
      abort "fatal: missing 'version' field in star.yml", 1
    end
  end

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
          when "auth"
            puts "fatal: not implemented yet"
            # Command::Auth.run
          when "init"
            Command::Init.run(path)
          when "run"
            Command::Run.run(path)
          when "install"
            puts "fatal: not implemented yet"
            # Command::Install.run(@@path, no_dev: @@options[:no_dev])
          when "list"
            puts "fatal: not implemented yet"
            # Command::List.run(@@path, tree: args.includes?("--tree"))
          when "lock"
            puts "fatal: not implemented yet"
            # Command::Lock.run(
            #   @@path,
            #   args[1..-1].reject(&.starts_with?("--")),
            #   update: args.includes?("--update")
            # )
          when "publish"
            puts "fatal: not implemented yet"
            # Command::Update.run(
            #   @@path,
            #   args[1..-1].reject(&.starts_with?("--"))
            # )
          when "update"
            puts "fatal: not implemented yet"
            # Command::Update.run(
            #   @@path,
            #   args[1..-1].reject(&.starts_with?("--"))
            # )
          when "version"
            puts get_star_yml_field("version")
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
        auth                               - Starts the authentication process to login as Stars author
        init                               - Initialize a `star.yml` file.
        run                                - Run the `entry_point` field of a `star.yml` file with Cosmo
        install                            - Install dependencies, creating or using the `star.lock` file. (WIP)
        list                               - List installed dependencies. (WIP)
        lock [--update] [<shards>...]      - Lock dependencies in `star.lock` but doesn't install them. (WIP)
        publish [<package-name>]           - Upload a Star to the registry. (WIP)
        update [<shards>...]               - Update dependencies and `star.lock`. (WIP)
        version [<path>]                   - Print the current version of the star. (WIP)

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
