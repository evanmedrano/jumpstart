def add_bootstrap_and_fontawesome_template
  log_status "Adding bootstrap and fontawesome files."

  yarn_install_bootstrap_and_fontawesome
  add_stylesheets_to_javascript_directory
  add_imports_to_application_scss
  setup_environment_js
  setup_application_js
  add_stylesheet_pack_tag
end

def yarn_install_bootstrap_and_fontawesome
  run "yarn add bootstrap jquery popper.js @fortawesome/fontawesome-free"
end

def add_stylesheets_to_javascript_directory
  run "mkdir app/javascript/stylesheets"
  run "touch app/javascript/stylesheets/application.scss"
end

def add_imports_to_application_scss
  inject_into_file "app/javascript/stylesheets/application.scss" do
    <<-RUBY
@import "~bootstrap/scss/bootstrap";
@import "@fortawesome/fontawesome-free";
    RUBY
  end
end

def setup_environment_js
  inject_into_file "config/webpack/environment.js",
    after: "const { environment } = require('@rails/webpacker')\n" do
    <<-RUBY
const webpack = require("webpack")

environment.plugins.append("Provide", new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default']
}))
    RUBY
  end
end

def setup_application_js
  inject_into_file "app/javascript/packs/application.js",
    after: "require(\"channels\")\n" do
    <<-RUBY
import "@fortawesome/fontawesome-free/js/all"
import "bootstrap"
import "../stylesheets/application"

document.addEventListener("turbolinks:load", () => {
  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover()
})
    RUBY
  end
end

def add_stylesheet_pack_tag
  inject_into_file "app/views/layouts/application.html.erb",
    after: "<%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>\n" do
      <<-RUBY
    <%= stylesheet_pack_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
      RUBY
  end
end
