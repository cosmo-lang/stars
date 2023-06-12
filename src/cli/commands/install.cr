require "file_utils"
require "git-repository"

module Stars::CLI::Command::Install
  extend self

  @@install_folder = File.expand_path File.join(CLI.path, ".stars")

  # Executes a git command
  private def git(args_raw : String, package_folder : String, err_message : String, include_output = false) : String
    args = args_raw.split(' ')
    command = args.shift
    args = ["--no-pager", "-C", package_folder, command].concat(args)
    output = IO::Memory.new
    Process.run("git", args, output: output, error: output)

    out_lines = output.to_s.split('\n')
    out_lines.delete("")

    if !out_lines.empty? && out_lines.last.starts_with?("fatal:")
      CLI.fatal "#{err_message}#{include_output ? ": \n#{output.to_s}" : ""}"
    end
    output.to_s
  end

  # Verifies that the given version fits the version given in star.yml
  private def verify_version(folder_path : String, version : String) : Nil
    puts "Verifying version validity..."
    expected_version = CLI.get_star_yml_field("version", search_path: folder_path).to_s

    # TODO: handle version schemes like ~ and ^
    unless version == expected_version
      CLI.fatal "Version mismatch. Expected version matching '#{expected_version}' but got '#{version}'."
    end
  end

  private def post_install(package_name : String, version : String, dev = false)
    puts "Adding to star.yml..."
    dependency_list = CLI.get_star_yml_field(
      (dev ? "dev_" : "") + "dependencies",
      optional: true
    )

    if dependency_list.nil?
      new_dependency_list = Dependencies.new
    else
      new_dependency_list = dependency_list.as_h
    end

    new_dependency_list[YAML::Any.new(package_name)] = YAML::Any.new(version)
    # TODO: allow version schemes here (~, ^)
    CLI.set_star_yml_field(
      (dev ? "dev_" : "") + "dependencies",
      YAML::Any.new(new_dependency_list)
    )
  end

  # Resolves a dependency by author/name scheme
  private alias Dependencies = Hash(YAML::Any, YAML::Any)
  private def resolve_dependency(full_name : String, development = false) : Nil
    unless full_name.includes?('/')
      CLI.fatal "Invalid package name. Correct format: \"author/package\""
    end

    full_name += "@latest" unless full_name.includes?('@')
    full_name, version = full_name.split('@')
    author_name, package_name = full_name.split('/')
    package_install_folder = File.join @@install_folder, package_name

    unless API.package_exists?(author_name, package_name)
      CLI.fatal "Package '#{full_name}' does not exist"
    end

    puts "Installing #{full_name}..."
    CLI.get_star_yml_field("version")
    not_cached = !File.directory?(package_install_folder) || Dir.entries(package_install_folder).empty?
    package = API.fetch_package(author_name, package_name)
    repo_name = package.repository
    repo_link = "https://github.com/#{repo_name}"

    if not_cached
      FileUtils.mkdir_p(package_install_folder)
      puts "Cloning repository..."
      git("clone #{repo_link}.git .", package_install_folder, "Failed to clone repository '#{repo_name}'")
      puts "Checking out version #{version}..."
      git("checkout #{version}", package_install_folder, "Failed to checkout tag #{version}")
    end

    puts "Finding version tag..."

    repo = GitRepository.new(repo_link)
    unless version == "latest"
      unless repo.tags.has_key?(version)
        CLI.fatal "Version #{version} release tag does not exist on repository '#{repo_name}'."
      end

      verify_version(package_install_folder, version)
    else
      version = repo.tags.last_key?
      if version.nil?
        CLI.fatal "No release tags exist on repository '#{repo_name}'. Please create one and try again."
      end

      verify_version(package_install_folder, version)
    end

    if File.directory?(package_install_folder) && Dir.entries(package_install_folder).size > 0
      FileUtils.rm_rf File.join(package_install_folder, "star.lock")
      git("pull origin #{version} --tags", package_install_folder, "Failed to pull from repository '#{repo_name}'.")
    end

    # TODO: lock versions
    post_install(package_install_folder, full_name, version)
    puts Color.green "Successfully installed package #{full_name}@#{version}!"
  end

  def run(package_name : String?, no_dev = false, as_dev = false) : Nil
    FileUtils.mkdir_p(@@install_folder)

    if package_name.nil?
      dependency_list = CLI.get_star_yml_field("dependencies", optional: true)

      unless no_dev
        dev_dependency_list = CLI.get_star_yml_field("dev_dependencies", optional: true)
        unless dev_dependency_list.nil? || dev_dependency_list.as_a?.nil?
          dev_dependency_list.as_a.each do |dev_dependency|
            resolve_dependency(dev_dependency.to_s, development: true)
          end
        end
      end

      unless dependency_list.nil? || dependency_list.as_a?.nil?
        dependency_list.as_a.each do |dependency|
          resolve_dependency(dependency.to_s)
        end
      end
    else
      resolve_dependency(package_name, development: as_dev)
    end
  end
end
