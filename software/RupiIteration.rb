#! /usr/bin/env ruby
#-*- coding UTF-8 -*-

require './rupi.rb'

# @!attribute start
#   Contain the first intended loop. Index will be set to this value at start.
# @!attribute end
#   Contain the last intended loop. Index will follow each loop and have this value at end of iteration.
# @!attribute index
#   Contain the name of index used in the for iteration. New integer variable is created for each loop which will integrate with the RuPi code.
# @!attribute stmts
#   Contain the code to be executed.
class For_class

    # @example For iterator within Rupi
    #  int _i = 0;                         ==> Int_class<@value=0>
    #  array _my_array = [1,2,3,4];        ==> Array_class<@value=[1,2,3,4]>
    #  for 1,4 with _k { _i=_k; }          ==> Bool_class<@value=true>
    #  for 0,3 with _k {
    #    int _tmp = _my_array.at(_k);      ==> Bool_class<@value=true>
    #    _sum = _sum + _tmp;               ==> Bool_class<@value=true>
    #  }   #  _i                           ==> Int_class<@value=4>
    #  _sum                                ==> Int_class<@value=10>
    # @return [None] No return value from this method.
    # @raise [None] No error exception in this method.
    # @param i_start [Int_class] The first position of the index. The index will run from start to end
    # @param i_end [Int_class] End index value.
    # @param index [String_class] The name of the index which could be used in the For-loop.
    # @param stmts [Stmts_class] Contain the block of code which will be executed.
  def initialize(i_start, i_end, index, stmts)
    @start = convert_obj(i_start)
    @end = convert_obj(i_end)
    @index = index
    @stmts = stmts
  end

  # Method will execute a For-iteration within the Rupi-code.
  # Before all statements are runned the scope is increased with one step. Any variables created in this scope will be deleted at the end of the loop. For each iteration the index with name according to attribute @index will increase with one step. The index name could be used in the RuPi code to for example access elements in arrat. If the RuPi code contain any Return_class this will stop the eval method and return result of the Return_class.
  # @example Please see initialize of the class
  # @note The scope is created and deleted for each loop.
  # @note When the @stmts does have a Return_class this will be return, instead of Bool_class
  # @return [Bool_class] Return with value true if succeded. Otherwise an exception is raised.
  # @raise [All] The method will catch any error, bubbling up from the executed code.
  def eval
    begin
      self.debug_info
      index  = @start.value
      for idx in @start.value..@end.value do
        scope_increase
        Declare_class.new('int', @index, index).eval
        @stmts.eval
        index += 1
        scope_decrease
      end
    rescue => error
      puts error.inspect
    end
    return Bool_class.new('bool','TRUE')
  end

protected
# Method will print debug information for the user.
# Printed information as following:
# - Start index.
# - End index.
# - Content of the block.
# It's possible to switch the debug info ON/OFF with the global variable @@our_debug.
# @example Example of a debugging info from the For_class
#  ==> Eval For_class. Start idx 0, End idx 4
#  ==> Block content: stmts
# @return [None] No return value from this method.
# @raise [None] No error exception in this method.
  def debug_info
    if @@our_debug
      puts "#{debug_time} Eval For_class. Start idx #{@start.value}, End idx #{@end.value}"
      puts "#{debug_time} Block content: #{@stmts}"
    end
  end
end

