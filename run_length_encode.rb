#!/usr/bin/env ruby

require 'json'
class RLE
  def self.help
    return <<-EOM
      $PROGRAM_NAME <file_name>*
      *file_name is a required option or you see this help message
       file must have one entry (letter, word, or phrase) per line ...each in sorted order
       this program will return a run length encoded list:
       [a a a] => [{a: 3}]
       [a b b c c c] => [a, {b: 2}, {c: 3}]
    EOM
  end

  def self.run(file_path=nil, lines: nil, trim_punct: true, lowercase: true)
    new(file_path, lines: lines, trim_punct: trim_punct, lowercase: lowercase).run
  end

  def initialize(file_path, lines: nil, trim_punct: true, lowercase: true)
    @file_path  = file_path
    @trim_punct = trim_punct
    @lowercase  = lowercase
    @lines      = lines
    trim_punct(lines)
  end

  
  def trim_punct(lines=@lines, lowercase=@lowercase)
    if @trim_punct && lines && !lines.empty?
      # any punct followed by a space:
      @lines = lines.map {|l| lowercase ? l.gsub(/[[:punct:]](\s+|$)/,'\1').downcase : l.gsub(/[[:punct:]](\s+|$)/,'\1') }
    end
  end

  def lines
    unless @lines
      @lines = File.readlines(@file_path).map(&:chomp)
      trim_punct(@lines)
    end
    @lines
  end

  def run
    last_line = nil
    repeat_count = 0
    record = {} # supports order
    output = []
    lines.each do |line|
      record[line] ||= 0
      record[line] += 1
    end
    record.each do |tok, ct|
      token = (ct <= 1) ? tok : {tok => ct}
      output << token
    end
    output
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.size > 0
    if ARGV.size < 3
    file_path = ARGV.shift
    results = RLE.run(file_path)
    if ARGV.size > 0
      puts results.to_json
    else
      puts results
    end
    else # at least 3 args ...must be words
      puts RLE.run(lines: ARGV, trim_punct: true)
    end
  else
    puts RLE.help
  end
end
