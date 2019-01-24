#! /usr/bin/env ruby
# script prepare for YARD 0.9.12

require './RupiParse.rb'
require './RupiGeneral.rb'

# Basic container class used by Interger/Floating/String/Bool etc.
# @!attribute [r] type
#   Contain the type of the variable. 'bool','string','int','float', 'array'
# @!attribute [rw] value
#   Contain the value of the variable. Example 3 for an Integer.
# @!attribute [rw] name
#   Contain the name of the variable. This is also the same name which the variable is stored under in global @@variable_list.
class Basic_container
  attr_accessor :name, :value
  attr_reader :type

  # @example Please see example on each variable type
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param type [String_class] Saved variable type.
  # @param value [All] Value of the variable. Value depend on type of variable and is set by the set_value() method to insure safe handling.
  # @param name [String_class] Name of the variable. If the variable has not been declared it will have the name 'tmp'
  def initialize(type, value, name='tmp')
    @type = type
    @value = self.set_value(value)
    @name = name
  end
end

# Class will declare a variable within RuPi
# @!attribute [rw] type
#   Contain the type of the variable. 'bool','string','int','float', 'array'
# @!attribute [rw] value
#   Contain the value of the variable. Example 3 for an Integer.
# @!attribute [rw] name
#   Contain the name of the variable. This is also the same name which the variable is stored under in global @@variable_list.
class Declare_class
  attr_accessor :type, :value, :name

  # @example
  #  int _i = 12;                     ==> Bool_class<@value=true>
  #  _i                               ==> 12
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param type [String_class] Saved variable type.
  # @param value [All] Value of the variable which will be used in RuPi.
  # @param name [String_class] Name of the variable in RuPi.
  def initialize(type, name, value)
    @type = type
    @name = name
    @value = value
  end

  # Method will execute a declare statement of a variable.
  # A variable will be created in the global @@variable_list with the scope number which is active. Before the varaible is created there is a check if the it already exist.
  # @example Please see initialize of the class
  # @note The variable is created in the scope which is active.
  # @return [Bool_class] Return with value true if succeded. Otherwise a return statement.
  # @raise [All] The method will catch any error, bubbling up from the executed code.
  def eval
    if @@variable_list.at(@@scope_no).has_key?(@name)
        raise NameError, 'Variable already exist in this scope'
    else
        @@variable_list[@@scope_no][@name] = declare_var(@type,@name,convert_obj(@value))
        if @@our_debug then "#{debug_time} Eval Declare_class #{@type} #{@name} <== #{@value}" end
        return Bool_class.new('bool','TRUE')
    end
    return Bool_class.new('bool', 'FALSE')
  end
end

# This method check the type and return a new variable of the correct type.
def declare_var(type, name, value)
  converted_obj = convert_obj(value)
  if type == 'int'
    if converted_obj.instance_of? Int_class
      converted_obj.name = name
      ret_value = value
    else
      ret_value = Int_class.new(type, value, name)
    end
  elsif type == 'bool'
    if converted_obj.instance_of? Bool_class
      converted_obj.name = name
      ret_value = value
    else
      ret_value = Bool_class.new(type, value, name)
    end
  elsif type == 'float'
    if converted_obj.instance_of? Float_class
      converted_obj.name = name
      ret_value = value
    else
      ret_value = Float_class.new(type, value, name)
    end
  elsif type == 'string'
    if converted_obj.instance_of? String_class
      converted_obj.name = name
      ret_value = value
    else
      ret_value = String_class.new(type, value, name)
    end
  elsif type == 'array'
    if converted_obj.instance_of? Array_class
      converted_obj.name = name
      ret_value = value
    else
      ret_value = Array_class.new(type, value, name)
    end
  end
  if @@our_debug then puts "#{debug_time} Declare #{name} <== #{ret_value} <== #{ret_value.value}" end
  return ret_value
end

