# frozen_string_literal: true

require 'optparse'
require 'csv'
require_relative '../parser'

##
# Sample module
module NumberSchool
  ##
  # Configure number school method
  #
  # @param [Hash] options
  #
  # @return [Parser, Hash] parser and options
  def self.configure_subparser(options)
    parser = Parser.new do |opts|
      opts.banner = 'Usage: sample [options]'
      opts.on('-h', '--help', 'Prints the help') do
        puts opts
        exit
      end
    end
    # set the function to execute
    parser.fun = method(:number_school_main)
    [parser, options]
  end
end

##
# Main function of the number school function
#
# @param [Logger] global logger
# @param [File] writer stream
# @param [File] reader stream
# @param [Hash] current command line arguments
def number_school_main(logger, reader, writer, arguments)
  logger.debug('Hello, World! from sample')
  logger.debug("Reader: #{reader}")
  logger.debug("Writer #{writer}")
  logger.debug("Args: #{arguments}")

  # delete the _id column
  csv_table = CSV.read(reader, headers: true)
  csv_table.delete('_id')
  csv_table.to_csv

  logger.debug('closing streams')
  writer.close
  reader.close
end
