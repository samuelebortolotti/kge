# frozen_string_literal: true

require 'optparse'
require 'zlib'
require 'logger'

# Relative imports
require_relative 'processors/sample'

##
# Configure Subparser
#
# It configures the option parser by adding the other parsers
#
# @param [OptionParser] parser
#
# @return [Hash, Hash(OptionParser)] options and parsers
def configure_subparsers(options)
  # subcommands
  subcommands = {}
  # Sample subparser
  subparser, current_options = Sample.configure_subparser options
  # Add the subparser command
  options, subcommands = add_commands(
    options,
    subcommands,
    current_options,
    subparser,
    :sample
  )
  # Return options and subcommands
  [options, subcommands]
end

##
# Add subparser commands
#
# It configures the option parsers by adding subcommands
#
# @param [Hash] global options
# @param [Hash(OptionParser)] global subparser hash
# @param [Hash] current parser options
# @param [OptionParser] current subparser
#
# @return [Hash, Hash(OptionParser)))))))))] options and parsers
def add_commands(global_options, global_subparser, current_options, current_subparser, name)
  # add current options to the hash
  global_options.merge! current_options
  # store the subparser
  global_subparser.store name, current_subparser
  # return the couple
  [global_options, global_subparser]
end

##
# Configure Parser
#
# It configures the option parser by adding the default parameters
#
# @return [OptionParser, Hash] parser and options
def configure_parser
  subtext = <<~HELP
    Subcommands are:
       sample :     sample command
  HELP
  options = {}
  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: main.rb [options] [subcommand [options]]'
    opts.separator 'KGE tools'
    opts.separator 'Example: ruby main.rb ...'
    opts.on('-h', '--help', 'Prints the help') do
      puts opts
      exit
    end
    opts.on('-f', '--file [FILE]', String, 'File to analyze') do |file|
      options[:file] = file
    end
    opts.on('-o', '--out [OUT]', String, 'Output file') do |out|
      options[:out] = out
    end
    opts.separator ''
    opts.separator subtext
  end
  [parser, options]
end

##
# Checks whether the arguments are provided or not
#
# Exits with 1 as error code and prints the help if one or more arguments are missing
#
# @param [OptionParser] parser
# @param [Hash] global options
# @param [Array] arguments to find
#
# @return [OptionParser, Hash] parser and options
def deal_with_missing_arguments(parser, options, arguments)
  arguments.each do |arg|
    if options[arg].nil?
      puts parser.help
      exit 1
    end
  end
end

##
# Returns the command line arguments
#
# It configures the option parser by adding the default parameters
# and parses the parameters
#
# @return [Hash] options
def retrieve_args
  parser, options = configure_parser
  options, subcommands = configure_subparsers(options)

  # parse the options
  parser.order!
  command = ARGV.shift
  # call if none command are given
  unless command.nil?
    subcommands[command.to_sym].order!
    options[:fun] = subcommands[command.to_sym].fun
  end

  # missing arguments
  deal_with_missing_arguments parser, options, %i[file out fun]

  # returns the options
  options
end

##
# Gets the output writer streams
# For the moment only gz archives
#
# @param [String] path
# @param [String] compression
#
# @return [Stream] file stream
def output_writer(path, compression)
  # Write data to a compressed file
  if compression == '.gz'
    Zlib::GzipWriter.open(path)
  else
    File.open(path, 'wt')
  end
end

# Gets the reader streams
# For the moment only gz archives
#
# @param [String] path
# @param [String] compression
#
# @return [Stream] file stream
def output_reader(path, compression)
  # Write data to a compressed file
  if compression == '.gz'
    Zlib::GzipReader.open(path)
  else
    File.open(path, 'rt')
  end
end

##
# Main function of the program
def main
  # logger sullo stdout
  logger = Logger.new($stdout)
  logger.level = Logger::DEBUG
  # Get the arguments
  begin
    args = retrieve_args
  rescue StandardError => e
    warn "Wrong usage of the program: #{e.message}"
    exit 2
  end
  # Prints the arguments
  logger.debug("Parsed arguments: #{args}")

  # call the function
  args[:fun].call(
    logger,
    output_reader(args[:file], File.extname(args[:file])),
    output_writer(args[:out], File.extname(args[:out])),
    args
  )
end

# call the main function
begin
  main
rescue StandardError => e
  warn "Unexpected error: #{e.message}"
  exit 3
end
