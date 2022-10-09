# frozen_string_literal: true

require 'optparse'

##
# Simple OptionParser exension with the fun attribute
class Parser < OptionParser
  attr_accessor :fun
end
