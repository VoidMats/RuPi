#! /usr/bin/env ruby

require './RupiParse.rb'
require './RupiContainer.rb'
require 'wiringpi2'

class Declare_channel_class
  attr_accessor :value, :name
  attr_reader :type, :mode

  def initialize(type, name, pin, mode)
    @type = type
    @name = name
    @value = set_value(pin)
    @mode = mode
    @io = WiringPi::GPIO.new
  end

  def eval
    if @@variable_list.at(@@scope_no).has_key?(@name)
      raise NameError, 'Variable already exist in this scope'
    else
      converted_obj = convert_obj(@value)
      created_channel = Channel_class.new(@type, convert_obj(@value), @mode, @io, @name)
      @@variable_list[0][@name] = created_channel
      # set the pin on the Raspberry
      if @mode.value
        @io.pin_mode(@value.value, WiringPi::INPUT)
      else
        @io.pin_mode(@value.value, WiringPi::OUTPUT)
      end
      self.debug_info
      return Bool_class.new('bool','TRUE')
    end
    return Bool_class.new('bool', 'FALSE')
  end

  def set_value(new_value)
    if new_value.instance_of? Int_class
      if new_value.value > 40 then raise IndexError, 'PIN number is out of range' end
      ret_value = new_value
    else
      if new_value < 40 then raise IndexError, 'PIN number is out of range' end
      ret_value = Int_class.new('int', new_value)
    end
    ret_value
  end

  def debug_info
    if @@our_debug then
      puts "#{debug_time} Eval Declare_channel_class #{@type} #{@name} <== #{@value.value}"
      puts "#{debug_time} set gpio channel #{@value.value} to INPUT: #{@mode.value}"
    end
  end
end

class Channel_class
  attr_accessor :name, :pin
  attr_reader :type, :time, :value

  def initialize(type, pin, mode, channels, name='tmp')
    @type = type
    @value = pin.value
    @mode = mode.value
    @name = name
    @@io = channels
  end

  def write(args)
    if args.size == 3 && @mode == false then
      re_calc = {'ms' => 0.01, 's' => 1, 'min' => 60, 'hour' => 3600}
      if !re_calc.has_key? args[2].value then
        raise ArgumentError, "Time unit has to be 'ms', 's', 'min','hour'" end
      time = convert_obj(args[1]).value * re_calc[args[2].value]
      @time = args[1].value
      @thread = Thread.new do
        if @@our_debug then puts "#{debug_time} Set GPIO pin #{@value} to #{args[0].value} for #{time} sec" end
        if args[0].value == 1 then
          @@io.digital_write(@value, WiringPi::HIGH)
          sleep time
          @@io.digital_write(@value, WiringPi::LOW)
        else
          @@io.digital_write(@value, WiringPi::LOW)
          sleep time
          @@io.digital_write(@value, WiringPi::HIGH)
        end
      end
      if @@our_debug then puts "#{debug_time} set GPIO to #{args[0].value}" end
    elsif args.size == 1 && @mode == false then
      if args[0].value == 0
        @@io.digital_write(@value, WiringPi::LOW)
      else
        @@io.digital_write(@value, WiringPi::HIGH)
      end
      if @thread
        @thread.exit
        if @@our_debug then puts "#{debug_time} Write method overright ongoing thread. Thread is killed." end
      end
    else
      raise ArgumentError, "Wrong number of arguments or type for Array_class.insert."
    end
    Bool_class.new('bool', 'TRUE')
  end

  def read
    #pin_state = io.digital_read(1)
    state = @@io.digital_read(@value)
    if state == 1 #maybe not true
      state = Bool_class.new('bool', 'TRUE')
    else
      state = Bool_class.new('bool', 'FALSE')
    end
    if @@our_debug then puts "#{debug_time} Read from GPIO on pin: #{@value} <== #{state} <== #{state.value}" end
    return state
  end

  def wait(args)
    if args.size == 2 then
      re_calc = {'ms' => 0.01, 's' => 1, 'min' => 60, 'hour' => 3600}
      if !re_calc.has_key? args[2].value then
        raise ArgumentError, "Time unit has to be 'ms', 's', 'min','hour'" end
      time = convert_obj(args[1]).value * re_calc[args[2].value]
      if @thread.status == 'run'
        sleep time end
    else
      raise ArgumentError, "Wrong number of arguments or type for Array_class.wait"
    end
  end
end
