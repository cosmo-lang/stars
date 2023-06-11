require "./cli"

module Stars
  API_URL = "http://localhost:3000/api/packages/"
end
Stars::CLI.run