# Class will return the value from a RuPi varaible.
# @!attribute [r] value
#   Return the value of the varaible
# @!attribute [r] type
#   Return the type of the variable in form of a string, 'bool', 'int', 'string' etc.
class Variable_class

  # @example Get the value from a variable within RuPi.
  #  int _number1 = 1;                          ==> Bool_class<@value=true>
  #  _number1                                   ==> 1
  #  int _number2 = 2;                          ==> Bool_class<@value=true>
  #  _number2                                   ==> 2
  #  int _summery = _number1 + _number2;        ==> Bool_class<@value=true>
  #  _summery                                   ==> 3
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param name [String_class] Contain the name of the variable
  def initialize(name)
    @name = name
  end

  # Return the value from the name in global @@variable_list
  def value
    scope = var_exist? @name
    if scope != -1
        @value = @@variable_list[scope][@name].value
    else
        raise NameError, 'Variable does not exist'
    end
    return @value
  end

  # Return which type the variable is from the global @@variable_list.
  def type
    scope = var_exist? @name
    if scope != -1
        @type = @@variable_list[scope][@name]
    else
        raise NameError, 'Variable does not exist'
    end
    return @type
  end

  # Method will execute a return variable value within the Rupi-code.
  # Method check if the varaible has been declared and stored in the global @@variable_list.
  # @example Please see initialize of the class
  # @return [All] Return with the container class stored in the global @@variable_list.
  # @raise [All] The method will catch any error, bubbling up from the executed code.
  def eval
    begin
      scope = var_exist? @name
      if scope != -1
        ret_value = @@variable_list[scope][@name]
        if @@our_debug then puts "#{debug_time} Return #{ret_value} <== #{ret_value.value}" end
      else
        raise NameError, 'Variable does not exist'
      end
      return ret_value
    rescue => error
      puts error.inspect
    end
  end
end

# The class will assign a varaible with a new value
class Assign_class

  # @example Assign a variable within RuPi
  #  int _number1 = 1;                          ==> Bool_class<@value=true>
  #  int _number2 = 2;                          ==> Bool_class<@value=true>
  #  _summer1 = _number2;                       ==> Bool_class<@value=true>
  #  _summery1                                  ==> 2
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param name [String_class] Contain the name of the function to be called.
  # @param value [All] Contain the value according to the container class.
  def initialize(name, value)
    @name = name
    @value = value
  end

  # Method will assign a varaible with a new value.
  # The method check if the variable exist and if so, assign the new value. If the new value is of wrong type this will be raised by the Basic_container class.
  # @example Please see initialize of the class
  # @note Variable type 'channel' is immutable and will not be assign a new value.
  # @return [All] Return with class from the executed block in function, otherwise Bool_class with value false.
  # @raise [All] The method will catch any error, bubbling up from the executed code.
  def eval
    begin
      scope = var_exist? @name
      if scope != -1
        if @@variable_list[scope][@name].type == 'channel' then
          raise TypeError, "Variable type 'channel' is immutable" end
        tmp = convert_obj(@value)
        if @@our_debug then puts "#{debug_time} Assign #{@name} <== #{tmp.value}" end
        @@variable_list[scope][@name].set_value(tmp, true)
        return Bool_class.new('bool', 'TRUE')
      else
        raise NameError, 'Variable does not exist'
      end
      return Bool_class.new('bool', 'FALSE')
    rescue => error
      puts error.inspect
    end
  end
end

# Class for the float varaible
class Float_class < Basic_container

  # Method will return it self
  # @return [Float_class] Eval will return it self.
  def eval
    if @@our_debug then puts "#{debug_time} Eval Float_class #{@name} <== -#{@value}" end
    return self
  end

  # Method will set a new value in the Basic_container class.
  # @return [None] No return value from this method.
  # @raise [TypeError] If the new value is of the wrong type. This will be raised.
  # @overload set_value(new_value, assign)
  #   @param new_value [Float_class] Contain the new Float_class
  #   @param assign [true/false] The new value is passed from an Assign_class. This value will be true (Ruby variable).
  # @overload set_value(new_value)
  #   @param new_value [Float_class] Contain the new Float_class
  def set_value(new_value, assign=false)
    if new_value.instance_of? Log_class
      raise TypeError, "Float_class: Error - compare expression does not convert float. "
    elsif new_value.kind_of? Basic_class
      @value = new_value.eval
    elsif new_value.instance_of? Variable_class
      @value = new_value
    elsif new_value.instance_of? Bool_class
      raise TypeError, "Float_class: Error - Bool_class does not convert to float."
    elsif new_value.kind_of? Basic_container
      @value = new_value.value.to_f
    elsif new_value.instance_of? Comp_not_class
      raise TypeError, "Float_class: Error - compare expression does not convert to float. "
    else
      @value = new_value
    end
  end

  # Method clear the value to 0.0
  def clear
    @value = 0.0
  end
