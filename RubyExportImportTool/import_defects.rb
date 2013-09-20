require 'rally_rest_api'
require 'time'
require 'stuff'
require 'fastercsv'
require 'base_import'
require 'import_scheduleable'

#class ImportDefects < BaseImport
class ImportDefects < ImportScheduleable

  @defect = nil

  def ImportDefects.create_defect(stuff, fields)
  
  	@defect = stuff.slm.create(:defect, fields)
  end
  
  
  def ImportDefects.parse_defect(stuff, header, row)
  
      requirement_name = row['Requirement']
      req = nil
      if ( requirement_name != "" and requirement_name != nil )
        query_result = stuff.slm.find(:requirement, :project => stuff.project) { equal :name, requirement_name }
        if ( query_result.results != nil )
          if (query_result.results.length >= 1) # Need to deal with lookups by name returning more than one value
            req = query_result.results.first
          end
        end
      end

    release_note = row["ReleaseNote"]
    if ( release_note == "" or release_note == nil )
      release_note = false
    end
    
    affects_doc = row["AffectsDoc"]
    if ( affects_doc == "" or affects_doc == nil )
       affects_doc = false
    end
    
    #barry - import release if defined
    releaseobj = nil 
    if (row['Release'] != nil)
    	release = row['Release']
	query_result = stuff.slm.find(:release, :release => stuff.project, :project_scope_up => true, :project_scope_down => true) { equal :name, release }
	releaseobj = query_result.results.first
	if releaseobj == nil
		puts "Unable to find release:#{release}"
	end
    end
    
    puts "creating in release #{row['Release']}"
    
    fields = {
      :release => releaseobj,
      :requirement => req,
      :severity => row['Severity'],
      :priority => row['Priority'],
      :state => row['State'],
      :rank => row['Rank'],
      :plan_estimate => row['PlanEstimate'],
      :environment => row['Environment'],
      :resolution => row['Resolution'],
      :submitted_by => row['SubmittedBy'],
      :package => row['Package'],
      :found_in_build => row['FoundIn'], 
      :fixed_in_build => row['FixedIn'], 
      :target_build => row['TargetBuild'], 
      :verified_in_build => row['VerifiedIn'], 
      :release_note => release_note, 
      :affects_doc => affects_doc, 
    }
  
    fields.merge!(gather_artifact_fields(stuff, header,row))
    fields.merge!(gather_custom_fields(header, row))
    
    # Barry - delete any fields that are nil
    fields.delete_if {|key, value| value == nil } 
    
    print "Defect: ", row['Name'], "\n"
    
    # Barry 11/1 - add support for UpdateDefect
    if row['Type'] == "UpdateDefect"
        query_result = stuff.slm.find(:defect, :project => stuff.project) { equal :name, row['Name']}    	
        updateDefect = query_result.first
        updateDefect.update(fields)
    else
    	create_defect(stuff, fields)
    end
    print "#{@defect.name}\n"
    print "#{@defect.name}\n"
  end
  
  def ImportDefects.create_defects(stuff, filename)
    input = FasterCSV.read(filename)
    
    header = input.first #ignores first line
  
    rows = []
    (1...input.size).each { |i| rows << FasterCSV::Row.new(header, input[i]) }
    
    rows.each { |row| 
    
          if (row['Type'] != nil && row['Type'] == "Task")
    	  	parse_task(stuff, @defect, header, row)
    	  else
    		parse_defect(stuff, header, row)            
          end

        
    }
  end
end
