def add_rubocop
  run "touch .rubocop.yml"

  inject_into_file ".rubocop.yml" do
<<-'RUBOCOP'
require:
  - rubocop-rails
  - rubocop-rspec

AllCops:
  NewCops: enable
  Exclude:
    - 'vendor/**/*'
    - 'bin/**/*'
    - 'db/**/*'
    - 'log/**/*'
    - 'public/**/*'
    - 'config/**/*'
    - 'node_modules/**/*'
    - 'Gemfile'
    - '.irbrc'
    - 'Guardfile'
    - 'Rakefile'
    - 'config.ru'

Metrics/ClassLength:
  Enabled: false

Metrics/BlockLength:
  Enabled: false

Metrics/MethodLength:
  Enabled: false

Metrics/ModuleLength:
  Enabled: false

Style/Documentation:
  Enabled: false

Layout/LineLength:
  Enabled: false

Layout/FirstParameterIndentation:
  Enabled: false

Style/SignalException:
  EnforcedStyle: only_fail

Style/StringLiterals:
  EnforcedStyle: single_quotes

Naming/VariableNumber:
  EnforcedStyle: snake_case

#TODO: enable later
Naming/MemoizedInstanceVariableName:
  Enabled: false

#TODO: enable later
Naming/MethodParameterName:
  Enabled: false

#TODO: enable this later
Layout/EmptyLines:
  Enabled: false

Layout/SpaceInsideHashLiteralBraces:
  EnforcedStyle: no_space
  EnforcedStyleForEmptyBraces: no_space

Layout/SpaceInsideBlockBraces:
  EnforcedStyle: space
  EnforcedStyleForEmptyBraces: no_space

#TODO: how to prevent rubocop falsely finding "return and" pattern in rails
Style/AndOr:
  Enabled: false

Metrics/AbcSize:
  Max: 1000

Metrics/CyclomaticComplexity:
  Max: 210

Metrics/PerceivedComplexity:
  Max: 210

RSpec/ImplicitExpect:
  Enabled: false
RUBOCOP
  end
end
