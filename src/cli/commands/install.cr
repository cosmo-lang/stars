require "file_utils"

module Stars::CLI::Command::Install
  extend self

  @@install_folder = File.expand_path File.join(CLI.path, ".stars")

  private def run_command(process : String, args : String, err_message : String, include_status = true) : Nil
    status = Process.run(process, args.split(' '))
    if status.to_s.split('\n').last.starts_with?("fatal:") || !status.success?
      abort Color.red("#{err_message}#{include_status ? ": #{status.exit_reason}" : ""}"), 1
    end
  end

  private def resolve_dependency(full_name : String) : Nil
    unless full_name.includes?('/')
      abort Color.red("Invalid package name. Correct format: \"author/package\""), 1
    end

    full_name += "@latest" unless full_name.includes?('@')
    full_name, version = full_name.split('@')
    _, package_name = full_name.split('/')
    package_install_folder = File.join @@install_folder, package_name

    # TODO: use API to get real repository name
    puts "Installing #{full_name}..."
    FileUtils.mkdir_p(package_install_folder)
    entries = Dir.entries(package_install_folder)
    if entries.empty?
      run_command("git", "clone https://github.com/#{full_name}.git #{@@install_folder}", "Failed to clone repository '#{full_name}'")
    else
      FileUtils.rm_rf File.join(package_install_folder, "star.lock")
      run_command("git", "pull origin master", "Failed to pull from repository '#{full_name}'.")
    end

    # TODO: lock versions
    puts "Fetching tags..."
    run_command("git", "fetch --tags", "Failed to fetch tags from repository '#{full_name}'")
    unless version == "latest"
      puts "Finding version tag..."
      run_command("git", "describe --tags --match #{version} --abbrev=0", "Version #{version} release tag does not exist on repository '#{full_name}'.", include_status: false)
      puts "Checking out version #{version}..."
      run_command("git", "checkout #{version}", "Failed to checkout tag #{version}")
    else
      puts "Finding version tag..."
      run_command("git", "describe --tags --abbrev=0", "No release tags exist on repository '#{full_name}'. Please create one and try again.", include_status: false)
    end

    puts Color.green "Successfully installed package #{full_name}@#{version}!"
  end

  def run(package_name : String?, no_dev = false) : Nil
    FileUtils.mkdir_p(@@install_folder)

    if package_name.nil?
      dependency_list = CLI.get_star_yml_field("dependencies", optional: true)

      unless no_dev
        dev_dependency_list = CLI.get_star_yml_field("dev_dependencies", optional: true)
        unless dev_dependency_list.nil? || dev_dependency_list.as_a?.nil?
          dev_dependency_list.as_a.each do |dev_dependency|
            resolve_dependency(dev_dependency.to_s)
          end
        end
      end

      unless dependency_list.nil? || dependency_list.as_a?.nil?
        dependency_list.as_a.each do |dependency|
          resolve_dependency(dependency.to_s)
        end
      end
    else
      resolve_dependency(package_name)
    end
  end
end
