require "option_parser"
require "yaml"

module Stars
  extend self

  # Returns `shard.yml` as a `YAML::Any`
  def get_shard : YAML::Any
    raw_yaml = File.read File.join File.dirname(__FILE__), "..", "shard.yml"
    YAML.parse(raw_yaml)
  end

  # Parse options
  @@options = {} of Symbol => Bool
  begin
    OptionParser.new do |opts|
      opts.banner = "Thank you for using Stars!\nUsage: stars [COMMAND] [OPTIONS]"
      opts.on("-h", "--help", "Outputs help menu for Cosmo CLI") do
        puts opts
        exit
      end
      opts.on("-v", "--version", "Outputs the current version of Cosmo") do
        puts "Stars v#{get_shard["version"]}"
        exit
      end
    end.parse(ARGV)
  rescue ex : OptionParser::InvalidOption
    puts ex.message
  end
end
