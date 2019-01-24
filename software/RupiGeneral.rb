#! /usr/bin/env ruby
#-*- coding UTF-8 -*-

require './rupi.rb'

# This class will execute all statements within the Rupi code.
# @!attribute stmts
#   Contain several statements which will be executed with eval().
# @!attribute stmt
#   Contain one statement which will be executed with eval().
class Stmts_class

  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param stmts [Stmts_class] Contain the compare statement
  # @param stmt [Stmts_class] Contain the block of code which will be executed.
  def initialize(stmts,stmt)
    @stmts = stmts
    @stmt = stmt
  end

  # Method will execute several statements which has been created by the parser. .
  # This method is the most important in the whole RuPi language. This will trigger the chain of statements which has been made by the parser. This include the whole program as well as the block of code which has been parsed in for example if-statements.
  # @note The this evaluation will trigger the chain of statements.
  # @return [None] Return with value true if succeded. Otherwise false.
  # @raise [All] The method will catch any error, bubbling up from the executed code.
  def eval
      begin
        tmp = @stmts.eval
        if tmp.instance_of? Return_class
            if @@our_debug then puts "Return statement found" end
            tmp
        else
            @stmt.eval
        end
      rescue => error
        puts error.inspect
      end
  end
end

# This class will print text in the terminal.
# @!attribute text
#   Contain the text to be printed.
class Print_class

  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param text [String_class] Contain the text which will be printed.
  def initialize(text)
    @text = text
  end

  # Method will print text in terminal.
  # @return [Bool_class] Return with value true.
  def eval
    puts convert_obj(@text).value
    return Bool_class.new('bool','TRUE')
  end
end

# This class will sleep the ongoing process for time given.
# The user has to send which unit the value has (ms, s, min, h). The value is then recalculated to seconds. The limit for the hardware is around 20 ms switchingtime for a Raspberry Pi 2.
# @!attribute value
#   Contain the value which the process will sleep.
# @!attribute unit
#   Contain the unit of the value.
class Wait_class

  # @example Wait statement within Rupi
  #  wait(2,"s");                        ==> Bool_class<@value=true>
  #   ==> program stop for 2 seconds
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param value [Float_class] Contain the time.
  # @param unit [String_class] Contain the unit of the time.
  def initialize(value, unit)
    @value = value
    @unit = unit
  end

  # Method will execute an sleep method within the Rupi-code.
  # @example Please see initialize of the class
  # @return [Bool_class] Return with value true if succeded. Otherwise false.
  # @raise [All] The method will catch any error, bubbling up from the executed code.
  def eval
    begin
      re_calc = {'ms' => 0.01, 's' => 1, 'min' => 60, 'hour' => 3600}
      if !re_calc.has_key? @unit.value then
        raise ArgumentError, "Time unit has to be 'ms', 's', 'min','hour'" end
      time = convert_obj(@value).value * re_calc[@unit.value]
      if @@our_debug then puts "#{debug_time} Rupi will sleep for #{time} sec" end
      sleep time
      return Bool_class.new('bool', 'TRUE')
    rescue => error
      puts error.inspect
    end
  end
end

# This class will execute a return statement within the Rupi code.
# @!attribute [rw] value
#   Contain the compare statement which will be made.
class Return_class
    attr_reader :value

    # @return [None] No return value from this method.
    # @raise [None] No error exception in this method.
    # @param value [All] Contain return value which has been evaluated in a block of code.
    def initialize(value)
        @value = value
    end

    # Method will execute a return-statement within the Rupi-code.
    # @raise [None] No error exception in this method.
    # @raise [None] No error exception in this method.
    def eval
        @value = convert_obj(@value)
        self
    end
end

def func_exist?(name)
  return @@func_list.has_key?(name)
end

# Method will check if the varaible name already exist.
# @param name [String] Name of the variable
# @param scope [Int] Scope number where to start searching.
def var_exist?(name, scope=@@scope_no)
  scope.downto(0).each do |idx|
    if @@variable_list.at(idx).has_key?(name) then return idx end
  end
  return -1
end

# Method print the time in RuPi debug.
def debug_time
  t = Time.now
  return " RUPI DEBUG " + t.strftime("%H:%M:%S, %L -- : ").to_s
end

# Method increase the global scope with one step.
def scope_increase()
  @@scope_no += 1
  @@variable_list.push({})
  if @@our_debug then puts "#{debug_time} Increase the scope with 1 to #{@@scope_no}" end
  :ok
end

# Method decrease the global scope with one step.
def scope_decrease()
  @@variable_list.pop
  @@scope_no -= 1
  if @@our_debug then puts "#{debug_time} Decrease the scope with 1 to #{@@scope_no}" end
  :ok
end

# Method check the object and convert it to a Basic_container class. If the object is not a Basic_container class it will be run with eval. This method will insure that operations in the RuPi code is done correct.
def convert_obj(obj)
  if obj.kind_of? Basic_class
    return obj.eval
  elsif obj.instance_of? Variable_class
    return obj.eval
  elsif obj.kind_of? Basic_container
    return obj
  elsif obj.instance_of? Call_Func
    return obj.eval
  elsif obj.instance_of? Func_class
    return obj.eval
  elsif obj.instance_of? Return_class
    return obj.value
  elsif obj.instance_of? Comp_not_class
    return obj.value.eval
  else
    return obj
  end
  Bool_class.new('bool', 'FALSE')
end

# Method checks which Ruby variable the object contain and return  RuPi type to further process.
def check_type(obj)
  if obj.kind_of? Integer
    return 'int'
  elsif obj.kind_of? Float
    return 'float'
  elsif obj.instance_of? String
    return 'string'
  elsif obj.instance_of? TrueClass
    return 'bool'
  elsif obj.instance_of? FalseClass
    return 'bool'
  elsif obj.instance_of? Array
    return 'array'
  else
    raise TypeError, "check_type: Error - type of object does not exist"
  end
end
