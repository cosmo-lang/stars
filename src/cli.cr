require "./cli/colors"
require "./cli/commands"
require "option_parser"
require "yaml"

module Stars::CLI
  extend self

  HELP_MENU = <<-HELP
  Thank you for using Stars!
  Usage: stars [<options>...] [<command>]

  Commands:
    init                               - Initialize a `star.yml` file.
    run                                - Run the `entry_point` field of a `star.yml` file with Cosmo
    install [<package-name>]           - Install dependencies, creating or using the `star.lock` file. (WIP)
    list                               - List installed dependencies. (WIP)
    lock [--update] [<shards>...]      - Lock dependencies in `star.lock` but doesn't install them. (WIP)
    publish [<package-name>]           - Upload a Star to the registry. (WIP)
    register                           - Register as a Stars author
    update [<shards>...]               - Update dependencies and `star.lock`. (WIP)
    version [<path>]                   - Print the current version of the star. (WIP)

  General options:
  HELP

  @@options = {} of Symbol => Bool
  @@path = Dir.current

  def path : String
    @@path
  end

  def fatal(message : String)
    abort Color.red("fatal: #{message}"), 1
  end

  def set_star_yml_field(field_name : String, value : YAML::Any) : Nil
    star_path = File.join path, "star.yml"
    unless File.exists?(star_path)
      fatal("missing star.yml")
    end

    raw_yaml = File.read(star_path)
    star_yaml = YAML.parse(raw_yaml)
    yaml_hash = star_yaml.as_h
    yaml_hash[YAML::Any.new(field_name)] = value

    File.write(star_path, YAML::Any.new(yaml_hash))
  end

  def get_star_yml_field(field_name : String, optional = false) : YAML::Any?
    star_path = File.join path, "star.yml"
    unless File.exists?(star_path)
      fatal("missing star.yml")
    end

    raw_yaml = File.read(star_path)
    star_yaml = YAML.parse(raw_yaml)
    value = star_yaml[field_name]?
    if value.nil? && !optional
      fatal("missing '#{field_name}' field in star.yml")
    end

    value
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
        opts.on("--dev", "Install dependency as a development dependency.") do
          @@options[:dev] = true
        end

        opts.unknown_args do |args, options|
          command = (args.first? || "").downcase
          unless args[1]?.nil?
            unless command == "install"
              @@path = File.expand_path(args[1])
            end
          end

          case args.first?
          when "init"
            Command::Init.run
          when "run"
            Command::Run.run
          when "install"
            Command::Install.run(args[1]?, no_dev: @@options[:no_dev]?, as_dev: @@options[:dev]?)
          when "list"
            fatal("not implemented yet")
            # Command::List.run(@@path, tree: args.includes?("--tree"))
          when "lock"
            fatal("not implemented yet")
            # Command::Lock.run(
            #   @@path,
            #   args[1..-1].reject(&.starts_with?("--")),
            #   update: args.includes?("--update")
            # )
          when "publish"
            Command::Publish.run
          when "register"
            Command::Register.run
          when "update"
            fatal("not implemented yet")
            # Command::Update.run(
            #   @@path,
            #   args[1..-1].reject(&.starts_with?("--"))
            # )
          when "version"
            puts get_star_yml_field("version").to_s
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
    puts HELP_MENU
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