end

# Class for the integer variable
class Int_class < Basic_container

  # Method will return it self
  # @return [Int_class] Eval will return it self.
  def eval
    if @@our_debug then puts "#{debug_time} Eval Int_class #{@name} <== #{@value}" end
    return self
  end

  # Method will set a new value in the Basic_container class.
  # @return [None] No return value from this method.
  # @raise [TypeError] If the new value is of the wrong type. This will be raised.
  # @overload set_value(new_value, assign)
  #   @param new_value [Int_class] Contain the new Int_class
  #   @param assign [true/false] The new value is passed from an Assign_class. This value will be true (Ruby variable).
  # @overload set_value(new_value)
  #   @param new_value [Int_class] Contain the new Int_class
  def set_value(new_value, assign=false)
    if new_value.instance_of? Log_class
      raise TypeError, "Int_class: Error - compare expression does not convert to int."
    elsif new_value.kind_of? Basic_class
      @value = new_value.eval
    elsif new_value.instance_of? Variable_class
      @value = new_value
    elsif new_value.instance_of? Bool_class
      raise TypeError, "Int_class: Error - Bool_class does not convert to int."
    elsif new_value.kind_of? Basic_container
      @value = new_value.value.to_i
    elsif new_value.instance_of? Comp_not_class
      raise TypeError, "Int_class: Error - compare expression does not convert to int."
    else
      if new_value.kind_of? Basic_class
        @value = new_value.eval
      elsif new_value.instance_of? Variable_class
        @value = new_value
      elsif new_value.kind_of? Basic_container
        @value = new_value.value.to_i
      else
        @value = new_value
      end
    end
  end

  # Method clear the value to 0
  def clear
    @value = 0
  end
end

# Class for the boolean variable
class Bool_class < Basic_container

  # Method will return it self
  # @return [Bool_class] Eval will return it self.
  def eval
    if @@our_debug then puts "#{debug_time} Eval Bool_class #{@name} <== #{@value}" end
    return self
  end

  # Method will set a new value in the Basic_container class.
  # @return [None] No return value from this method.
  # @raise [RangeError] If the new value is of the wrong type it will be rasied as RangeError.
  # @overload set_value(new_value, assign)
  #   @param new_value [Bool_class] Contain the new Bool_class
  #   @param assign [true/false] The new value is passed from an Assign_class. This value will be true (Ruby variable).
  # @overload set_value(new_value)
  #   @param new_value [Bool_class] Contain the new Bool_class
  def set_value(new_value, assign=false)
    if new_value.kind_of? Basic_class
      tmp = new_value.eval
    elsif new_value.instance_of? Variable_class
      tmp = new_value
    elsif new_value.kind_of? Bool_class
      tmp = new_value.value
    elsif new_value.instance_of? Comp_not_class
      tmp = new_value.eval
    else
      if !assign
        tmp = new_value
      else
        tmp = convert_obj(new_value).value
      end
    end
    if tmp == "TRUE" || tmp == true
      @value = true
    elsif tmp == "FALSE" || tmp == false
      @value = false
    else
      raise RangeError, "Bool_class: Error - Value is out range or of wrong type. It has to be either TRUE or FALSE"
    end
  end

  # The method clear the value to false
  def clear
    @value = false
  end
end

