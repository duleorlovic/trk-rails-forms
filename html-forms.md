Form is not allowed to be a child of table, tbody, tr or ul so do not use forms
inside tables (except it is inside td) and list (except inside li)
https://stackoverflow.com/questions/5967564/form-inside-a-table


Code:
it is the same to have select multiple and bunch of select boxes

        <%= f.select :languages_spoken_at_home, ApplicationRecord.split_and_convert_to_hash(LANGUAGES), {include_blank: false}, class: 'form-control content-search', 'data-controller': 'select2', multiple: true %>
        <%# <% ApplicationRecord.split_and_convert_to_hash(LANGUAGES).values.each_with_index do |language,i| %1> %>
        <%#   <%= f.check_box 'languages_spoken_at_home', { multiple: true, label: language}, language, nil %1> %>
        <%# <% end %1> %>


* `"data-disable-with": "<i class='fa fa-spinner fa-spin'></i> #{name}"` works
on any element except `f.submit` since it is `input` element and you will see
`<i>` tags... better is to use `f.button` but than you lose `params[:commit]`
which is included in `f.submit`. So solution is to include `hidden_field_tag
:commit, "Some label"`
In form builder
```
# app/form_builders/my_form_builder.rb
class MyFormBuilder < BootstrapForm::FormBuilder
  # this will overwrite all f.submit form helpers. data-disable-with does not
  # work well when responding with csv so there you should explicitly disable:
  # <%= f.submit "Generate CSV", 'data-disable-with': nil %>
  def submit(name, options = {})
    options.reverse_merge! 'data-disable-with': "<i class='fa fa-spinner fa-spin'></i> #{name}"
    # "data-disable-with": "<i class='fa fa-spinner fa-spin'></i> #{name}"`
    # works on any element except `f.submit` since it is `input` element and you
    # will see `<i>` tags... solution is to use hiddent field (so we do not
    # lose params[:commit] which is included in f.submit)
    hidden_field_tag(:commit, name) +
      button(name, options)
  end
```

