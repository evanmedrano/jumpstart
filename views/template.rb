require_relative "../support/logger"

def add_slim
  remove_generated_views
  add_new_views
  add_markup_to_views
end

def remove_generated_views
  remove_erb_view file_name: "application"
  remove_erb_view file_name: "mailer"
  remove_erb_view file_name: "mailer", file_type: "text"
end

def add_new_views
  add_header_partial
  add_slim_view file_name: "application"
  add_slim_view file_name: "mailer"
  add_slim_view file_name: "mailer", file_type: "text"
end

def add_markup_to_views
  add_application_slim_markup
  add_mailer_html_slim_markup
  add_mailer_text_slim_markup
end

def add_header_partial
  run "mkdir app/views/application"
  add_slim_view file_name: "_header", dir: "application"
end

def add_slim_view(file_name:, file_type: "html", dir: "layouts")
  run "touch app/views/#{dir}/#{file_name}.#{file_type}.slim"
end

def remove_erb_view(file_name:, file_type: "html")
  run "rm app/views/layouts/#{file_name}.#{file_type}.erb"
end

def add_application_slim_markup
  inject_into_file "app/views/layouts/application.html.slim" do
    <<-SLIM
doctype html
html
  head
    title = Rails.application.class.parent.to_s
    = csrf_meta_tags
    = csp_meta_tag

    = stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload'
    = stylesheet_pack_tag 'application', media: 'all', 'data-turbolinks-track': 'reload'
    = javascript_pack_tag 'application', 'data-turbolinks-track': 'reload'

  body
    = render 'header'

    - if flash.any?
      - flash.each do |key, value|
        .flash = value.html_safe

    = yield
    SLIM
  end
end

def add_mailer_html_slim_markup
  inject_into_file "app/views/layouts/mailer.html.slim" do
    <<-SLIM
doctype html
html
  head
    meta http-equiv="Content-Type" content="text/html; charset=utf-8"
    style
      / Email styles need to be inline

  body
    = yield
    SLIM
  end
end

def add_mailer_text_slim_markup
  inject_into_file "app/views/layouts/mailer.text.slim" do
    <<-SLIM
= yield
    SLIM
  end
end
