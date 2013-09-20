require 'rally_rest_api'
require 'time'
require 'stuff'
require 'base_import'

class ImportScheduleable < BaseImport
  
  def ImportScheduleable.gather_scheduleable_fields(stuff, header, row)
    blocked = row['Blocked']
  # set this to a default so folks don't have to put in a bunch of Falses
    if ( blocked == "" or blocked == nil )
      blocked = false
    end
    
    scheduleable_fields = {
      :schedule_state => row['Status'],
      :blocked => blocked,
      :release => find_release(stuff, row['Release']),
      :iteration => find_iteration(stuff, row['Iteration']),
      :plan_estimate => row['PlanEstimate'],
      :rank => row['Rank'],
      :package => row['Package']
    }
  end
  
  def ImportScheduleable.create_task(stuff, fields)
    stuff.slm.create(:task, fields)
  end
  
  def ImportScheduleable.validate_task(row)
    if (row['Release'] != "" and row['Release'] != nil)
      puts "WARNING: Ignoring Release on Task #{row['Name']}"
    end
  
    if (row['Iteration'] != "" and row['Iteration'] != nil)
      puts "WARNING: Ignoring Iteration on Task #{row['Name']}"
    end  
  
    if (row['PlanEstimate'] != "" and row['PlanEstimate'] != nil)
      puts "WARNING: Ignoring PlanEstimate on Task #{row['Name']}"
    end
  
    if (row['Rank'] != "" and row['Rank'] != nil)
      puts "WARNING: Ignoring Rank on Task #{row['Name']}"
    end
  end
  
  def ImportScheduleable.parse_task(stuff, story, header, row)
    validate_task(row)
        
    blocked = row['Blocked']
  # default this so people don't need to enter it every time
    if ( blocked == "" or blocked == nil )
      blocked = false
    end
  
    state = row['Status']
  # default this so people don't need to enter it every time
    if ( state == "" or state == nil )
      state = "Defined"
    end
    
    fields = {
      :work_product => story,
      :blocked => blocked,
      :estimate => row['TaskEstimate'],
      :to_do => row['TaskToDo'],
      :actuals => row['TaskActuals'],
      :state => state
      }
    
    fields.merge!(gather_artifact_fields(stuff, header, row))
    
    #puts story.workspace.name
    #puts story.project.name
    #puts stuff.workspace.name
    #puts stuff.project.name
    #puts fields[:work_product]
    
    #puts fields
        
    print "  Task: ", row['Name'], "\n"
    create_task(stuff, fields)
  end
  
end