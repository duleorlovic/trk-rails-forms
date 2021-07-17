# Rails Forms

Exaples includes basic html forms, nested attributes, Hotwire...

1. Basic html forms
1. Boostrap forms
1. Nested forms
1. Hotwire turbo frames and modal
1. Hotwire Todo app


# Development

To add new project use

```
rails new trk-rails-forms-new-example --database=postgresql
cd trk-rails-forms-new-example
git add .
git commit -am'rails new trk-rails-forms-new-example --database=postgresql'
git remote add origin git@github.com:duleorlovic/trk-rails-forms-new-example.git
git push origin master --set-upstream
cd ..
git submodule add git@github.com:duleorlovic/trk-rails-forms-new-example.git
git add .
git commit -am'Adding new example'
```

To apply example on some existing project (TODO: apply patch)
```
rails app:template LOCATION=https://github.com/duleorlovic/trk-rails-forms/trk-rails-forms-new-example_template.rb

# or if you are inside folder
rails app:template LOCATION="`pwd`_template.rb"
```

If you do not like long bash prompt you can change with this command
```
PS1="$ "
```
