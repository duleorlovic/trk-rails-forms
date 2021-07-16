# Example apps

* https://github.com/duleorlovic/trk-rails-forms-hotwire-screencast-room-messages-scaffold
  sample app from Hotwired screencast https://hotwired.dev/#screencast
* spa todo app with bootstrap modals and inline editing

To create this example I used

```
rails new trk-rails-forms-hotwire-screencast-room-messages-scaffold --database=postgresql
```

Template to install this example to your application
```
rails app:template LOCATION="`pwd`_template.rb"
```

# Install hotwire

```
gem 'hotwire-rails'
# this includes stimulus-rails and turbo-rails gems

rails hotwire:install
# this will install stimulus and turbo https://github.com/hotwired/hotwire-rails/blob/28d25901c0b0b4492e473478e7e10ca9fc94213e/lib/tasks/hotwire_tasks.rake#L3
# there are two ways, using asset pipeline and webpacker
# Turbolinks is removed from Gemfile and from packs/application.js

rails turbo:install:asset_pipeline
# added to app/views/layouts/application.html.erb
# <%= turbo_inlude_tags %> this is old
<%= yield :head %>
<%= javascript_include_tag "turbo", type: "module" %>

rails turbo:install:webpacker
# Please check if this are added to app/javascript/packs/application.js
import '@hotwired/turbo-rails'
```

When we include Turbo in javascipt there is an issue with double click, double
request it seems that turbo frames does not work (it triggers only once) second
click on edit does nothing
One way to solve is to add response in controller
```
  format.turbo_stream { render turbo_stream: turbo_stream.replace("#{_params_step}-edit", template: "profile/#{_params_step}") }
```
https://github.com/hotwired/turbo-rails/issues/180

# Turbo Drive

https://turbo.hotwired.dev/handbook/drive

Turbo Drive is intercepting all clicks and form submittion. There are two type
of navigation:
* Application visits (advance or replace) always issues a network request (use a
  cached version before request arrives), if location includes an anchor, it
  will scroll to anchored element, and pushes new entry onto the browser's
  history stack using `history.pushState`. In js you can do with
  `Turbo.visit(location)`. You might want to discard topmost
  history entry and replace with new location `history.replaceState` with
  `data-turbo-action='replace'` tag or in js `Turbo.visit('/edit', {action:
  'replace' })`
* Restoration visit (restore) and using back or forward buttons. It uses a
  cached version (without attached event listeners since it was copied with
  `cloneNode(true)`).

In Rails console click GET requests are HTML and form PATCH/POST and GET after
redirection are TURBO_STREAM requests for ALL links and forms on the page.

You can cancel application visit by listening on `turbo:before-visit` event.

Disable Turbo Drive on specific links or forms using `data-turbo='false'` on any
parent element.

Progress bar is added automatically for request longer than 500ms

Assets loaded from `<head>` is reloaded on visits if you add
`data-turbo-track='reload'` for example
```
  <link rel="stylesheet" href="/application-258e88d.css" data-turbo-track="reload">
```
If you want some page to be fully reloaded each time you visit it, you can add
meta tag with name `turbo-visit-control` and content `reload` which is usefull
if javascript library does not work well with turbo drive visits
```
<head>
  <meta name="turbo-visit-control" content="reload">
</head>
```
If you want some path to be loaded without Turbo Drive you can change the root
so for example `/help` links will be loaded fullpage, but `/app` links with
turbo
```
<head>
  <meta name="turbo-root" content="/app">
</head>
```

After a POST form submittion, server should return 303 redirect response which
Turbo will follow and render its content. It can not render 200 response after
POST request because browsers have built-in behavior 'Are you sure you want to
submit this form again'. 4xx and 5xx are rendered so we can show validation
errors.

# Turbo Frames

https://turbo.hotwired.dev/handbook/frames

Turbo Frames is decomposing part of the page, so clicks and form submittion
happens only inside that frame, ie only the particular frame is extracted from
the response and replaced the existing content.
This enables: Efficient caching, parallelized loading lazy-loaded frames and
mobile ready since we decompose pages into frames.

Each frame has unique id
```
<body>
  <turbo-frame id='message_1'>
    <h1>My title</h1>
    <a href='/messages/1/edit'>Edit</a>
  </turbo-frame>
</body>
```
which is used to update with matching frame id in response
```
<body>
  <h1>Editing message</h1>
  <turbo-frame id='message_1'>
    <form action='/messages/1'>
      <input type='submit'>
    </form>
  </turbo-frame>
</body>
```

If you need a link to reload whole page you can add `data-turbo-frame': '_top'`
(similar as with iframes). You add that to attribute to specific links/forms or
to whole frame.

Turbo frame can be laizy (lazily) load with `src: template_path` attribute
Note that usually target attribute on turbo_frame_tag in response does
not have an effect, always define on frame that is first rendered (in this
example it is a class attribute)
```
<%= turbo_frame_tag 'new_message', src: new_room_message_path(@room), class: 'my-class' do %>
  <img src='spinner.gif'>
<% end %>
```

# Turbo Streams

https://turbo.hotwired.dev/handbook/streams

Turbo Streams is used to deliver live page changes. Basic actions: append
(added inside element at the end),
prepend, replace (outer html) update (inner content), remove, before (template
is added before element), after (inserted after element).
Example
```
<turbo-stream action="replace" target="message_1">
  <template>
    <div id="message_1">This changes the existing message!</div>
  </template>
</turbo-stream>
```
If you need to target multiple elements you can use `<turbo-stream
action='remove' targets='.old_records'>`

https://github.com/hotwired/turbo-rails gem provides helpers you can use in
rails instead of writting html.
```
# app/views/posts/create.turbo_stream.erb
<%= turbo_stream.append 'messages', @message %>

# or in app/controllers/messages_controller.rb
def create
  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: turbo_stream.append 'messages', partial: 'message', locals: { message: @message }
    end
  end
```

Note that stream actions are only for DOM changes, for advanced javascript
invocation use stimulus.

For example reset input when turbo finishes
```
export default class extends Controller {
  // This is called on form when we want to reset the input
  // <%= form_with ..., html: { 'data-controller': 'reset-form', 'data-action': 'turbo:submit-end->forms#reset' } do |f| %>
  reset() {
    this.element.reset()
  }
}
```

# Live page changes

For Live page changes we can use streaming over websocket with same stream
actions as with frames.

Use tag to create websocket connection with channel dom_id @room
```
<%= turbo_stream_from @room %>
```
If you do not see cable connection in Network tab that try to `rm -rf
public/packs`.

When using broadcast concern
https://github.com/hotwired/turbo-rails/blob/main/app/models/concerns/turbo/broadcastable.rb
First parameter is stream name (by default is currrent instance id, but in this
case it is `room.id`)

By default target is `model_name.plural` (in this case `messages`)
https://github.com/hotwired/turbo-rails/blob/main/app/models/concerns/turbo/broadcastable.rb#L68
By default it uses defalt partial (in this case
`app/views/messages/_message.html.erb`)
```
class Message < ApplicationRecord
  belongs_to :room
  # after_create_commit -> { broadcast_append_to room }
  # after_destroy_commit -> { broadcast_remove_to room }
  # after_update_commit -> { broadcast_replace_to room }
  broadcasts_to :room
end
```