# Class for the string variable
class String_class < Basic_container

  # Method will return it self
  # @return [Bool_class] Eval will return it self.
  def eval
    if @@our_debug then puts "#{debug_time} Eval String_class #{@name} <== #{@value}" end
    return self
  end

  # Method will set a new value in the Basic_container class.
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @overload set_value(new_value, assign)
  #   @param new_value [String_class] Contain the new String_class
  #   @param assign [true/false] The new value is passed from an Assign_class. This value will be true (Ruby variable).
  # @overload set_value(new_value)
  #   @param new_value [String_class] Contain the new String_class
  def set_value(new_value, assign=false)
    if new_value.kind_of? Basic_class
      @value = new_value.eval.to_s
    elsif new_value.instance_of? Variable_class
      @value = new_value
    elsif new_value.kind_of? Basic_container
      @value = new_value.value.to_s
    elsif new_value.instance_of? Comp_not_class
      @value = new_value.eval.to_s
    else
      if !assign
        new_value = new_value.chop
        @value = new_value[1..-1]
      else
        @value = new_value.value
      end
    end
  end

  # Method will add a second string on an existing string.
  # String will be inserted at the end of the first string. This method will not modify the new string, as removing or strip any whitespace etc. Method add() should be used instead of string + string, which does not compile in RuPi. The string can only be inserted at the last index in form of a varialbe or a raw text.
  # @example Text will be appended to the string
  #  string _my_string = "text"               ==> String_class<@value=text>
  #  string _my_string2 = "2"                 ==> String_class<@value=2>
  #  _my_string.add(" more text")             ==> String_class<@value=text more text>
  #  _my_string.add(_my_string2)              ==> String_class<@value=text more text2>
  #  _my_string                               ==> text more text
  #  _my_string2                              ==> text more text2
  # @return [Bool_class] Return object will be a Bool_class with true if all executed correct.
  # @raise [ArgumentError] If passed arguments are more then one, ArgumentError will be raised.
  # @param text [String_class] The string which will be appended to the main string.
  def add(args)
    #Arguments: added string
    if @@our_debug then puts "#{debug_time} String_class method add <== #{args}" end
    if convert_obj(args[0]).instance_of?(String_class) && args.size == 1
      @value << convert_obj(args[0]).value
    else
      raise ArgumentError, "Wrong number of arguments for String_class.add"
    end
    return Bool_class.new('bool', 'TRUE')
  end

  # Method will remove trailing whitespaces.
  # This method will not modify the text but only remove the whitetespace after the text. Method will not remove any whitetespace before the text, please use lstrip for that.
  # @example Removing trailing whitespaces with strip
  #  string _my_string = "text     "          ==> String_class<@value=text     >
  #  string _my_string2 = "2"                 ==> String_class<@value=2>
  #  string _my_string3 = "text     "         ==> String_class<@value=text     >
  #  _my_string.add(_my_string2)              ==> String_class<@value=text     2>
  #  _my_string3.rstrip()                     ==> String_class<@value=text>
  #  _my_string3.add(_my_string2)             ==> String_class<@value=text2>
  #  _my_string3                              ==> text2
  # @return [Bool_class] Return object will be a Bool_class with true if all executed correct.
  # @raise [LocalJumpError] If program reach a none existing position in the code.
  def rstrip
    tmp = @value.rstrip!
    if @@our_debug then puts "#{debug_time} String_class method rstrip <== #{tmp}" end
    if tmp != nil
      return Bool_class.new('bool', 'TRUE')
    else
      return Bool_class.new('bool', 'FALSE')
    end
    raise LocalJumpError, "Compiler reach a none existing position. String_class.rstrip"
  end

  # Method will remove whitespaces from beginning of the string.
  # This method will not modify the text but only remove the whitespaces infront of the text. Method will not remove any whitespaces after the text.
  # @example Removing whitespaces with strip
  #  string _my_string = "text     "          ==> String_class<@value=text     >
  #  string _my_string2 = "2"                 ==> String_class<@value=2>
  #  string _my_string3 = "    text"          ==> String_class<@value=     text>
  #  _my_string.add(_my_string2)              ==> String_class<@value=text     2>
  #  _my_string3.lstrip()                     ==> String_class<@value=text>
  #  _my_string3.add(_my_string2)             ==> String_class<@value=text2>
  #  _my_string3                              ==> text2
  # @return [Bool_class] Return object will be a Bool_class with true if all executed correct.
  # @raise [LocalJumpError] If program reach a none existing position in the code.
  def lstrip
    tmp = @value.lstrip!
    if @@our_debug then puts "#{debug_time} String_class method lstrip <== #{tmp}" end
    if tmp != nil
      return Bool_class.new('bool', 'TRUE')
    else
      return Bool_class.new('bool', 'FALSE')
    end
    raise LocalJumpError, "Compiler reach a none existing position. String_class.lstrip"
  end

  # Method remove characters from the string.
  # The method will remove any characters or whitespace. This include end-of-line signs etc. Normaly the method is called with a start position and number of elements to be removed. Overload method is to pass only one interger and the position will be set to 0 (start element).
  # @example Text will be appended to the string
  #  string _my_string = "text"               ==> String_class<@value=text>
  #  string _my_string2 = "example "          ==> String_class<@value=example>
  #  _my_string.remove(2)                     ==> String_class<@value=t>
  #  _my_string.remove(3,1)                   ==> String_class<@value=exale>
  #  _my_string                               ==> t
  #  _my_string2                              ==> exale
  # @return [Bool_class] Correct executed method will return a Bool_class with value true.
  # @raise [ArgumentError] If passed arguments are three or more exception will be raised.
  # @overload remove(length)
  #   @param length [Int_class] The number of characters that will be removed.
  # @overload remove(index, length)
  #   @param index [Int_class] Position of first element to remove.
  #   @param length [int_class] The number of characters that will be removed.
  def remove(args)
    #Arguments: idx=0, length
    if @@our_debug then puts "#{debug_time} String_class method remove <== #{args}" end
    if args.size == 1 || args.size == 2 then
      if args.size == 1 then
        idx=0
        length = args[0].value
      else
        idx = args[0].value
        length = args[1].value
      end
    else
      raise ArgumentError, "Wrong number of arguments for String_class.remove"
    end
    if @@our_debug then puts "#{debug_time} Remove String_class #{@name} with idx: #{idx}, #{length}" end
    @value[idx..(idx+length)] = ''
    return Bool_class.new('bool', 'TRUE')
  end

  # Method clear the value to ""
  def clear
    @value = ""
    return Bool_class.new('bool', 'TRUE')
  end
