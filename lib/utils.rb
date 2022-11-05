require 'csv'

##
# CSV writer function
#
# @param [String] name of the file
# @param [String] data to write
#
def write_csv(name, data)
  CSV.open(name, 'w') do |csv|
    csv << data
  end
end
