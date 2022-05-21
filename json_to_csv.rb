#!/usr/bin/env ruby

require 'json'
require 'csv'

class J2C
  def self.run(input_file, output_file=nil)
    new(input_file, output_file).run
  end

  DEFAULT_OUTPUT_FILE = "myfile.csv"

  attr_reader :input_file, :output_file
  def initialize(input_file, output_file=nil)
    @input_file = input_file
    @output_file = output_file || DEFAULT_OUTPUT_FILE
    @data = []
  end

  def run
    puts({input_file: input_file, output_file: output_file})
    CSV.open(output_file, "w") do |csv|
      keys = nil
      File.readlines(input_file).each do |line|
        h = JSON.parse(line)
        unless keys
          keys = h.keys
	  csv << keys
        end
	csv << keys.map {|k| h[k] }
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  J2C.run(ARGV[0], ARGV[1])
end
