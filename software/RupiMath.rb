#! /usr/bin/env ruby

require './RupiContainer.rb'
require './RupiGeneral.rb'

# @!attribute left
#   Contain the lefthand side of the operator.
# @!attribute operator
#   Contain the sign of the oprtator. .
# @!attribute right
#   Contain the righthand side of the operator.
class Basic_class

  # @example Please see class decleration for each operation.
  # @return [None] No return value from this method.
  # @raise [None] No exception from this method.
  # @param left [Basic_container] Contain the Basic_container class for the left side of the operator.
  # @param operator [String] Contain the operator for the calculation.
  # @param right [Basic_container] Contain the Basic_container class for the right side of the operator.
  def initialize(left, op, right)
    @left = left
    @right = right
    @op = op
  end
end

# The class will execute a comparising expression.
# @example Compare operation in RuPi
#  int _i1 = 3;                   ==> Bool_class<@value=true>
#  int _i2 = 5;                   ==> Bool_class<@value=true>
#  _i1 < _i2                      ==> true
#  _i1 > _i2                      ==> false
#  bool _b1 = _i1 > 8;            ==> Bool_class<@value=true>
#  bool _b2 = _i1 < 8;            ==> Bool_class<@value=truue>
#  _b1                            ==> false
#  _b2                            ==> true
class Comp_class < Basic_class

  # Method execute a compare operation.
  # The value is checked and a new Bool_class is created and returned. If the value is of the wrong type or not TRUE/FALSE a exception is raised (RangeError).
  # @example Please see class description.
  # @return [Bool_class] Return a Bool_class with calculated value.
  # @raise [RangeError] If the calculated value is not TRUE/FALSE a exception will be raised.
  def eval
    if @@our_debug then puts "#{debug_time} Eval compare #{@left} #{@op} #{@right}" end
    value = convert_obj(@left).value.send @op, convert_obj(@right).value
    if @@our_debug then puts "#{debug_time} Compared value return <== #{value}" end
    if value == true
      return declare_var('bool', 'tmp', 'TRUE')
    elsif value == false
      return declare_var('bool', 'tmp', 'FALSE')
    else
      raise RangeError, 'Compared value is out of range or nil'
    end
  end
end

# The class will execute a comparising not expression.
# @!attribute value
#   Contain the compare statement wich will be evaluated.
class Comp_not_class

  # @example  in RuPi
  #  bool _b = FALSE;                   ==> Bool_class<@value=false>
  #  !_b                                ==> true
  #  bool _b2 = !_b;                    ==> Bool_class<@value=true>
  #  _b2                                ==> true
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param expr [Comp_class] Contain the compare statement
  def initialize(expr)
    @value = expr
  end

  # Method execute an inverted compare operation.
  # The value is checked and an new inverted Bool_class is created and returned. If the value is of the wrong type or not TRUE/FALSE a exception is raised (RangeError)
  # @return [Bool_class] Return a Bool_class with inverted value.
  # @raise [RangeError] If the evaluated value is not TRUE/FALSE exception will be raised.
  def eval
    if @value.value
      if @@our_debug then puts "#{debug_time} Eval logical not return <== #{'FALSE'}" end
      return declare_var('bool', 'tmp', 'FALSE' )
    elsif !@value.value
      if @@our_debug then puts "#{debug_time} Eval logical not return <== #{'TRUE'}" end
      return declare_var('bool', 'tmp', 'TRUE' )
    else
      raise RangeError, 'Comp_not_class: Error - Compared NOT value is out of range or nil'
    end
  end
end

# The class will execute an addition/substract expression.
# @example Addition/Substraction in RuPi
#  int _i1 = 3;                       ==> Bool_class<@value=true>
#  int _i2 = 4;                       ==> Bool_class<@value=true>
#  int _i3 = _i1 + _i2;               ==> Bool_class<@value=true>
#  _i3                                ==> 7
class Add_class < Basic_class

  # @example Please see class description.
  # @return [Basic_container] Return the calculated value in form of a Basic_container variable.
  # @raise [ZeroDivisionError] Divion with zero will raise an error.
  def eval
    if @@our_debug then puts "#{debug_time} Eval Add_class #{@left} #{@op} #{@right}" end
    left = convert_obj(@left)
    right = convert_obj(@right)
    value = instance_eval("#{left.value} #{@op} #{right.value}")
    if @@our_debug then puts "#{debug_time} Eval Add_class return <== #{value}" end
    return declare_var(check_type(value), 'tmp', value)
  end
