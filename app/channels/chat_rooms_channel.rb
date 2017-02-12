class ChatRoomsChannel < ApplicationCable::Channel
  #Use a strategy (lib/subscriber_tracker.rb) to keep track 
  #of the number of subscribers that have subcribed to each room. 
  #TODO Find a way to query the PUBSUB, so we don't have to maintain unncessary state
  RoomSubTracker = SubscriberTracker

  def subscribed
    @name = params['name']
    stream_from "chat_rooms_#{params['chat_room_id']}_channel"
    
    #Record Keeping
    record_added_subscription(params['chat_room_id'])
    current_sub_count = get_subscriptions_count(params['chat_room_id'])
    
    #Broadcast Calls
    person_joined_message(current_sub_count)
    update_count(current_sub_count)
  end
  
  def unsubscribed
    #Record Keeping
    record_removed_subscription(params['chat_room_id'])
    current_sub_count = get_subscriptions_count(params['chat_room_id']) 
     
    #Broadcast Calls
    person_left_message(current_sub_count+1)
    update_count(current_sub_count)
  end

  def send_message(data)
    # process data sent from the page
    ActionCable.server.broadcast "chat_rooms_#{data['chat_room_id']}_channel",
                                 message: data['message'], name: data['name']
  end
  

  private
  
  def record_added_subscription(room)
    RoomSubTracker.add_sub room
  end
  
  def get_subscriptions_count(room)
    RoomSubTracker.sub_count room
  end
  
  def record_removed_subscription(room)
    RoomSubTracker.remove_sub room
  end
  
  def update_count(count)
    ActionCable.server.broadcast "chat_rooms_#{params['chat_room_id']}_channel",
                                 count: count.to_s + (count > 1 ? ' people in the room' : ' person in the room') 
  end

  def person_joined_message(count)
    ActionCable.server.broadcast "chat_rooms_#{params['chat_room_id']}_channel",
                                 message: 'Welcome to the room, person ' + count.to_s + ' !', name: 'computer'
  end
  
  def person_left_message(count)
    ActionCable.server.broadcast "chat_rooms_#{params['chat_room_id']}_channel",
                                 message: 'Person ' + count.to_s + ' has left chat!', name: 'computer'
  end
end
