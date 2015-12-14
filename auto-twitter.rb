#!/usr/bin/env ruby

# Written by @Netuoso
# http://www.github.com/netuoso/auto-twitter

class TwitterStatus

  attr_reader :options, :rest_client, :streaming_client

  require 'twitter'
  require 'optparse'
  require 'pry'

  def initialize
    @options = {}
    # Make sure to configure your environment variables or hardcode your keys here
    @config = {consumer_key: ENV['TWITTER_CONSUMER_KEY'], 
               consumer_secret: ENV['TWITTER_CONSUMER_SECRET'],
               access_token: ENV['TWITTER_ACCESS_TOKEN'],
               access_token_secret: ENV['TWITTER_ACCESS_SECRET']}
    OptionParser.new do |opt|
      opt.on('-a', '--require ACTION', 'Action: [required] (String)') { |o| @options[:action] = o }
      opt.on('-d', '--data DATA', 'Data: [optional] (String)') { |o| @options[:data] = o }
      opt.on('-b', '--background BOOLEAN', 'Background: [optional] (Boolean)') { |o| @options[:background] = o }
    end.parse!

    @rest_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = @config[:consumer_key]
      config.consumer_secret     = @config[:consumer_secret]
      config.access_token        = @config[:access_token]
      config.access_token_secret = @config[:access_token_secret]
    end

    @streaming_client = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = @config[:consumer_key]
      config.consumer_secret     = @config[:consumer_secret]
      config.access_token        = @config[:access_token]
      config.access_token_secret = @config[:access_token_secret]
    end
  end

  def process
    if options.empty?
      p "Usage: #{__FILE__} -a action -d data"
      p "Debug: #{__FILE__} -a dev"
    else
      case options[:action]
      when 'tweet'
        raise 'data required when tweeting' unless options[:data]
        tweet(options[:data])
        p "Successfully tweeted #{options[:data].chars.count} characters."
      when 'stream'
        raise 'Process file exists. Is the script already running? If not, delete the twitter-status.pid file and rerun' if File.exists?('twitter-status.pid')
        pid = Process.fork { stream }
        write_pid(pid)
      when 'dev'
        # This method is for debugging and testing
        binding.pry
      else
        p OptionParser.new.permute(options)
      end
    end
  end

  private

  def tweet(data)
    rest_client.update(data)
  end

  def stream
    # Prepopulate some topics you are interested in
    topics = ["bitcoin", "hacking", "infosec", "security", "breaking news", "cybersecurity", "satoshi nakomoto", "financial tech",
              "defcon", "defcon parties", "hacking ctf", "new orleans tech", "silicon bayou", "technology", "fintech", "litecoin",
              "world news", "shocking", "computer virus", "malware", "adware", "ransomware", "crypto wall", "federal bureau", "techflavor com",
              "greyhatpro com", "nsa gov", "fbi gov"]
    # Get trending topics around a certain location; adjust the lat, long at will
    trend_location = rest_client.trends_closest(lat:40.7053094,long:-74.2588796).first.id
    rest_client.trends(trend_location).to_a.each do |trend|
      topics << trend.name
    end
    tweet_count = 0
    last_post = Time.now
    streaming_client.filter(track: topics.join(',')) do |obj|
      if obj.is_a?(Twitter::Tweet) && Time.now >= (last_post + rand(600..1800))
        rest_client.update(obj.text[0..139])
        tweet_count += 1
        puts "Tweet ##{tweet_count}: #{obj.text}" unless options[:background] == 'true'
        last_post = Time.now
        break if tweet_count == 6
      end
    end
    stream
  end

  def write_pid(pid)
    if options[:background] == 'true'
      pid_file = File.open('./auto-twitter.pid', 'w')
      pid_file.write(pid)
      pid_file.close
    end
  end

end

# Necessary monkey patch due to HTTP client Twitter gem depends on
class HTTP::URI                                                                                                                                                                                         
  def port                                                                                                                                                                                              
    443 if self.https?                                                                                                                                                                                  
  end                                                                                                                                                                                                   
end

TwitterStatus.new.process
