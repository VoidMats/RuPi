#! /usr/bin/env ruby

require './RupiParse.rb'
require './RupiGeneral.rb'
require './RupiContainer.rb'
require './rupi.rb'

# This class will call a function within the Rupi code.
# @!attribute name
#   Contain the name of the function.
# @!attribute args
#   Contain the list of arguments passed to the function.
class Call_Func

    # @example Call of a function within RuPi.
    #  func Sum( int _a, int _b ) {
    #     int _c = _a + _b;
    #     return _c;
    #  };                                         ==> Bool_class<@value=true>
    #  int _number1 = 1;                          ==> Bool_class<@value=true>
    #  int _number2 = 2;                          ==> Bool_class<@value=true>
    #  int _summery = Sum(_number1, _number2);    ==> Bool_class<@value=true>
    #  _summery                                   ==> 3
    # @return [None] No return value from this method.
    # @raise [None] No error exception in this method.
    # @param name [String_class] Contain the name of the function to be called.
    # @param args [array] Contain the list of arguments that will be passed to the function.
    def initialize(name, args=nil)
        @name = name
        if !args.instance_of? Array
            @args = [args]
        else
            @args = args
        end
    end

    # Method will execute a function call within the Rupi-code.
    # The method check if the function name is stored in the global variable @@func_list. The argument list from the stored function is pulled out and checked if it needs eval(). Scope is increased and parameters are assigned. The block of code is executed and returned result will be passed further into the RuPi code.
    # @example Please see initialize of the class
    # @note When the block of statements does not have a Return_class a Bool_class will be return giving signal it was executed correct.
    # @return [All] Return with class from the executed block in function, otherwise Bool_class with value false.
    # @raise [All] The method will catch any error, bubbling up from the executed code.
    def eval
        begin
            if !func_exist?(@name)
                raise NameError, "Function #{@name} has not been declared."
            else
                if @@our_debug then puts "#{debug_time} Function called : #{@name}" end
                para = @@func_list[@name].para
                if @args[0] != nil and para[0] != nil
                    #Making sure we only get Basic_container type objects in @args
                    @args.each_with_index {|arg, idx| @args[idx] = convert_obj(arg)}
                    scope_increase
                    @@func_list[@name].para.each {|item| item.eval }
                    @args.each_with_index {|arg, idx|
                        Assign_class.new(para[idx].name, arg).eval
                    }
                elsif para[0] != nil
                    scope_increase
                    para.each {|item| item.eval }
                else
                    scope_increase
                end
                ret_value = @@func_list[@name].eval
                scope_decrease
                return convert_obj(ret_value)
            end
            Bool_class.new('bool', 'FALSE')
        rescue => error
            puts error.inspect
        end
    end
end

# This class will declare a function.
# @!attribute name
#   Contain the name of the function.
# @!attribute para
#   Contain the list of parameters used in the fuction.
# @!attribute block
#   Contain the block of code
class Dec_Func

    # @example Call of a function within RuPi.
    #  func Sum( int _a, int _b ) {
    #     int _c = _a + _b;
    #     return _c;
    #  };                                         ==> Bool_class<@value=true>
    #  int _number1 = 1;                          ==> Bool_class<@value=true>
    #  int _number2 = 2;                          ==> Bool_class<@value=true>
    #  int _summery = Sum(_number1, _number2);    ==> Bool_class<@value=true>
    #  _summery                                   ==> 3
    # @return [None] No return value from this method.
    # @raise [None] No error exception in this method.
    # @overload
    #   @param name [String_class] Contain the name of the function to be called.
    #   @param block [Stmts_class] Contain the block of statements which will be executed.
    #   @param para [array] Contain the list of arguments that will be passed to the function.
    # @overload
    #   @param name [String_class] Contain the name of the function to be called.
    #   @param block [Stmts_class] Contain the block of statements which will be executed.
    def initialize(name, block, para=nil)
        @name = name
        if !para.instance_of? Array
            @para = [para]
        else
            @para = para
        end
        @block = block
        return Bool_class.new('bool', 'TRUE')
    end


    def eval
        if @@func_list.has_key?(@name)
            raise NameError, "#{@name} : Function already declared"
        else
            @@func_list[@name] = Store_Func.new(@name, @block, @para)
        end
    end
end

# This class will store a function.
# @!attribute name
#   Contain the name of the function.
# @!attribute block
#   Contain the block of code
# @!attribute [rw] para
#   Contain the list of parameters used in the fuction.
class Store_Func
    attr_reader :para

    # @return [None] No return value from this method.
    # @raise [None] No error exception in this method.
    # @param name [String_class] Contain the name of the function.
    # @param para [list] Contain a list of parameters used in the function.
    # @param block [Stmts_class] Contain the block of code which will be executed.
    def initialize(name, block, para)
        @name = name
        @para = para
        @block = block
    end

    # Method will eval() the block of statements.
    def eval
        @block.eval
    end
end

# This class will call variablefunction.
# @!attribute name
#   Contain the name of the variable.
# @!attribute func
#   Contain the name of the function
# @!attribute args
#   Contain the list of arguments used in the function.
class Func_class

  # @example Please see each example for the class. Example string#add()
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param name [String_class] Contain the name of the variable.
  # @param func [String_list] Contain a name of the function .
  # @param block [list] Contain the list of arguments used in the function.
  def initialize(name, func, args=nil)
    @name = name
    @func = func
    @args = args
  end

  # Method will execute a varaiblefunction within the RuPi code.
  # The method check if the varaible name is stored in the global variable @@variable_list. The argument list is checked if it needs eval(). Scope is increased and the function is executed and returned result will be passed further into the RuPi code.
  # @return [Bool_class] Return with value true if succeded. Otherwise false.
  # @raise [RuntimeError] If the returned value from the function is nil, exception will be raised.
  # @raise [NameError] If the variable does not exist exception will be raised.
  def eval
    if @@our_debug then
      puts "#{debug_time} Call method from class #{@name} <== #{@func}(#{@args})"
    end
    # Check the argument list
    args = []         # Create a new array so it does not interfere with loops
    if @args.instance_of? Array then
      @args.each {|arg| args << convert_obj(arg) }
    elsif @args != nil then args = [convert_obj(@args)] end
    # Execute the method
    scope = var_exist? @name
    if scope != -1
      if @args == nil
        tmp = @@variable_list[scope][@name].send @func
      else
        tmp = @@variable_list[scope][@name].send @func, args
      end
      if tmp != nil
        if @@our_debug then puts "#{debug_time} Return from class method #{@name}.#{@func} <== #{tmp.value}" end
        return tmp
      else
        raise RuntimeError, "Function result is not correct. Func_class.eval"
      end
    else
      raise NameError, "Variable does not exist"
    end
  end
end
