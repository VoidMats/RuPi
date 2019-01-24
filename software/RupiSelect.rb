#! /usr/bin/env ruby

require './RupiParse.rb'
require './RupiGeneral.rb'

# This class will execute an If statement within the Rupi code.
# @!attribute compare
#   Contain the compare statement which will be made.
# @!attribute stmts
#   Contain the code to be executed if comparision is true.
class If_class

  # @example If statement within Rupi
  #  int _i = 2;                         ==> Int_class<@value=2>
  #  if( _i < 4) {
  #     _i++;                            ==> Bool_class<@value=true>
  #  }
  #  _i                                  ==> Int_class<@value=3>
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param compare [Comp_class] Contain the compare statement
  # @param stmts [Stmts_class] Contain the block of code which will be executed.
  def initialize(compare, stmts)
    @compare = compare
    @stmts = stmts
  end

  # Method will execute a if-statement within the Rupi-code.
  # Before all statements are runned the scope is increased with one step.
  # Any variables created in this scope will be deleted at the end of the loop. The comparising is made in the beginning and will result in running either if-statements or continue in the Rupi code. Does the if-statement contain any Return_class this will stop the eval method and return result of the Return_class.
  # @example Please see initialize of the class
  # @note The scope is created and deleted for each loop.
  # @note When the @stmts does have a Return_class this will be return, instead of Bool_class
  # @return [Bool_class] Return with value true if succeded. Otherwise false.
  # @raise [All] The method will catch any error, bubbling up from the executed code.
  def eval
    if convert_obj(@compare).value == true
      scope_increase
      ret_val = @stmts.eval
      self.debug_info
      scope_decrease
      if ret_val.instance_of? Return_class
          ret_val   #this propagates returnstatements out of if
      else
          Bool_class.new('bool', 'TRUE')
      end
    end
  end

protected
  # Method will print debug information for the user.
  # Printed information as following:
  # - That a If_class is executed.
  # - which variables are created in this scope.
  # The scope number is also printed. It's possible to switch the debug info ON/OFF with the global variable @@our_debug.
  # @example Example of a debugging info from the For_class
  #  ==> IF-statement executed
  #  ==> Variables created in this scope: 1
  #  ==> [<Bool_class, @type='bool', @name='tmp', @value=true>]
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  def debug_info
    if @@our_debug
      puts "#{debug_time} IF-statement executed"
      puts "#{debug_time} Variables created in this scope: "
      print "#{debug_time} #{@@variable_list[@@scope_no]}"
      puts ""
    end
  end
end

# This class will execute an If-else statement within the Rupi code.
# @!attribute compare
#   Contain the compare statement which will be made.
# @!attribute if_stmts
#   Contain the code to be executed if comparision is true.
# @!attribute else_stmts
#   Contain the code to be executed if comparision is false.
# @!attribute elif
#   Elif parameter will set the statement to be elif statement instead of a normal if-else statement.
class Else_class

  # @example If-else statement within Rupi
 #  int _i = 7;                         ==> Int_class<@value=7>
 #  if( _i < 4) {
 #     _i++;                            ==> Bool_class<@value=true>
 #  }
 #  else {
 #     _i--;
 # }
 #  _i                                  ==> Int_class<@value=6>
 # @return [None] No return value from this method.
 # @raise [None] No error exception in this method.
 # @overload new(compare, if_stmts, else_stmts)
 #   @param compare [Comp_class] Contain the compare statement
 #   @param if_stmts [Stmts_class] Contain the block of code which will be executed if compare is true.
 #   @param else_stmts [Stmts_class] Contain the block of code which will be executed if compare is false.
 # @overload new(compare, if_stmts, else_stmts, elif)
 #   @param compare [Comp_class] Contain the compare statement
 #   @param if_stmts [Stmts_class] Contain the block of code which will be executed if compare is true.
 #   @param else_stmts [Stmts_class] Contain the block of code which will be executed if compare is false.
 #   @param elif [Bool_class] Parameter which set the class to be elif statement or a normal if-else statement. With elif=true the scope will only increase ones.
  def initialize(compare, if_stmts, else_stmts, elif=false)
    @compare = compare
    @if_stmts = if_stmts
    @else_stmts = else_stmts
    @elif = elif
  end

  # Method will execute a else-statement within the Rupi-code.
  # Before all statements are runned the scope is increased with one step. Any variable
  # created in this scope will be deleted at the end of the loop. The comparising is made in the beginning and will result in running either if-statements or else-statements. Does the RuPi code contain any Return_class this will stop the eval method and return result of the Return_class.
  # @example Please see initialize of the class
  # @note The scope is created and deleted for each loop.
  # @note When the @stmts does have a Return_class this will be return, instead of Bool_class
  # @return [Bool_class] Return with value true if succeded. Otherwise false.
  # @raise [All] The method will catch any error, bubbling up from the executed code.
  def eval
    if convert_obj(@compare).value == true
        scope_increase
        ret_val = @if_stmts.eval
        self.debug_info("IF")
        scope_decrease
        if ret_val.instance_of? Return_class
            ret_val   #this propagates returnstatements out of if
        else
            Bool_class.new('bool', 'TRUE')
        end
    else
        if !@elif then scope_increase end
        ret_val = @else_stmts.eval
        self.debug_info("ELSE")
        if !@elif then scope_decrease end
        if ret_val.instance_of? Return_class
            ret_val   #this propagates returnstatements out of else
        else
            Bool_class.new('bool', 'TRUE')
        end
    end
  end

protected
  # Method will print debug information for the user.
  # Printed information as following:
  # - Which block is executed (IF or ELSE).
  # - Variables that are created in this scope.
  # - The scope number.
  # It's possible to switch the debug info ON/OFF with the global variable @@our_debug.
  # @example Example of a debugging info from the For_class
  #  ==> Executed IF-ELSE: IF block
  #  ==> Variables created in this scope: 1
  #  ==> [<Bool_class, @type='bool', @name='tmp', @value=true>]
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  def debug_info(text)
    if @@our_debug
      puts "#{debug_time} Executed IF-ELSE: #{text} block"
      puts "#{debug_time} Variables created in this scope: #{@@scope_no}"
      print "#{debug_time} #{@@variable_list[@@scope_no]}"
      puts ""
    end
  end
end