end

# Class for the array variable
class Array_class < Basic_container

  # Method will return it self
  # @return [Array_class] Eval will return it self.
  def eval
    if @@our_debug then puts "#{debug_time} Eval Array_class #{@name} <== #{@value}" end
    return self
  end

  # Method will set the array in a secure way.
  # This method is called when an Array is declared and is private within the class.
  # @return [Array] Return a Ruby Array class
  # @raise [None] No exception from this method
  # @param new_value [String] String that will be executed with instance_eval
  def set_value(new_value, assign=false)
    if assign
      @value = convert_obj(new_value).value
    else
      return instance_eval(new_value)
    end
  end

  # Method will add a value into given index.
  # Array has an index order starting from 0. If only value is passed this will
  # be inserted in first position.
  # @example Insert element into Array
  #  _my_array                ==> Array_class<@value=[1,2,3,4]>
  #  _my_array.insert(1,9);   ==> Bool_class<@value=true>
  #  _my_array                ==> Array_class<@value=[1,9,2,3,4]>
  # @return [Bool_class] Return with value = true if succeded. Otherwise false.
  # @raise [ArgumentError] If the number of arguments are wrong this will be raised.
  # @overload insert(value)
  #   @param value [Int_class] Value inserted at first position. Index 0.
  # @overload insert(index, value)
  #   @param index [Int_class] Start index of removed values
  #   @param value [Int_class] End index of removed values
  def insert(args)
    if args.size == 1 || args.size == 2 then
      if (args[-1].instance_of? Float_class) || (args[-1].instance_of? Int_class)
          value = args[-1].value
      else
          raise ArgumentError, "Array only holds integers and floats"
      end
      if args.size == 1 then
        idx=0
      else
        idx = args[0].value
        if idx > @value.length then raise ArgumentError, "Index out of range" end
      end
    else
      raise ArgumentError, "Wrong number of arguments or type for Array_class.insert."
    end
    if @@our_debug then puts "#{debug_time} Insert Array_class #{@name} with idx: #{idx}, #{value}" end
    @value = @value.insert(idx, value)
    return Bool_class.new('bool', 'TRUE')
  end

  # Method will return the number of elements in the array
  # @example Get size of Array
  #  array _my_array = [1,2,3];       ==> Array_class<@value=[1,2,3]>
  #  _my_array.size;                  ==> Int_class<@value=3>
  # @return [Int_class] Return an Int_class with value of the array size
  # @raise [None] No exception from this method
  def size
    return Int_class.new('int', @value.length);
  end

  # Method will delete values from start index to end index.
  # Array has an index order starting from 0. If only one parameter is passed end index
  # will be set to start index, Hence only one index will be removed.
  # @example Delete element or elements from array
  #  array _my_array = [1,2,3,4];     ==> Array_class<@value=[1,2,3,4]>
  #  _my_array.remove(0,1);           ==> Bool_class<@value=true>
  #  _my_array                        ==> Array_class<@value=[3,4]>
  # @return [Bool_class] Return with value = true if succeded. Otherwise false.
  # @raise [ArgumentError] If the number of arguments are wrong this will be raised.
  # @overload remove(idx_start, idx_end)
  #   @param idx_start [Int_class] Start index of removed values
  #   @param idex_end [Int_class] End index of removed values
  # @overload remove(idx_start)
  #   @param idx_start [Int_class] Index of removed value
  def remove(args)
    if args.size == 1 || args.size == 2 then
      if args.size == 1 then
        idx_start = args[0].value
        idx_end = idx_start
      else
        idx_start = args[0].value
        idx_end = args[1].value
      end
    else
      raise ArgumentError, "Wrong number of arguments or type for Array_class.remove. Argument must be integer"
    end
    if @@our_debug then puts "#{debug_time} Remove Array_class #{@name} with idx: #{idx_start}, #{idx_end-idx_start+1}" end
    if idx_end == idx_start
      @value.delete_at(idx_start)
      return Bool_class.new('bool', 'TRUE')
    else
      @value.slice!(idx_start, (idx_end-idx_start+1))
      return Bool_class.new('bool', 'TRUE')
    end
  end

  # Return the object/value at that index. Array has an index order starting from 0.
  # If the index does not exist. Bool_class with false will be returned.
  # @example Return element at index
  #  array _my_array = [1,2,3,4];          ==> Array_class<@value=[1,2,3,4]>
  #  _my_array.at(1)                       ==> Int_class<@value=2>
  # @return [Int_class] Return object will be an Int_class with value from index.
  # @raise [ArgumentError] If passed arguments are more then one this will be raised.
  # @param index [Int_class] Index of the returned value in the array
  def at(args)
    if args.size == 1
        idx = convert_obj(args[0]).value
        if idx > @value.length-1 then raise ArgumentError, "Index out of range" end
    else
      raise ArgumentError, "Wrong number of arguments or type for Array_class.at(). Argument must be integer"
    end
    return Int_class.new('int', @value.at(idx))
  end

  # Return the summery of all values in each element in the array self.
  # The method will add up all values from first element to the last element in the array.
  # The return value will be an Int_class with the calculated value. This method does not have any arguments and will not raise any error if any goes wrong.
  # @example Return the summery of all elements in the array
  #  _my_array                      ==> Array_class<@value=[1,2,3,4]>
  #  _my_array.sum()                ==> Int_class<@value=10>
  # @return [Int_class] Return object will be an Int_class with the summery of elements.
  # @raise [None] No exception from this method.
  def sum
    sum = 0
    @value.each {|e| sum += e }
    return Int_class.new('int', sum);
  end

  # The method will sort the array in an increased order.
  # The sorting method will compare the elements and place them in an increased order.
  # The return value will be an Int_class with the calculated value. This method does not have any arguments and will not raise any error if any goes wrong.
  # @example Sort the existing array
  #  array _my_array = [2,1,9,3,14,4];     ==> Array_class<@value=[2,1,9,3,14,4]>
  #  _my_array.sort()                      ==> Bool_class<@value=true>
  #  _my_array                             ==> Array_class<@value=[1,2,3,4,9,14]>
  # @return [Bool_class] Return object will be a Bool_class with TRUE or FALSE.
  # @raise [None] No exception from this method.
  def sort
    @value = @value.sort
    return Bool_class.new('bool','TRUE')
  end
end
