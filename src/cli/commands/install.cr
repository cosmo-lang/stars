require "file_utils"

module Stars::CLI::Command::Install
  extend self

  @@install_folder = File.expand_path File.join(CLI.path, ".stars")

  private def run_command(process : String, args : String, err_message : String, include_status = true) : String
    output = IO::Memory.new
    status = Process.run(process, args.split(' '), output: output)

    if status.to_s.split('\n').last.starts_with?("fatal:") || !status.success?
      CLI.fatal "#{err_message}#{include_status ? ": #{status.exit_reason}" : ""}"
    end

    output.to_s
  end

  private def verify_version(version : String) : Nil
    expected_version = CLI.get_star_yml_field("version").to_s

    # TODO: handle version schemes like ~ and ^
    unless version == expected_version
      CLI.fatal "Version mismatch. Expected version matching '#{expected_version}' but got '#{version}'."
    end
  end

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
    FileUtils.mkdir_p(package_install_folder)
    entries = Dir.entries(package_install_folder)
    package = API.fetch_package(author_name, package_name)
    repo_name = package.repository
    if entries.empty?
      run_command("git", "clone https://github.com/#{repo_name}.git #{@@install_folder}", "Failed to clone repository '#{repo_name}'")
    else
      FileUtils.rm_rf File.join(package_install_folder, "star.lock")
      run_command("git", "pull origin master", "Failed to pull from repository '#{repo_name}'.")
    end

    puts "Fetching tags..."
    run_command("git", "fetch --tags", "Failed to fetch tags from repository '#{repo_name}'")
    unless version == "latest"
      puts "Finding version tag..."
      version = run_command("git", "describe --tags --match #{version} --abbrev=0", "Version #{version} release tag does not exist on repository '#{repo_name}'.", include_status: false)
      verify_version(version)
      puts "Checking out version #{version}..."
      run_command("git", "checkout #{version}", "Failed to checkout tag #{version}")
    else
      puts "Finding version tag..."
      version = run_command("git", "describe --tags --abbrev=0", "No release tags exist on repository '#{repo_name}'. Please create one and try again.", include_status: false)
      verify_version(version)
    end

    dependency_list = CLI.get_star_yml_field("dependencies", optional: true)
    if dependency_list.nil?
      dependency_list = {} of String => String
    else
      new_dependency_list = dependency_list.as_h
      new_dependency_list[YAML::Any.new(full_name)] = YAML::Any.new(version)
      CLI.set_star_yml_field("dependencies", YAML::Any.new(new_dependency_list))
    end

    # TODO: lock versions
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
