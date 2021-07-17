# this includes stimulus-rails and turbo-rails gems
gem 'hotwire-rails'

rails_command 'hotwire:install'
# this will run stimulus:install and turbo:install https://github.com/hotwired/hotwire-rails/blob/28d25901c0b0b4492e473478e7e10ca9fc94213e/lib/tasks/hotwire_tasks.rake#L3

environment <<~CODE
  config.generators do |generate|
    generate.jbuilder false
    generate.helper false
    generate.stylesheets false
    generate.test_framework nil
  end
CODE
generate(:scaffold, 'todo title:string completed:boolean')
rails_command('db:drop')
rails_command('db:create')
rails_command('db:migrate')

route "root to: 'todos#index'"

run 'yarn add bootstrap jquery @popperjs/core'

run 'echo import \"bootstrap\" >> app/javascript/packs/application.js'
run 'echo import \"stylesheet/application\" >> app/javascript/packs/application.js'

file 'app/javascript/stylesheet/application.scss', <<~CODE
  // node_modules
  @import 'bootstrap/scss/bootstrap';
CODE

insert_into_file 'app/views/layouts/application.html.erb', <<CODE, before: '  </head>'
    <%= stylesheet_pack_tag 'application', 'data-turbo-track': 'reload' %>
CODE

gsub_file 'app/views/layouts/application.html.erb', /.*yield.*/, <<CODE
    <div class='container'>
      <%= yield %>
    </div>
CODE

git add: '.'
git commit: " -m 'Template to install hotwire and bootstrap, generate todo scaffold'"
