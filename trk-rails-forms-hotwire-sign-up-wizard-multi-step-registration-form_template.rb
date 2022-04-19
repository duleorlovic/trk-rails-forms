# git add: '.'
# git commit: ' -m "rails new trk-rails-forms-hotwire-sign-up-wizard-multi-step-registration-form --database=postgresql"'
# this includes stimulus-rails and turbo-rails gems
gem 'hotwire-rails'

# this will run stimulus:install and turbo:install https://github.com/hotwired/hotwire-rails/blob/28d25901c0b0b4492e473478e7e10ca9fc94213e/lib/tasks/hotwire_tasks.rake#L3
rails_command 'hotwire:install'

gem 'bootstrap_form'

gem 'devise'
generate('devise:install')
generate(:devise, 'user')
generate(:model, 'company name')
generate(:migration, 'add_company_to_users company:references')
generate(:model, 'registration email company_name')
generate(:controller, 'home index')
route "root to: 'home#index'"

rails_command('db:create')
rails_command('db:migrate')

# add stimulus-use
run 'yarn add stimulus-use'

git add: '.'
git commit: " -m 'Template to install hotwire, devise, user, company and registration model'"
