#!/usr/bin/env ruby

require 'rubygems'
require 'chatterbot/dsl'

consumer_key ''
consumer_secret ''

secret ''
token ''

# remove this to update the db
no_update

# remove this to get less output when running
verbose

# here's a list of users to ignore
blacklist "abc", "def"

REPLY_THRESHOLD = 0.45
TIMELINE_THRESHOLD = 0.05
TIMELINE_WAIT = 0

$last_tweet_at = 0

def send_tweet(src)
  txt = [
         "burnnn"
        ].sample

  $last_tweet_at = Time.now.to_i
  puts "TWEETING #{tweet_user(src)} #{txt} from #{src.id}"

  x = client.update "#{tweet_user(src)} #{txt}",{:in_reply_to_status_id => src.id}
  puts x.inspect
end

while true do
  streaming(with:"followings") do
    followed do |user|
      follow user
    end
    

    timeline do |tweet|
      next if tweet.retweeted_status?
      puts "#{tweet.user.screen_name} -- #{tweet.text}"
      x = rand

   
      puts "#{x} <= #{timeline_chance}"
      # handle replies to the bot
      if tweet.text =~ /@wowwwburn/i && x <= REPLY_THRESHOLD
        send_tweet(tweet)
      else
        # cooldown period and make sure we ignore tweets from people
        # who don't follow the bot
        next if Time.now.to_i <= $last_tweet_at + TIMELINE_WAIT ||
                                                  ! client.friendship?(tweet.user, 'wowwwburn')


        # figure out the chance of replying to this tweet. it's a little
        # higher for other wowww bots
        timeline_chance = TIMELINE_THRESHOLD
        if tweet.text =~ /@wowww/ || tweet.user.screen_name =~ /wowww/
          timeline_chance = 0.4
        end

        if x <= timeline_chance
          send_tweet(tweet)
        end
      end
    end
  end 
  puts "oops something went wrong?!?!?!"
  sleep 20
end
