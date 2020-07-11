require_relative "code_for_files"

def add_scss_template
  log_status "Adding scss files."

  add_scss_directories
  add_scss_files
  add_code_to_scss_files
end

def add_scss_directories
  add_scss_directory "abstracts"
  add_scss_directory "base"
  add_scss_directory "components"
  add_scss_directory "layouts"
  add_scss_directory "pages"
end

def add_scss_files
  add_scss_file_to_directory(file: "_breakpoints", dir: "abstracts")
  add_scss_file_to_directory(file: "_mixins", dir: "abstracts")
  add_scss_file_to_directory(file: "_variables", dir: "abstracts")

  add_scss_file_to_directory(file: "_base", dir: "base")
  add_scss_file_to_directory(file: "_typography", dir: "base")
  add_scss_file_to_directory(file: "_utilities", dir: "base")

  add_scss_file_to_directory(file: "_footer", dir: "layouts")
  add_scss_file_to_directory(file: "_header", dir: "layouts")
end

def add_scss_directory(directory)
  run "mkdir app/javascript/stylesheets/#{directory}"
end

def add_scss_file_to_directory(file:, dir:)
  run "touch app/javascript/stylesheets/#{dir}/#{file}.scss"
end
