#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'

# 4chan category
url = "http://boards.4chan.org/b/"

# Visit imageboard
agent = Mechanize.new
agent.user_agent = 'w3m'
page = agent.get(url)

# Find out how many pages the imageboard has ; visit each one
replies = agent.page.links_with(:text => %r{^\d}, :href => %r{^\d+$}).each do |reply|
  link = "#{url}#{reply.href}"
  begin
    page = agent.get(link)  
  rescue Mechanize::ResponseCodeError
  end
  puts "Page: #{reply.href}"

  # Find image posts 
  replies = agent.page.links_with(:text => "Reply")

  # For each image post, click Reply and harvest image URLs
  replies.each do |reply|
    begin
      reply.click
    rescue Mechanize::ResponseCodeError
    end
    puts "Post ID: #{reply.href}"

    # Download all images on the page, try to ignore duplicates
    replies = agent.page.links_with(:text => %r{\d*.jpg$}, :href => %r{\/src\/\d*.jpg$})
    replies.each do |reply|
      link = "#{reply.href}"
      filename = File.basename(reply.href)

      # Skip the file if it exists
      if FileTest.exist?("#{filename}")
        puts "Skipping: #{link} - #{filename} exists"
        next
      end
      puts "Saving: #{link}"
      begin
        
        # Hash out the line below for a dry-run
        agent.get(link).save_as(filename)
      rescue Mechanize::ResponseCodeError
      end
    end
  end
end