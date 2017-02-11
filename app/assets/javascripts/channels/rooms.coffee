jQuery(document).on 'turbolinks:load', ->
  if $('#messages').length > 0
    messages = $('#messages')
    chat_room_id = $('ul').data('chat-room-id')
    App.room_chat = App.cable.subscriptions.create {
        channel: "ChatRoomsChannel"
        chat_room_id: chat_room_id 
      },
      connected: ->
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        $('#msg-box ul').append data['message']

      send_message: (message, chat_room_id) ->
        @perform 'send_message', message: message, chat_room_id: chat_room_id
    
    $('#messages').submit (e) ->
      $this = $(this)
      textarea = $this.find('#message_body')
      if $.trim(textarea.val()).length > 1
        App.room_chat.send_message textarea.val(), chat_room_id 
        textarea.val('')
      e.preventDefault()
      return false