end

# The class will execute a multiplication/division expression.
# @example Multiplication/Division in RuPi
#  int _i1 = 3;                       ==> Bool_class<@value=true>
#  int _i2 = 4;                       ==> Bool_class<@value=true>
#  int _i3 = _i1 * _i2;               ==> Bool_class<@value=true>
#  _i3                                ==> 12
class Mult_class < Basic_class

  # @example Please see class description.
  # @return [Basic_container] Return the calculated value in form of a Basic_container variable.
  # @raise [ZeroDivisionError] Divion with zero will raise an error.
  def eval
    begin
      if @@our_debug then puts "#{debug_time} Eval Mult_class #{@left} #{@op} #{@right}" end
      value = convert_obj(@left).value.send @op, convert_obj(@right).value
      if @@our_debug then puts "#{debug_time} Eval Multi_class return <== #{value}" end
      return declare_var(check_type(value), 'tmp', value)
    rescue ZeroDivisionError
      puts "Mult_class: Error - calculation not possible. Divide with 0"
    end
  end
end

# The class will execute a logical operation
# @example Logical operator in RuPi
#  bool _b = TRUE;                      ==> Bool_class<@value=true>
#  int _i = 3;                          ==> Bool_class<@value=true>
#  if( _b && _i<5 ){                    ==> Bool_class<@value=true>
#     print("If statement is TRUE");
#  };                                   ==> Bool_class<@value=true>
class Log_class < Basic_class

  # Method will execute a logical expression (AND/OR) in RuPi.
  # All variables will be converted into a basic container variable, which values will be compared in an instance_eval(). A complete process without any error will return a Bool_class with either true or false, depending on the mathimathical result. The class could be used several times to finish a chain of logical expression in a RuPi code.
  # @example Please see class description.
  # @return [Bool_class] Return with value true if succeded. Otherwise false.
  # @raise [NoMethodError] If the logical expression can't be calculated this will raise an error.
  def eval
    if @@our_debug then puts "#{debug_time} Eval logic math #{@left} #{@op} #{@right}" end
    if @op == "&&"
      value = instance_eval("#{convert_obj(@left).value} & #{convert_obj(@right).value}")
    elsif @op == "||"
      value = instance_eval("#{convert_obj(@left).value} | #{convert_obj(@right).value}")
    else
      raise NoMethodError, 'This mathimathical logical expression does not compile'
    end
    if value == true
      value = 'TRUE'
    else
      value = 'FALSE'
    end
    if @@our_debug then puts "#{debug_time} Eval compare return <== #{value}" end
    return declare_var('bool', 'tmp', value)
  end
end

# The class will execute an increment of a varaible.
# @!attribute name
#   Contain the name of the variable.
# @!attribute operator
#   Contain the sign of increment or decrement.
class Inc_class

  # @example Increment statement within Rupi
  #  int _i = 1;                        ==> Int_class<@value=1>
  #  _i++;                              ==> Bool_class<@value=true>
  #  _i                                 ==> 2
  #  _i--;                              ==> Bool_class<@value=true>
  #  _i                                 ==> 1
  # @return [None] No return value from this method.
  # @raise [None] No error exception in this method.
  # @param name [String] Contain the name of the variable.
  # @param operator [String] Decline or increase operator.
  def initialize(name, op)
    @name = name
    @op = op
  end

  # Method will execute an increase or decline operation on an Integer.
  # The execution will read the operator and increment the variable with one step. A complete process without any error will return the new variable. Faulty will return a Bool_class with value false. The Inc_class will raise exception if the variable does not exist or is of the wrong type. Only integer could be increment.
  # @example Please see constructor of the class
  # @return [Bool_class] Return with value true if succeded. Otherwise false.
  # @raise [TypeError] Wrong type of variable. Only integer could be used.
  # @raise [NameError] Variable does not exist.
  def eval
    scope = var_exist? @name
    if scope != -1
      if @@variable_list[scope][@name].type == 'int'
        tmp = @@variable_list[scope][@name].value.send @op, 1
        @@variable_list[scope][@name].set_value(tmp)
        if @@our_debug then puts "#{debug_time} Increment #{@name} with #{@op}1" end
        return @@variable_list[scope][@name]
      else
        raise TypeError, 'Inc_class: Error - Variable is of wrong type'
      end
    else
      raise NameError, 'Inc_class: Error - Varaible does not exist'
    end
  end
end
