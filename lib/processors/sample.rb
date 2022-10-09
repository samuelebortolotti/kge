# frozen_string_literal: true

require 'optparse'
require_relative '../parser'

##
# Sample module
module Sample
  ##
  # Configure subparser method
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
      opts.on('-d', '--dummy [DUMMY]', String, 'dummy argument') do |_file|
        options[:dummy] = dummy
      end
    end
    # set the function to execute
    parser.fun = method(:sample_main)
    [parser, options]
  end
end

##
# Main function of the sample function
#
# @param [Logger] global logger
# @param [File] writer stream
# @param [File] reader stream
# @param [Hash] current command line arguments
def sample_main(logger, reader, writer, arguments)
  logger.debug('Hello, World! from sample')
  logger.debug("Reader: #{reader}")
  logger.debug("Writer #{writer}")
  logger.debug("Args: #{arguments}")
  logger.debug('closing streams')
  writer.close
  reader.close
end
