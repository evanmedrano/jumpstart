def add_code_to_scss_files
  add_scss_base
  add_scss_breakpoints
  add_scss_mixins
  add_scss_variables
  import_scss_files
end

def add_scss_base
  inject_into_file "app/javascript/stylesheets/base/_base.scss" do
    <<-SCSS
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
  SCSS
  end
end

def add_scss_breakpoints
  inject_into_file 'app/javascript/stylesheets/abstracts/_breakpoints.scss' do
    <<-SCSS
$breakpoints: (
  "sm": (
    min-width: 576px
  ),
  "md": (
    min-width: 768px
  ),
  "lg": (
    min-width: 992px
  ),
  "xl": (
    min-width: 1200px
  )
) !default;
  SCSS
  end
end

def add_scss_mixins
  inject_into_file 'app/javascript/stylesheets/abstracts/_mixins.scss' do
    <<-SCSS
// Margin
@mixin margin($top, $right, $bottom, $left) {
  margin-top: $top;
  margin-right: $right;
  margin-bottom: $bottom;
  margin-left: $left;
}

// Padding
@mixin padding($top, $right, $bottom, $left) {
  padding-top: $top;
  padding-right: $right;
  padding-bottom: $bottom;
  padding-left: $left;
}

// Responsive breakpoints
@mixin respond-to($breakpoint) {
  @if map-has-key($breakpoints, $breakpoint) {
      @media \#{inspect(map-get($breakpoints, $breakpoint))} {
        @content;
      }
  } @else {
      @warn "Unfortunately, no value could be retrieved from `\#{$breakpoint}`."
        + "Available breakpoints are: \#{map-keys($breakpoints)}.";
  }
}
  SCSS
  end
end

def add_scss_variables
  inject_into_file 'app/javascript/stylesheets/abstracts/_variables.scss' do
    <<-SCSS
// Type scale
$fs-1: 1rem;
$fs-2: 1.2rem;
$fs-3: 1.4rem;
$fs-4: 1.6rem;
$fs-5: 1.8rem;
$fs-6: 2.0rem;
$fs-7: 2.4rem;
$fs-8: 3.0rem;
$fs-9: 3.6rem;
$fs-10: 4.8rem;
$fs-11: 6.0rem;
$fs-12: 7.2rem;

// Spacing scale (su = spacing unit)
$su-1: .4rem;
$su-2: .8rem;
$su-3: 1.2rem;
$su-4: 1.6rem;
$su-5: 2.4rem;
$su-6: 3.2rem;
$su-7: 4.0rem;
$su-8: 4.8rem;
$su-9: 6.4rem;
$su-10: 9.6rem;

// Colors

// Neutrals
$neutral-100: hsl(149, 8%, 95%);
$neutral-200: hsl(149, 8%, 80%);
$neutral-300: hsl(149, 8%, 61%);
$neutral-400: hsl(149, 8%, 45%);
$neutral-500: hsl(149, 8%, 25%);

// BASIC
$black: hsl(0, 0, 0);
$white: hsl(0, 0, 100%);
  SCSS
  end
end

def import_scss_files
  inject_into_file "app/javascript/stylesheets/application.scss" do
    <<-SCSS

@import "abstracts/breakpoints";
@import "abstracts/mixins";
@import "abstracts/variables";

@import "base/base";
@import "base/typography";
@import "base/utilities";

@import "layouts/footer";
@import "layouts/header";
    SCSS
  end
end
