#! /usr/bin/env ruby
#-*- coding UTF-8 -*-

$VERBOSE = nil #stops warning spam of global variables

require './rupi.rb'
require './rdparse.rb'
require './RupiContainer.rb'
require './RupiIteration.rb'
require './RupiFunc.rb'
require './RupiMath.rb'
require './RupiSelect.rb'
require './RupiGeneral.rb'
require './RupiRaspberry.rb'
require 'wiringpi2'

@@variable_list = [{}]
@@func_list = {}
@@scope_no = 0
@@our_debug = true

class Rupi

    attr_accessor :our_debug, :variable_list, :rupiParser

    def initialize(debug=false)
        @@params = {}

        @rupiParser = Parser.new("rupi") do
            # *** Tokenizer / Lexer ***
            token(/\s+/)                                            # Whitespaces
            token(/\d+\.\d+/) {|m| m.to_f }                         # Float number
            token(/\d+/) {|m| m.to_i }                              # Integer number
            token(/\"[^\"]*\"/) {|str| str }                          # String
            token(/\[((\d*|\d*\.\d+),?\s*)*\]/) {|array| array}     # array

            # Operators
            token(/&&/) {|operator| operator }
            token(/\|\|/) {|operator| operator }
            token(/<=/) {|operator| operator }
            token(/>=/) {|operator| operator }
            token(/</) {|operator| operator }
            token(/>/) {|operator| operator }
            token(/==/) {|operator| operator }
            token(/!=/) {|operator| operator }
            token(/\+\+/) {|operator| operator }
            token(/--/) {|operator| operator }
            token(/!/) {|operator| operator }

            # Reserved keywords
            token(/if/) {|s| s }                # Selector - if
            token(/else/) {|s| s }              # Selector - else
            token(/elif/) {|s| s }              # Selector - elif
            token(/TRUE/) {|b| b }              # Boolean - true
            token(/FALSE/) {|b| b }             # Boolean - false
            token(/int/) {|var| var }           # Varaible types - int
            token(/bool/) {|var| var }          # Variable type - bool
            token(/float/) {|var| var }         # Variable type - float
            token(/string/) {|var| var }        # Variable type - string
            token(/array/) {|var| var }         # Variable type - array
            token(/channel/) {|m| m }           # Raspberry channel
            token(/INPUT/) {|m| m }             # Raspberry mode
            token(/OUPUT/) {|m| m }             # Raspberry mode
            token(/return/) {|m| m }
            token(/func/) {|m| m }
            token(/print/) {|pr| pr }           # Print

            # General tokens
            token(/_[^\d]\w*/) {|var| var }     # Variablename
            token(/[A-Z]\w*/) {|func| func }    # Function
            token(/[a-z]+/) {|func| func }      # Class function call

            token(/./) {|m| m}                  # All the rest... One character

            # *** Parser ***
            start :program do
                match(:stmts) do |stmts|
                    stmts.eval unless stmts.is_a? NilClass
                end
            end

            rule :stmts do
                match(:stmts, :stmt) {|stmts, stmt| Stmts_class.new(stmts,stmt)}
                match(:stmt)
            end

            rule :stmt do
                match(:return_stmt, ';')
                match(:func_call_stmt)
                match(:func_call_var_stmt)
                match(:assign_stmt, ';')
                match(:iter_stmt, ';')
                match(:if_stmt, ';')
                match(:declare_stmt, ';')
                match(:func_dec_stmt, ';')
                match(:general_stmt, ';')
                match(:expr)
            end

            rule :return_stmt do
                match('return', :expr) {|_, value, _|
                    Return_class.new(value) }
            end

            rule :declare_stmt do
                match(:type, :var_name, '=', :func_call_var_stmt ) do
                    |type, name, _, value|
                    Declare_class.new(type,name,value) end
                match(:type, :var_name, '=', :expr) do
                    |type, name, _, value|
                    Declare_class.new(type,name,value) end
                match('channel', :var_name, '=', '(', :int, ',', :mode, ')') do
                    |_, name, _, _, pin, _, mode, _|
                    Declare_channel_class.new('channel', name, pin, mode) end
            end

            rule :assign_stmt do
                match(:var_name, '=', :func_call_var_stmt ) do |name, _, value|
                    Assign_class.new(name, value) end
                match(:var_name, '=', :expr) do |name, _, value|
                    Assign_class.new(name, value) end
                match(:var_name, '++') do |name, _|
                    Inc_class.new(name, '+') end
                match(:var_name, '--') do |name, _|
                    Inc_class.new(name, '-') end
            end

            # *** Iterators ***
            rule :iter_stmt do
                match(:for_stmt)
                match(:while_stmt)
                match(:each_stmt)
            end

            rule :for_stmt do
                match('for', :int, ',', :int, 'with', :var_name, '{', :stmts, '}') do
                    |_, i_start, _, i_end, _, index, _, stmts, _|
                    For_class.new(i_start, i_end, index, stmts)
                end
            end

            rule :while_stmt do
                match('while', '(', :comp_expr, ')', '{', :stmts, '}' ) do
                    |_, _, compare, _, _, stmts, _|
                    While_class.new(compare, stmts)
                end
            end

            rule :each_stmt do
                match('each', :var_value, 'with', :var_name, '{', :stmts, '}') do
                    |_, array_name, _, index, _, stmts, _|
                    Each_class.new(array_name, index, stmts)
                end
            end

            rule :func_call_var_stmt do
                match(:var_name, '.', :class_func, '(', :arguments, ')') do
                    |name, _, func, _, arg, _|
                    Func_class.new(name, func, arg) end
                match(:var_name, '.', :class_func, '(', ')') do
                    |name, _, func, _, _|
                    Func_class.new(name, func) end
            end

            # *** If and Else ***
            rule :if_stmt do
                match('if', '(', :log_expr, ')', '{', :stmts, '}', 'else', '{', :stmts, '}') do
                    |_, _, compare, _, _, if_stmts, _, _, _, else_stmts, _|
                    Else_class.new(compare, if_stmts, else_stmts) end
                match('if', '(', :log_expr, ')', '{', :stmts, '}', 'elif', :elif_stmt) do
                    |_, _, compare, _, _, if_stmts, _, _, elif_stmts|
                    Else_class.new(compare, if_stmts, elif_stmts, true) end
                match('if', '(', :log_expr, ')', '{', :stmts, '}') do
                  |_, _, compare, _, _, stmts, _|
                  If_class.new(compare, stmts) end
            end

            rule :elif_stmt do
                match('(', :log_expr, ')', '{', :stmts, '}', 'elif', :elif_stmt) do
                    |_, compare, _, _, if_stmts, _, _, elif_stmts|
                    Else_class.new(compare, if_stmts, elif_stmts, true) end
                match('(', :log_expr, ')', '{', :stmts, '}', 'else',  '{', :stmts, '}') do
                    |_, compare, _, _, if_stmts, _, _, _, else_stmts, _|
                    Else_class.new(compare, if_stmts, else_stmts) end
                match('(', :log_expr, ')', '{', :stmts, '}') do
                    |_, compare, _, _, if_stmts, _|
                    If_class.new(compare, if_stmts) end
            end

            rule :general_stmt do
                match('print', '(', :expr, ')') do
                    |_, _, text, _|
                    Print_class.new(text)
                end
                match('print', '(', :atom, ')') do
                    |_, _, text, _|
                    Print_class.new(text)
                end
                match('wait', '(', :int, ',', :string, ')') do
                    |_, _, value, _, unit, _|
                    Wait_class.new(value,unit)
                end
            end

            rule :func_dec_stmt do
                match('func', :func_name, '(', :parameters, ')', '{', :stmts, '}') do
                    |_, name, _, para, _, _, block, _|
                    Dec_Func.new(name, block, para)
                end
                match('func', :func_name, '(', ')', '{', :stmts, '}') do
                    |_, name, _, _, _, block, _|
                    Dec_Func.new(name, block)
                end
            end

            rule :func_call_stmt do
                match(:func_name, '(', :arguments, ')') do
                    |name, _, args, _|
                    Call_Func.new(name, args)
                end
                match(:func_name, '(', ')') do
                    |name, _, _|
                    Call_Func.new(name)
                end
            end

            rule :parameters do
                match(:parameters, ',', :parameter) do
                    |paras, _, para|
                    if paras.instance_of? Array
                        paras << para
                    else
                        [paras] << para
                    end
                end
                match(:parameter) do
                    |para| para
                end
            end

            rule :parameter do
                match(:declare_stmt)
                match(:para_declare_stmt)
            end

            rule :para_declare_stmt do
                match(:type, :var_name) do
                    |type, name|
                    if type == 'int'
                        Declare_class.new(type, name, 0)
                    elsif type == 'float'
                        Declare_class.new(type, name, 0.0)
                    elsif type == 'bool'
                        Declare_class.new(type, name, 'TRUE')
                    elsif type == 'string'
                        Declare_class.new(type, name, "")
                    elsif type == 'channel'
                        raise NameError, 'Channel can only be declared with values'
                    elsif type == 'array'
                        Declare_class.new(type, name, "[]")
                    end
                end
            end

            rule :arguments do
                match(:arguments, ',', :argument) do
                    |args, _, arg|
                    if args.instance_of? Array
                        args<<arg
                    else
                        [args]<<arg
                    end
                end
                match(:argument) do
                    |arg| arg
                end
            end

            rule :argument do
                match(:var_name) do |var|
                    Variable_class.new(var) end
                match(:func_call_stmt)
                match(:func_call_var_stmt)
                match(:var)
            end

            rule :class_func do
                match(/[a-z]+/) {|func| func }
            end

            rule :expr do
                match(:expr, :add_op, :add_expr) do |lhs, op, rhs|
                    Add_class.new(lhs,op,rhs) end
                match(:add_expr)
            end

            rule :add_expr do
                match(:add_expr, :mult_op, :log_expr) do |lhs, op, rhs|
                    Mult_class.new(lhs,op,rhs) end
                match(:log_expr)
            end

            rule :log_expr do
                match(:log_expr, :log_op, :comp_expr) do |lhs, op, rhs|
                    Log_class.new(lhs,op,rhs) end
                match(:not_op, :comp_expr) do | _, expr|
                    Comp_not_class.new(expr) end
                match(:comp_expr)
            end

            rule :comp_expr do
                match(:comp_expr, :comp_op, :atom) do |lhs, op, rhs|
                    Comp_class.new(lhs,op,rhs) end
                match(:atom)
            end

            rule :add_op do
                match('+') {|m| m}
                match('-') {|m| m}
            end

            rule :mult_op do
                match('*') {|m| m}
                match('/') {|m| m}
            end

            rule :log_op do
                match('&&') {|m| m}
                match('||') {|m| m}
            end

            rule :not_op do
                match('!') {|m| m}
            end

            rule :comp_op do
                match('<=') {|m| m}
                match('>=') {|m| m}
                match('<') {|m| m}
                match('>') {|m| m}
                match('==') {|m| m}
                match('!=') {|m| m}
            end

            rule :type do
              match('int') {|m| m }
              match('float') {|m| m }
              match('bool') {|m| m }
              match('string') {|m| m }
              match('channel') {|m| m }
              match('array') {|m| m }
            end

            rule :atom do
                match(:func_call_stmt)
                match(:func_call_var_stmt)
                match('(', :expr, ')') {|_, expr, _| expr }
                match(:var)
                match(:var_value)
            end

            rule :var do
                match(:int)
                match(:float)
                match(:bool)
                match(:string)
                match(:channel)
                match(:array)
            end

            rule :var_value do
                match(/_[^\d]\w*/) do |name|
                    Variable_class.new(name) end
            end

            rule :var_name do
                match(/_[^\d]\w*/) {|name| name }
            end

            rule :func_name do
                match(/[A-Z]\w*/) {|v| v }
            end

            rule :int do
                match('-', Integer) do |_, value|
                    Int_class.new('int', -value) end
                match(Integer) do |value|
                    Int_class.new('int', value) end
            end

            rule :float do
                match('-', Float) do |_, value|
                    Float_class.new('float', -value) end
                match(Float) do |value|
                    Float_class.new('float', value) end
            end

            rule :bool do
                match('TRUE') {Bool_class.new('bool','TRUE')}
                match('FALSE') {Bool_class.new('bool','FALSE')}
            end

            rule :string do
                match(/"[^\"]*"/) do |str|
                    String_class.new('string', str) end
            end

            rule :array do
                match(/\[((\d*|\d*\.\d+),?\s*)*\]/) do |array|
                    Array_class.new('array', array) end
            end

            rule :mode do
                match('INPUT') do
                    Bool_class.new('bool', 'TRUE') end
                match('OUTPUT') do
                    Bool_class.new('bool', 'FALSE') end
            end
        end
    end
end
