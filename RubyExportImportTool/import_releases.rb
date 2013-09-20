require 'rally_rest_api'
require 'time'
require 'stuff'

def create_release(stuff, fields)
	stuff.slm.create(:release, fields)
end

# TODO - don't update if nil or ""
def update_release(stuff, release, fields)
	release.update(fields)
end

def parse_release(stuff, row)
  start_date = row['StartDate(YYYY-MM-DD)']
  release_date = row['EndDate(YYYY-MM-DD)']
  name = row['Name']
  
# Hack for relative release dates
  if ( release_date.to_i < 20 )
    release_date = Time.now + release_date.to_i*7*86400 - 86400
  end

  if ( start_date.to_i < 20 )
    start_date = Time.now + start_date.to_i*7*86400
  end
  
  resources = row['Resources']
  if ( resources == "" or resources == nil )
    resources = 0
  end
  
  fields = {
    :workspace => stuff.workspace,
    :project => stuff.project,
    :name => name,
    :release_start_date => start_date,
    :release_date => release_date,
    :resources => resources,
    :state => row['State'],
    :theme => row['Theme']
  }
  
  release = find_release(stuff, name)
  
  if ( release == nil )
    print "Release: ", name, "\n"
    create_release(stuff, fields)
  else
    print "Updating Release: ", name, "\n"
    update_release(stuff, release, fields)
  end
  
end


def create_releases(stuff, filename)
  input = FasterCSV.read(filename)
  header = input.first #ignores first line
  
  rows = []
  (1...input.size).each { |i| rows << FasterCSV::Row.new(header, input[i]) }
  
  rows.each { |row| parse_release(stuff, row)}
end
		