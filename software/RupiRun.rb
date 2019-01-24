#! /usr/bin/env ruby
# *-* coding-UTF-8 *-*

require './rupi.rb'

filename = "test.txt"

if ARGV.length >= 1
    ret_value = ARGV[0]
    if ARGV.length == 2
        filename = ARGV[1]
    end
elsif ARGV.length > 2
    raise ArgumentError, "To many arguments"
else
    puts "*** Run program for Rupi ***"
    puts "="*28
    puts "Select terminal with Debug mode: 1"
    puts "Select terminal with Rupi debug mode: 2"
    puts "Select read file with Debug mode: 3"
    puts "Select read file with Rupi debug mode: 4"
    puts "Select read file with no debug mode: 5"
    print "Selected: "
    ret_value = STDIN.gets
    puts "="*28
end

rupi_run = Rupi.new

if ret_value.to_i == 1
  rupi_run.log(true,false)
  @@our_debug = false
  @@wiringpi = false
  rupi_run.terminal
elsif ret_value.to_i == 2
  rupi_run.log(false,true)
  @@our_debug = true
  @@wiringpi = false
  rupi_run.terminal
elsif ret_value.to_i == 3
  rupi_run.log(true, false)
  @@our_debug = false
  @@wiringpi = false
  rupi_run.read_file(filename)
elsif ret_value.to_i == 4
  rupi_run.log(false, true)
  @@our_debug = true
  @@wiringpi = false
  rupi_run.read_file(filename)
elsif ret_value.to_i == 5
  rupi_run.log(false, false)
  @@our_debug = false
  @@wiringpi = false
  rupi_run.read_file(filename)
end
