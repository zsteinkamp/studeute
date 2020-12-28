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
  post_arr.push(post)
  post_hash[post['ID']] = post
end

# now true up revisions
post_arr.sort_by{ |p| [p['ID'].to_i]}.each do |post|
  if post['post_type'] == 'attachment' || post['post_status'] == 'draft'
    post_hash.delete(post['ID'])
  end
  if post['post_status'] == 'inherit' && post['post_type'] == 'revision'

    old_name = post_hash[post['post_parent']]['post_name']
    post['post_name'] = old_name

    old_date = post_hash[post['post_parent']]['post_date']
    post['post_date'] = old_date

    post_hash[post['post_parent']] = post
    post_hash.delete(post['ID'])
  end
  if post['post_content'] == ''
    post_hash.delete(post['ID'])
  end
  #puts "#{post['ID']} :: #{post['post_title']}"
end

post_hash.each do |id, post|
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

