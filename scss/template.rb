def add_scss_template
  add_scss_directories
  add_scss_files
  import_scss_files
end

def add_scss_directories
  add_scss_directory "abstracts"
  add_scss_directory "base"
  add_scss_directory "components"
  add_scss_directory "layouts"
  add_scss_directory "pages"
end

def add_scss_files
  add_scss_file_to_directory("_variables", "abstracts")

  add_scss_file_to_directory("_base", "base")
  add_scss_file_to_directory("_typography", "base")
  add_scss_file_to_directory("_utilities", "base")

  add_scss_file_to_directory("_footer", "layouts")
  add_scss_file_to_directory("_header", "layouts")
end

def import_scss_files
  apply_page_reset_styling

  inject_into_file "app/javascript/stylesheets/application.scss" do
    <<-RUBY

@import "abstracts/variables";

@import "base/base";
@import "base/typography";
@import "base/utilities";

@import "layouts/footer";
@import "layouts/header";
    RUBY
end
end

def apply_page_reset_styling
  inject_into_file "app/javascript/stylesheets/base/_base.scss" do
    <<-RUBY
*,
*::before,
*::after {
  box-sizing: inherit;
  margin: 0;
  padding: 0;
}

html {
  font-size: 62.5%;
}

body {
  box-sizing: border-box;
}
  RUBY
end
end

def add_scss_directory(directory)
  run "mkdir app/javascript/stylesheets/#{directory}"
end

def add_scss_file_to_directory(file, directory)
  run "touch app/javascript/stylesheets/#{directory}/#{file}.scss"
end