# This class will execute a while iteration within RuPi code.
# @!attribute compare
#   Compare statement which will be made for each iteration.
# @!attribute stmts
#   Contain the code to be executed.
class While_class

  # @example While iterator within Rupi
  #  array _my_array = [1,2,3,4];         ==> Array_class<@value=[1,2,3,4]>
  #  int _i = 0;                          ==> Bool_class<@value=true>
  #  while(_i<_my_array.size()) {
  #     print(_my_array.at(_i));
  #     _i++;
  #  }
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param compare [Comp_class] The comparising made for each iteration.
  # @param stmts [Stmts_class] Contain the block of code which will be executed.
  def initialize(compare, stmts)
    @compare = compare
    @stmts = stmts
  end

  # Method will execute a while iteration within the Rupi-code.
  # Before all statements are runned the scope is increased with one step. Any variable created in this scope will be deleted at the end of the loop. The comparising is made in the beginning and will result in running either the block of statements or interupt the loop. If the RuPi code contain any Return_class this will stop the eval method and return result of the Return_class.
  # @example Please see initialize of the class
  # @note The scope is created and deleted for each loop.
  # @note When the @stmts does have a Return_class this will be return, instead of Bool_class
  # @return [Bool_class] Return with value true if succeded. Otherwise a return statement.
  # @raise [All] The method will catch any error, bubbling up from the executed code.
  def eval
    begin
      self.debug_info
      condition = @compare.eval
      while condition.value do
        scope_increase
        @stmts.eval
        condition = @compare.eval
        scope_decrease
      end
    rescue => error
      puts error.inspect
    end
    return Bool_class.new('bool','TRUE')
  end

protected
  # Method will print debug information for the user.
  # Printed information would the comparision being made on each loop and the block of code
  # which will be executed.The information could be turned ON/OFF with the global variable
  # @@our_debug.
  # @example Example of a debugging info from the For_class
  #  ==> Eval While_class <== 1<_x
  #  ==> Block content: int _i = 12;
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  def debug_info
    if @@our_debug
      puts "#{debug_time} Eval While_class <== #{@compare}"
      puts "#{debug_time} Block content: #{@stmts}"
    end
  end
end

# This class will execute a each iteration within RuPi code.
# @!attribute compare
#   Compare statement which will be made for each iteration.
# @!attribute index
#   Contain the name of the index used in the each iteration. New integer variable is created for each loop which will integrate with the RuPi code.
# @!attribute stmts
#   Contain the code to be executed.
class Each_class

  # @example Each iterator within Rupi
  #  array _my_array = [1,2,3,4];         ==> Array_class<@value=[1,2,3,4]>
  #  each _my_array with _i { _i++; };    ==> Bool_class<@value=true>
  #  _my_array                            ==> [2,3,4,5]
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param array [Array_class] Array used for the iteration
  # @param index [String_class] The name of the index which could be used in the iteration. The index holds the value of the element at that position.
  # @param stmts [Stmts_class] Contain the block of code which will be executed.
  def initialize(array, index, stmts)
    @array = array
    @index = index
    @stmts = stmts
  end

  # Method will execute a each iteration within the Rupi-code.
  # Before all statements are runned the scope is increased with one step. Any variable created in this scope will be deleted at the end of the loop. For each iteration a new variable is created which hold the element at that index. The If the RuPi code contain any Return_class this will stop the eval method and return result of the Return_class.
  # @example Please see initialize of the class
  # @note The scope is created and deleted for each loop.
  # @note When the @stmts does have a Return_class this will be return, instead of Bool_class
  # @return [Bool_class] Return with value true if succeded. Otherwise a return statement.
  # @raise [All] The method will catch any error, bubbling up from the executed code.
  def eval
    self.debug_info
    begin
      @array.value.each_with_index {|e,idx|
        scope_increase
        if e.instance_of? Fixnum
          Declare_class.new('int', @index, e).eval
        elsif e.instance_of? Float
          Declare_class.new('float', @index, e).eval
        else
          Declare_class.new(e.type, @index, e).eval
        end
        @stmts.eval
        @array.value[idx] = @@variable_list[@@scope_no][@index].eval.value
        scope_decrease
      }
      Bool_class.new('bool', 'TRUE')
    rescue => error
      puts error.inspect
    end
  end

protected
  # Method will print debug information for the user.
  # Printed information as following:
  # - The elements in the array in form of a Ruby Array
  # - Content of the block.
  # It's possible to switch the debug info ON/OFF with the global variable @@our_debug.
  # @example Example of a debugging info from the For_class
  #  ==> Eval Each_class <== [1,2,3,4]
  #  ==> Block content: stmts
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  def debug_info
    if @@our_debug
      puts "#{debug_time} Eval Each_class <== #{@array.value}"
      puts "#{debug_time} Block content: #{@stmts}"
    end
  end
end
