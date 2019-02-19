# README
This readme file and the YARD documentation will be in English. The rest of the
of the documentation will be in Swedish. No translation will be made.

## RuPi - Ruby Raspberry Pi language
RuPi is a small domain language (DSL) with focus on implementing control functions
on the GPIO port of a Raspberry Pi. The language is very similar to C++ and is for beginners. No advance features are implemented and probably never will. Complete manual could be access by YARD or pdf file under the folder /dokument.

## YARD
To print the yard documentation move the folder where all the Ruby scripts are stored
and write in the terminal.
'''bash
$ yardoc *.*
'''
To install YARD. Please type.
'''bash
$ gem install yard
'''

## Requirements
Please see complete installation manual in the RuPi documentation. But, ones the Raspberry
has access to Internet following could be typed in the terminal:
'''bash
$ sudo apt-get install ruby

$ sudo apt-get install ruby-dev

$ sudo apt-get install ruby-bundler

$ sudo gem install wiringpi2
'''

## Connect components to a Raspberry
There is good instructions on the [Raspberry Community Hompage](https://www.raspberrypi.org/documentation/usage/gpio/). Shortly:

Output signal: To connect a LED the current has to be limit to not burn out the port of the Raspberry. This could be calculated with Ohm's law. But a resistor of 330 Ohm should be enough to limit and light up the LED.

Input signal: To create a Pull-down connection please add a 10k Ohm resistor to the ground and 1k Ohm resistor on the inlet side.

# Use RuPi
RuPi could be used in terminal mode or reading from a file.
RuPi code could be type into any textfile. To compile RuPi please type

'''bash
$ ruby RupiRun.rb [option] [filename]
'''
