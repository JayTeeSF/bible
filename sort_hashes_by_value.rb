#!/usr/bin/env ruby

require 'json'

bh = {}
File.readlines(ARGV[0]).each do |line|
  h_line = line.chomp
  warn("h_line: #{h_line.inspect}")
  mini_h = eval(h_line)
  bh[mini_h.keys.first] = mini_h.values.first.to_i
end

puts bh.sort_by {|_key, value| value }.reverse.to_h.inspect
