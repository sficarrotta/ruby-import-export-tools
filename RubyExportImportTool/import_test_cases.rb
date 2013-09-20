require 'rally_rest_api'
require 'time'
require 'stuff'
require 'fastercsv'
require 'base_import'

@test_case = nil

class ImportTestCases < BaseImport

  # Barry 7/21/2009 Added support for importing/exporting TestFolder
  # TestFolders are specified using a path like string eg.
  # A//B//C
  # The "//" is used to disambiguate folder names that contain forward slashes ("/")
  
  # Recursive method to traverse up the folder hierarchy while matching the searched for 
  # path
  def ImportTestCases.match_folder(folder,paths, i)
  	if folder.name != paths[i]
  		return nil
  	 elsif (folder.name == paths[i]) && (i = paths.size-1)
	  	return folder
   	 elsif folder.parent
  		return match_folder ( folder.parent, paths, i+1 )
  	end
  end

  # Returns a folder for a path eg. if passed "A//B//C" it will first search for all folders that 
  # are named "C", then it will traverse up the hierarchy of each matching the remainder of the path (in this case
  # B and C. 
  def ImportTestCases.folder_from_path(stuff,path)
  
  	paths = path.split('//').reverse	# splits and reverses the path "A//B//C" becomes "C,B,A"
  	
  	folders = find_objects_by_name(stuff,paths.first,"TestFolder")
  	
  	folders.each { |folder| 
  		full_folder = match_folder(folder,paths,0)
  		if full_folder
  			return folder
  		end
  	}
  	
  	puts "TestFolder: '#{path}' not found\n"
  	
  end
  
  # Used to find multiple folders with the passed name (ie. not just the first one)
  def ImportTestCases.find_objects_by_name(stuff, name, type)  
          if ( name != "" and name != nil )
            query_result = stuff.slm.find(
              type, 
              :project => stuff.project, 
              :project_scope_up => true, 
              :project_scope_down => true) {equal :name, name}
            return query_result
          end
    end

  # returns a folder for a given test_folder path name. If it is a simple name eg. "FolderA" it defaults to the 
  # older behavior of returning the first folder (regardless of hierarchy) with that name
  def ImportTestCases.find_folder(stuff,test_folder)
  
  	if test_folder
  		if test_folder.include? "//"
  			return folder_from_path(stuff,test_folder)
  		else
  			# this is the old behavior, return the first folder found with the name
  			find_object_by_name(stuff, test_folder, :test_folder)
	  	end
  	end
  end
  
  
  
  # Barry 7/21/2009 Added support for importing/exporting TestFolder
  # End changes

  def ImportTestCases.create_test_case(stuff, name, work_product, owner, priority, package, risk, description, notes, objective, 
    pre_conditions, post_conditions, validation_input, validation_expected_result, test_folder, custom_fields, tags)
  
    fields = {
      :workspace => stuff.workspace,
      :project => stuff.project,
      :name => name,
      :work_product => find_object_by_name(stuff, work_product, :requirement),
      :owner => owner,
      :priority => priority,
      :package => package, 
      :risk => risk,
      :description => description,
      :objective => objective,
      :notes => notes,
      :pre_conditions => pre_conditions,
      :post_conditions => post_conditions,
      :validation_input => validation_input,
      :validation_expected_result => validation_expected_result,
      :test_folder => find_folder(stuff,test_folder) # find_object_by_name(stuff, test_folder, :test_folder)
    }
    
    fields.merge!(custom_fields)
        
    @test_case = stuff.slm.create(:test_case, fields)
    # added to support import of tags
    update_tags(stuff,@test_case,tags)
    
  end
  
  def ImportTestCases.find_object_by_name(stuff, name, type)  
    if ( name != "" and name != nil )
      query_result = stuff.slm.find(
        type, 
        :project => stuff.project, 
        :project_scope_up => true, 
        :project_scope_down => true) {equal :name, name}
      return query_result.first
    end
  end
  
  
  def ImportTestCases.create_step(stuff, step_input, step_expected_result)
    stuff.slm.create(:test_case_step,
    	:test_case => @test_case,
  	:workspace => stuff.workspace,
  	:project => stuff.project,
  	:input => step_input,
  	:expected_result => step_expected_result)
  end
  
  def ImportTestCases.create_test_case_result(stuff, build, date_run, verdict, duration, owner, notes)
    stuff.slm.create(:test_case_result,
      :test_case => @test_case,
      :workspace => stuff.workspace,
      :project => stuff.project,
      :build => build,
      :date => date_run,
      :verdict => verdict,
      :duration => duration,
      :tester => owner,
      :notes => notes)
  end
  
  
  def ImportTestCases.parse_test_case(stuff, header, row)
  # TODO Validate
  #  validate_test_cases(row)
  
    name = row['Name']
    work_product = row['WorkProduct']
    owner = row['Owner']
    priority = row['Priority']
    package = row['Package']
    risk = row['Risk']
    
    description = row['Description']
    notes = row['Notes']
    objective = row['Objective']
    pre_conditions = row['PreConditions']
    post_conditions = row['PostConditions']
    validation_input = row['ValidationInput']
    validation_expected_result = row['ValidationExpectedResult']
    test_folder = row['TestFolder']
    tags = row['Tags']
    
    #puts "#{test_folder} = #{folderFromPath(stuff,test_folder)}\n"

    custom_fields = gather_custom_fields(header, row)
    
    print "Test Case: ", name, "\n"
    create_test_case(stuff, name, work_product, owner, priority, package, risk, description, 
      notes, objective, pre_conditions, post_conditions, validation_input, validation_expected_result, test_folder, custom_fields, tags)
  end
  
  def ImportTestCases.parse_step(stuff, row)
  # TODO Validate
  #  validate_step(row)
    
    input = row['StepInput']
    expected_result = row['StepExpectedResult']
  
    print "  Step: ", input, "\n"
    create_step(stuff, input, expected_result)
  end
  
  def ImportTestCases.parse_result(stuff, row)
  # TODO Validate
  #  validate_result(row)
  
    build = row['Build']
    date_run = row['DateRun']
    verdict = row['Verdict']
    duration = row['Duration']
    tester = row['Owner']
    notes = row['Notes']
    
  # Hack for relative result dates
    if ( date_run.to_i < 20 )
      date_run = Time.now + date_run.to_i*86400
    end
  
    if ( duration == nil )
      duration = 0
    end
    
    print "  Result: ", build, "\n"
    create_test_case_result(stuff, build, date_run, verdict, duration, tester, notes)
  end
  
  
  def ImportTestCases.parse_test_case_row(stuff, header, row)
    if (row['Type'] == "TestCase")
      @test_case = parse_test_case(stuff, header, row)
    end
    
    if (row['Type'] == "Step")
      parse_step(stuff, row)
    end
  
    if (row['Type'] == "Result")
      parse_result(stuff, row)
    end
  end
  
  
  def ImportTestCases.create_test_cases(stuff, filename)
    input = FasterCSV.read(filename)
    header = input.first #ignores first line
    
    rows = []
    (1...input.size).each { |i| rows << FasterCSV::Row.new(header, input[i]) }
    
    rows.each { |row| parse_test_case_row(stuff, header, row)}
  end
end	