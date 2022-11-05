# frozen_string_literal: true

require 'optparse'
require 'csv'
require_relative '../parser'

##
# Invalisi module
module Invalsi
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
    parser.fun = method(:invalsi_main)
    [parser, options]
  end
end

##
# Main function of the invalsi function
#
# @param [Logger] global logger
# @param [File] writer stream
# @param [File] reader stream
# @param [Hash] current command line arguments
def invalsi_main(logger, reader, writer, arguments)
  logger.debug("Reader: #{reader}")
  logger.debug("Writer #{writer}")
  logger.debug("Args: #{arguments}")

  # delete the anno if anno is lower than
  csv_table = []
  CSV.read(reader, headers: true).each do |value|
    date = value['Anno'].split('-')
    csv_table << value if Date.new(date) < Date.new(2021)
  end
  csv_table.to_csv

  logger.debug('closing streams')
  writer.close
  reader.close
end
