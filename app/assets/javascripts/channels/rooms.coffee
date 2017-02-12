gotoBottom = (id) ->
  element = document.getElementById(id);
  element.scrollTop = element.scrollHeight - element.clientHeight

timeNow = (i) ->
  d = new Date
  h = (if d.getHours() < 10 then '0' else '') + d.getHours()
  m = (if d.getMinutes() < 10 then '0' else '') + d.getMinutes()
  s = if d.getSeconds() < 10 then d.getSeconds() + '0' else d.getSeconds()
  h + ':' + m + ':' + s

random32String = () ->
  out = ''
  charSet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  i = 0
  while i < 9 
    randomPoz = Math.floor(Math.random() * charSet.length)
    out += charSet.substring(randomPoz, randomPoz + 1)
    i++
  out

url = null
recret = ''
App.name_of_speaker = random32String()

jQuery(document).on 'turbolinks:load', ->
  if $('#homepage').length > 0
    url ||= random32String()
    $('#chat-room').attr('href',url)
    $('#url').val( window.location + url)
  if $('#messages').length > 0
    messages = $('#messages')
    chat_room_id = $('ul').data('chat-room-id')
    App.room_chat = App.cable.subscriptions.create {
        channel: "ChatRoomsChannel",
        chat_room_id: chat_room_id,
        name: App.name_of_speaker 
      },
      connected: ->
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        if data['name']  == App.name_of_speaker  
          $('#chat-msg-container ul').append '<li class="me">'  + '<span class="time">' + timeNow() + '</span>' + data['message'] + "</li>"
        else if data['name'] == 'computer'
          $('#chat-msg-container ul').append '<li class="computer">'  + '<span class="time">' + timeNow() + '</span>' + data['message'] + "</li>"
        else if data['count'] 
          $('#count').text(data['count'])
        else
          $('#chat-msg-container ul').append '<li>'  + '<span class="time">' + timeNow() + '</span>' + data['message'] + "</li>"
        gotoBottom('chat-msg-container')

      send_message: (message, chat_room_id) ->
        @perform 'send_message', message: message, chat_room_id: chat_room_id, name: App.name_of_speaker
   
    $('#messages').keypress (e) ->
      if e.which == 13  && !e.shiftKey 
        message = $(this)
        textarea = message.find('#message_body')
        if $.trim(textarea.val()).length > 1
          App.room_chat.send_message textarea.val(), chat_room_id 
          textarea.val('')
          e.preventDefault() 
