require 'rally_rest_api'
require 'time'
require 'stuff'
require 'fastercsv'

def create_iteration(stuff, fields)
	stuff.slm.create(:iteration, fields)
end

def parse_iteration(stuff, row)
  
# Hack for relative iteration dates
  start_date = row['StartDate(YYYY-MM-DD)']
  if ( start_date.to_i < 20 )
    start_date = Time.now + start_date.to_i*7*86400
  end

# Hack for relative iteration dates
  end_date = row['EndDate(YYYY-MM-DD)']
  if ( end_date.to_i < 20 )
    end_date = Time.now + end_date.to_i*7*86400 - 86400
  end

  resources = row['Resources']
  if ( resources == "" or resources == nil )
    resources = 0
  end

  fields = {
    :workspace => stuff.workspace,
    :project => stuff.project,
    :name => row['Name'], 
    :start_date => start_date,
    :end_date => end_date,
    :resources => resources,
    :state => row['State'],
    :theme => row['Theme']  
  }

  print "Iteration: ", row['Name'], "\n"
  create_iteration(stuff, fields)
end


def create_iterations(stuff, filename)
  input = FasterCSV.read(filename)
  header = input.first #ignores first line
  
  rows = []
  (1...input.size).each { |i| rows << FasterCSV::Row.new(header, input[i]) }
  
  rows.each { |row| parse_iteration(stuff, row)}
end
		