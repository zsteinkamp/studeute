#!/usr/bin/ruby

require 'csv'
require 'json'
require 'yaml'

post_hash = {}
post_arr = []

# initial load of post data into post_hash
csv_arr = CSV.read('posts.csv', headers: true, col_sep: ';', quote_char: '"')
csv_arr.each do |row|
  post = row.to_h
  if (post['post_type'] == 'post' && post['post_content'] != '')
    post['post_slug'] = post['post_title'].downcase.gsub(/[^a-z0-9]+/,'-')
    fname = "_posts/#{post['post_date'].split(' ')[0]}-#{post['post_slug']}.markdown"

    File.open(fname, 'w') do |out|
      out.puts "---"
      out.puts "layout: post"
      out.puts "title: #{post['post_title']}"
      out.puts "date: '#{post['post_date']}'"
      out.puts "---"
      out.puts post['post_content'].gsub('http://studeute.steinkamp.us/wp-content', '')
    end
  end
end
