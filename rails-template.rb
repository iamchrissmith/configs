### ~/.railsrc :
# -d postgresql #defaults my development database to PostgreSQL instead of SQLite3
# -T
# -m ~/Projects/configs/rails-template.rb
# --skip-turbolinks
# --skip-spring
### end ~/.railsrc

# Make directories relative for editing and creating files
def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

# Add Haml
gem "haml", "~> 5.0"

# Add following gems to dev and test groups
gem_group :development, :test do
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers'
  gem "factory_girl_rails", "~> 4.0"
  gem 'pry-rails'
  gem 'pry-state'
  gem 'pry-byebug'
  gem 'database_cleaner'
  gem 'erb2haml'
  gem 'rubocop'
end

# Bundle and generate rspec
run 'bundle install'
generate 'rspec:install'
# convert erbs to Haml
run 'rake haml:replace_erbs'

# setup rubocop config
run 'cp ~/Projects/configs/.rubocop.yml ./'
run 'cat "--require rails_helper" >> .rspec'
# configure testing gems
after_bundle do
insert_into_file 'spec/rails_helper.rb', after: "require 'rspec/rails'\n" do <<-RUBY
# Capybara
require 'capybara/rails'
# Require shoulda-matchers and config it with Rails and RSpec
require 'shoulda-matchers'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
RUBY
end

# Uncomment factory_girl dir expander
uncomment_lines 'spec/rails_helper.rb', /Dir\[Rails\.root\.join\('spec\/support\/\*\*\/\*\.rb'\)\]\.each \{ \|f\| require f \}/

# Get rid of byebug
comment_lines 'Gemfile', /gem \'byebug\'\, platforms\: \[\:mri\, \:mingw\, \:x64_mingw\]/

# Create factory_girl.rb and configure it with RSpec
file 'spec/support/factory_girl.rb', <<-RUBY
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
RUBY

end
