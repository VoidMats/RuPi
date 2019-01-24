README
======
This readme file and YARD documentation will be in English, rest of the documentation will be Swedish. No translation will be made for these documents.

1.0 RuPi - Ruby Raspberry Pi language
=================================
RuPi small domain language (DSL) with the function to implement control of signals on the GPIO for a Raspberry Pi. This language is very similar to C++ and is for beginners. Complete manual could be access by YARD or pdf file under the folder /dokument.

1.1 YARD
========
To print the yard document move to the folder where all the Ruby scripts are stored and write in the terminal. 

$ yardoc *.*

To install YARD. Please type.

$ gem install yard

1.2 Requirements
================
Please see complete installation manual in the RuPi documentation. But, when the Raspberry has access to Internet following could be typed in the terminal:

$ sudo apt-get install ruby

$ sudo apt-get install ruby-dev

$ sudo apt-get install ruby-bundler

$ sudo gem install wiringpi2

1.3 Connect components to a Raspberry
=====================================

Output signal: To connect a LED the current has to be limit to not burn out the port of the Raspberry. This could be calculated with Ohm's law. But a resistor of 330 Ohm should be enough to limit and light up the LED.

Input signal: To create a Pull-down connection please add a 10k Ohm resistor to the ground and 1k Ohm resistor on the inlet side.

2.0 Use RuPi
============
RuPi could be used in terminal mode or reading from a file. 
RuPi code could be type into any textfile. To compile RuPi please type

$ ruby RupiRun.rb [option] [filename]



