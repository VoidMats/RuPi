#!/usr/bin/env ruby

require './RupiParse.rb'
require './RupiMath.rb'
require './rdparse.rb'

class Rupi
    def done(str)
        ["quit","exit","bye",""].include?(str.chomp)
    end

    def terminal
        print_global
        puts ""
        print "[Rupi Rocks] "
        str = STDIN.gets
        if done(str) then
            puts "Bye."
        else
            begin
              puts " ==> #{@rupiParser.parse str}"
            rescue => error
                puts error.inspect
            end
            terminal
        end
    end

    def read_file(filename)
        if !File.file?(filename)
            puts "File does not exist or is not a file."
        else
            file = File.read(filename)
            puts "Debug is ON: #{@@our_debug}"
            if @@our_debug
                puts "Text to be parsed:"
                puts "="*28
                puts " #{file}"
                puts "="*28
            end
            save = @rupiParser.parse file
            puts save
        end
        print_global
    end

    def command(str)
      @rupiParser.parse str
    end

    def log(state=true, our_state=false)
        if state == true
            @rupiParser.logger.level = Logger::DEBUG
        else
            @rupiParser.logger.level = Logger::WARN
        end
        if our_state == true
            @rupiParser.set_debug true
        else
            @rupiParser.set_debug
        end
    end

    def print_global
      puts "="*28
      puts"Variables:"
      for item in @@variable_list[@@scope_no]
          puts"#{item}"
      end
      puts "="*28
      puts "Functions:"
      @@func_list.each {|k,v|
          puts ""
          puts"#{k}:"
          if v.para[0] == nil
              puts"  None"
          else
              v.para.each {|x| puts"  #{x.type} : #{x.name} : #{x.value}" }
          end
      }
      puts "="*28
    end

    # For debugging purpose
    def print_value(name)
      @@variable_list.at(@@scope_no)[name].value
    end
end
