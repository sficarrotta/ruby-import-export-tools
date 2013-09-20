require 'rally_rest_api'
require 'time'
require 'stuff'
require 'fastercsv'
require 'base_import'

@test_case = nil

class ImportTestFolders < BaseImport

  def ImportTestFolders.create_test_folder(stuff, name)
  
    fields = {
      :workspace => stuff.workspace,
      :project => stuff.project,
      :name => name,
    }
    @test_folder = stuff.slm.create(:test_folder, fields)
  end
  

  
  def ImportTestFolders.parse_test_folder_row(stuff, header, row)
    name = row['Name']
    print "Test Folder: ", name, "\n"
    create_test_folder(stuff, name)
  end
  
    
  def ImportTestFolders.create_test_folders(stuff, filename)
    input = FasterCSV.read(filename)
    header = input.first #ignores first line
    
    rows = []
    (1...input.size).each { |i| rows << FasterCSV::Row.new(header, input[i]) }
    
    rows.each { |row| parse_test_folder_row(stuff, header, row)}
  end

end

		
