require 'rally_rest_api'
require 'stuff'

class ExportTestCases

  TEST_CASE_FIELDS = %w{Type Name WorkProduct Owner Priority Package Risk Description Notes Objective PreConditions PostConditions
                          ValidationInput ValidationExpectedResult TestFolder StepInput StepExpectedResult Build DateRun Verdict Duration}

  # Barry 7/21/09 - Export folder names with a full path
  
  # Recursive function to traverse folder hierarchy
  def ExportTestCases.create_folder_array( folder, folders)
  	folders.push( folder.name )
  	if (folder.parent)
  	  create_folder_array( folder.parent, folders )
  	end
  end

  def ExportTestCases.test_folder_path( folder )
  	if (folder == nil)
  	   return ""
  	end
  	folders = Array.new
  	create_folder_array( folder, folders)
  	path = ""
  	folders.reverse.each do |name|
  		path += name + "//"
  	end
  	return path
  end
  
  def ExportTestCases.write_step(test_case_csv, step)
    print "  Step: ", step.input, "\n"
  
    data = []
    data << "Step"
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << step.input ? step.input : ""
    data << step.expected_result ? step.expected_result : ""
    data << nil
    data << nil
    data << nil
    data << nil
    
    test_case_csv << FasterCSV::Row.new(TEST_CASE_FIELDS, data)
  end
  
  def ExportTestCases.write_result(test_case_csv, result)
    print "  Result: ", result.build, "\n"
    
    data = []
    data << "Result"
    data << nil
    data << nil
    tester = result.tester ? result.tester : ""
    data << check_user(tester)
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << nil
    data << result.build
    data << result.date
    data << result.verdict
    data << result.duration ? result.duration : ""
    
    test_case_csv << FasterCSV::Row.new(TEST_CASE_FIELDS, data)
  end
      
  def ExportTestCases.write_test_case(test_case_csv, test_case)
    print "Test Case: ", test_case.formatted_i_d, " ", test_case.name, "\n"
  
    data = []
    data << "TestCase"
    data << test_case.name
    data << (test_case.work_product ? test_case.work_product.name : "")
  
    owner = test_case.owner ? test_case.owner : ""
    data << check_user(owner)
    data << test_case.priority
    data << test_case.package ? test_case.package : ""
    data << test_case.risk
    data << test_case.description ? test_case.description : ""
    
# for AC
    url_link = ""
    if ( test_case.work_product != nil )
       type = case test_case.work_product.type
          when "Story" then "st"
          when "Feature" then "ft"
          when "SupplementalRequirement" then "dr"
          when "UseCase" then "uc"
          when "Defect" then "df"
          else "ar"
          end
       
       #2009-02-12 - fix for DE4984
       url = "https://rally1.rallydev.com/slm/detail/" + type + "/" + test_case.work_product.object_i_d
       url_link = "<a href='" + url + "'>" + test_case.work_product.name + "</a>"
       puts url_link
    end
    

    data << url_link + "<br>" + (test_case.notes ? test_case.notes : "")
# End for AC
    
#    data << test_case.notes ? test_case.notes : ""
    
    
    data << test_case.objective ? test_case.objective : ""
    data << test_case.pre_conditions ? test_case.pre_conditions : ""
    data << test_case.post_conditions ? test_case.post_conditions : ""
    data << test_case.validation_input ? test_case.validation_input : ""
    data << test_case.validation_expected_result ? test_case.validation_expected_result : ""
    data << test_folder_path(test_case.test_folder)
    data << nil
    data << nil
    data << nil
    data << nil
    
  # TODO Put back in Method/Type once Bob gets around the issues
  # I think method is a reserved word
  # test_case.method barfs
  # Doesn't like type either...
  
    test_case_csv << FasterCSV::Row.new(TEST_CASE_FIELDS, data)
    
  # TODO values.flatten takes care of duplicate name collisions in the hash  
    if test_case.steps
      test_case.steps.each {|step| write_step(test_case_csv, step)}
    end
    
    if test_case.results
      test_case.results.each {|result| write_result(test_case_csv, result)}
    end
  end
  
  def ExportTestCases.export(stuff, filename)
    query_result = stuff.slm.find_all(:test_case, :workspace => stuff.workspace, :project => stuff.project, :projectScopeUp => false, :projectScopeDown => false)
    
    print "Exporting ", query_result.total_result_count, " Test Cases\n"
  
    test_case_csv = FasterCSV.open(filename, "w") 
    test_case_csv << TEST_CASE_FIELDS
    
    count = 0
    query_result.each {|test_case| 
      write_test_case(test_case_csv, test_case)
      count = count + 1
      }

    print "Wrote ", count, "Test Cases\n"
  end

end
