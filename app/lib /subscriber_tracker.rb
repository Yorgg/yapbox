module SubscriberTracker
  #add a subscriber to a Chat rooms channel 
  def self.add_sub(room)
    count = sub_count(room)
    if count
      $redis.set(room, count + 1)
    else
      $redis.set(room,  1)
    end
  end
  
  def self.remove_sub(room)
    count = sub_count(room)
    if count == 1
      $redis.del(room)
    else
      $redis.set(room, count - 1)
    end
  end
  
  def self.sub_count(room)
    $redis.get(room).to_i
  end
end


