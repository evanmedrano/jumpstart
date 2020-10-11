def add_rubocop
  run "touch .rubocop.yml"

  inject_into_file ".rubocop.yml" do
<<-'RUBOCOP'
AllCops:
  Exclude:
    - 'vendor/**/*'
    - 'spec/**/*'
    - 'bin/**/*'
    - 'db/**/*'
    - 'log/**/*'
    - 'public/**/*'
    - 'Gemfile'
    - '.irbrc'
    - 'Guardfile'
    - 'Rakefile'

Metrics/LineLength:
  Enabled: false

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
Naming/UncommunicativeMethodParamName:
  Enabled: false

# todo: enable this later
Layout/EmptyLines:
  Enabled: false

Layout/SpaceInsideHashLiteralBraces:
  EnforcedStyle: no_space
  EnforcedStyleForEmptyBraces: no_space

Layout/SpaceInsideBlockBraces:
  EnforcedStyle: space
  EnforcedStyleForEmptyBraces: no_space

# todo: how to prevent rubocop falsely finding "return and" pattern in rails
Style/AndOr:
  Enabled: false

Metrics/AbcSize:
  Max: 1000

Metrics/CyclomaticComplexity:
  Max: 210

Metrics/PerceivedComplexity:
  Max: 210
RUBOCOP
  end
end
