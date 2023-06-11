require "./cli"

module Stars
  API_URL = "http://localhost:3030/api/packages/"
end
Stars::CLI.run
