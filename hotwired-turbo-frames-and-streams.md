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

In Rails log click GET requests are HTML and form PATCH/POST and GET after
redirection response are TURBO_STREAM requests for ALL links and forms on the
page.

You can cancel application visit by listening on `turbo:before-visit` event.

Disable Turbo Drive on specific links or forms using `data-turbo='false'` on any
parent element, for example on form
https://turbo.hotwire.dev/handbook/drive#disabling-turbo-drive-on-specific-links-or-forms
```
<%= form_with model: @member_profile, url: profile_update_path, method: :patch, html: { 'data-turbo': false } do |f| %>
```

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

After a POST form submittion, server should return 30x redirect response which
Turbo will follow and render its content. But if there is a second redirect,
turbo will not follow it.
It can not render 200 response after POST request because browsers have built-in
behavior 'Are you sure you want to submit this form again'.
4xx and 5xx are rendered so we can show validation errors.

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

When you need navigate out of the frame, for example full page than you can use
```
<turbo-frame id='set_aside_tray' target='_top'>
</turbo-frame>
```
Sometimes you want only particular links or forms to operate out of frame, in
that case use `'data-turbo-frame': '_top'` attribute. Also for link or form which
is outside of any frame, you can target it to specific frame by using
`'data-turbo-frame': 'modal'`.
You can target another frame:
```
<%= turbo_frame_tag 'new', target: 'modal' do %>
  <%= link_to 'New', new_todo_path %>
<% end %>
```
In this case, response should contain `<turbo-frame id='modal'>`
Note that double click does not work when it is the same url and response is 200
stateless GET.
It works fine if we have POST request for that target frame after click, than
clicking again will work normally, or if we have two different url (inside same
target frame) so we can click first, and than second, and again fist (click
twice on any link, second click will be ignored).
Only solution that I found is to redirect on server side.
https://github.com/hotwired/turbo/issues/249#issuecomment-881676935

Also when we include Turbo in javascript there is an issue with double
click/submit pair, it seems that turbo frames does not work (it triggers only
once for first click/submit) second pair click on edit does nothing.
One way to solve is to add response in controller
```
  format.turbo_stream { render turbo_stream: turbo_stream.replace("#{_params_step}-edit", template: "profile/#{_params_step}") }
```
https://github.com/hotwired/turbo-rails/issues/180


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
(added inside element at the end), prepend, replace (outer html) update (inner
content), remove, before (template is added before element), after (inserted
after element).
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

By default `target: model_name.plural` (in this case `messages`)
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

# Bootstrap modal todo app

*With forms you can update, and with streams you can create and delete while you
stay on the same page*

On index page, you can use one modal holder for all items or one modal for each
item.
If you choose to have separate modal for each item than you can set target on
frame element (from item to modal and from modal to item)
```
# app/views/todos/index.html.erb
<%= turbo_frame_tag "modal-#{todo.id}", target: "todo-frame-#{todo.id}" %>
<%= render todo %>

# app/views/todos/_todo.html.erb
<%= turbo_frame_tag "todo-frame-#{todo.id}", target: "modal-#{todo.id}" do %>
```
But simpler is to use one modal for all and differentiate items on a form using
a `data-turbo-frame` (also removing modals is faster since we have only one)
```
# app/views/todos/index.html.erb
<%= turbo_frame_tag 'modal %>
<%= render todo %>

# app/views/todos/_todo.html.erb
<%= turbo_frame_tag "todo-frame-#{todo.id}", target: 'modal' do %>
  <%= link_to 'Edit', edit_todo_path(todo), class: 'btn btn-primary' %>

# app/views/todos/edit.html.erb
<%= turbo_frame_tag 'modal' do %>
  <%= form_with model: @todo, html: { 'data-turbo-frame': "todo-frame-#{@todo.id}" } do |form| %>
```

Since we are using GET to fetch modal, turbo frame needs some redirection, so
you need to apply redirection patch
https://github.com/hotwired/turbo/issues/249#issuecomment-881676935

Edit/update is using frames, but for create and destroy we need to use
turbo_stream append and remove.

To open a modal we use stimulus connect callback.
There is an issue using back button since modal remains on the page (and it is
cached) and turbo-frame also get `src` attribute that loads the modal, we need
to close clear that before cache:
```
# app/javascript/controllers/start-modal-on-connect_controller.js

document.addEventListener("turbo:before-cache", function() {
  // remove modal since it will be opened automatically on connect
  // we need to do that by removing parent turbo-frame id='modal' which has src
  let modals = document.querySelectorAll('[data-controller="start-modal-on-connect"]')
  modals.forEach(function(modal) {
    let parentTurboFrame = modal.closest('turbo-frame')
    if (parentTurboFrame) {
      parentTurboFrame.innerHTML = ''
      parentTurboFrame.src = null
    } else {
      modal.remove()
    }
  })
})

export default class extends Controller {
  connect() {
    console.log('start-modal-on-connect#connect')
    let modal = new Modal(this.element)
    modal.show()
    // $(this.element).modal() // BS 4
  }

  close() {
    console.log('start-modal-on-connect#close')
    let modal = Modal.getInstance(this.element)
    modal.hide()
    // $(this.element).modal('hide') // BS 4
  }

  disconnect() {
    console.log('start-modal-on-connect#disconnect')
    // at this stage page it is already cached and it is about to be replaced
  }
}
```

# Signup wizard conditionally redirect

*Using stimulus you can update url while staying on the same page*


# Programatically submit turbo frame

I tried those commands https://discuss.hotwired.dev/t/triggering-turbo-frame-with-js/1622/12
```
// navigator.submitForm(form)
// Rails.fire(form, 'submit')
// this.formTarget.dispatchEvent(new CustomEvent('submit', { bubbles: true }))
```
but that does not work. The only solution is to hide submit button and click on
it
```
<%= f.submit 'OK', class: 'hide', 'data-message-chat-target': 'button' %>

static targets = [ 'button' ]
this.buttonTarget.click()
```

# Example apps

* https://github.com/duleorlovic/trk-rails-forms-hotwire-screencast-room-messages-scaffold
  sample app from Hotwired screencast https://hotwired.dev/#screencast
* https://github.com/duleorlovic/trk-rails-forms-hotwire-todo-app-bootstrap-modal
  spa todo app with bootstrap modals

https://discuss.hotwired.dev/t/a-to-do-list-application-created-with-hotwire/1827

https://www.reddit.com/r/rubyonrails/comments/kn36rm/i_created_a_beginner_friendly_hotwire_tutorial/
https://www.youtube.com/watch?v=QzMNO5DjOPQ
