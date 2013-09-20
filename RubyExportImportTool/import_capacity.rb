require 'rally_rest_api'
require 'time'
require 'stuff'
require 'fastercsv'
require 'base_import'

class ImportCapacity < BaseImport

  def ImportCapacity.create_uic(stuff, fields)
  	stuff.slm.create(:user_iteration_capacity, fields)
  end
  
  def ImportCapacity.validate_capacity(row)
    if (row['Iteration'] == "" or row['Iteration'] == nil)
      puts "Error: Iteration Name is required #{row['Iteration']}"
    end

    if (row['UserName'] == "" or row['UserName'] == nil)
      puts "Error: UserName is required #{row['UserName']}"
    end

    if (row['Capacity'] == "" or row['Capacity'] == nil)
      puts "Error: Capacity is required #{row['Capacity']}"
    end
  end
  
  def ImportCapacity.parse_capacity(stuff, header, row)
    validate_capacity(row)
    
    iteration = find_iteration(stuff, row['Iteration'])
    if ( iteration == nil )
      return
    end
    
    fields = {
      :iteration => iteration,
      :user_name => row['UserName'],
      :capacity => row['Capacity'],
      :workspace => stuff.workspace,
      :project => stuff.project
    }
    
    print "Capacity: ", row['UserName'], " ", iteration.name, " ", row['Capacity'], "\n"
    create_uic(stuff, fields)
  end
  
  def ImportCapacity.create_capacity(stuff, filename)
    input = FasterCSV.read(filename)
    
    header = input.first #ignores first line
  
    rows = []
    (1...input.size).each { |i| rows << FasterCSV::Row.new(header, input[i]) }
    
    rows.each { |row| parse_capacity(stuff, header, row)}
  end
end