require 'rally_rest_api'
require 'stuff'

class ExportStories

  STORY_FIELDS = %w{Type Name Parent Owner Status Blocked Release Iteration PlanEstimate TaskEstimate TaskToDo TaskActuals Rank 
                    Package Description Notes}

  protected

  def ExportStories.write_task(story_csv, task)
    print " Task: ", task.name, "\n"
  
  #Filter out deleted users
    owner = task.owner ? task.owner : ""
    owner = check_user(owner)
    
    data = []
    data << "Task"
    data << task.name
    data << nil #Parent
    data << owner
    data << task.state
    data << task.blocked
    data << nil #Release
    data << nil #Iteration
    data << nil #PlanEstimate
    data << task.estimate ? task.estimate : ""
    data << task.to_do ? task.to_do : ""
    data << task.actuals ? task.actuals : ""
    data << nil #Rank
    data << nil #Package
    data << task.description ? task.description : ""
    data << task.notes ? task.notes : ""
  
    story_csv << FasterCSV::Row.new(STORY_FIELDS, data)  
  end
  
  
                      
  def ExportStories.write_user_story(story_csv, story, export_tasks)
    print "Story: ", story.name, "\n"
  
  #Filter out deleted users
    owner = story.owner ? story.owner : ""
    owner = check_user(owner)
    
    data = []
    data << "Story"
    data << story.name
    data << (story.parent ? story.parent.name : "")
    data << owner
    data << story.schedule_state
    data << story.blocked
    data << (story.release ? story.release.name : "")
    data << (story.iteration ? story.iteration.name : "")
    data << story.plan_estimate
    data << nil
    data << nil
    data << nil
    data << story.rank
    data << (story.package ? story.package : "")
    data << (story.description ? story.description : "")
    data << (story.notes ? story.notes : "")
	
    story_csv << FasterCSV::Row.new(STORY_FIELDS, data)
    
  # TODO Once bob fixes flatten issue, use it for we might break on duplicate task names
    if ( story.tasks != nil and export_tasks == true )
      story.tasks.each {|task| write_task(story_csv, task)}
  #    cards.tasks.values.flatten.each {|name, task| write_task(story_csv, task)}
    end
  
  # Export the stories in a hierarchy
  # This makes round trip export/import of parent/child hierarchy possible
    if story.children != nil 
      story.children.each { |child| write_user_story(story_csv, child, export_tasks)}
    end
  
  end

  public

  def ExportStories.export(stuff, filename, export_tasks)
    # Only select stories without parents, the write_user_story method will export children recursively
    query_result = stuff.slm.find(:hierarchical_requirement, :project => stuff.project) { equal :parent, nil}
    
    print "Exporting ", query_result.total_result_count, " User Stories\n"
  
    story_csv = FasterCSV.open(filename, "w")
    story_csv << STORY_FIELDS
  
    query_result.each {|story| write_user_story(story_csv, story, export_tasks)}
  end
end