git add: '.'
git commit: ' -m "rails new trk-rails-forms-hotwire-screencast-room-messages-scaffold --database=postgresql"'
# this includes stimulus-rails and turbo-rails gems
gem 'hotwire-rails'

# this will run stimulus:install and turbo:install https://github.com/hotwired/hotwire-rails/blob/28d25901c0b0b4492e473478e7e10ca9fc94213e/lib/tasks/hotwire_tasks.rake#L3
rails_command 'hotwire:install'

generate(:scaffold, 'room name:string')
generate(:model, 'message room:references content:text')
rails_command('db:migrate')

git add: '.'
git commit: " -m 'Template to install hotwire, generate room scaffold and message model'"
