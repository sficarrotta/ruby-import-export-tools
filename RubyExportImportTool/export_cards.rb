require 'rally_rest_api'
require 'stuff'

class ExportCards

  STORY_FIELDS = %w{Type Name Parent Owner Status Blocked Release Iteration PlanEstimate TaskEstimate TaskToDo TaskActuals Rank 
                      Description Notes}
  
  protected
  
  # Should share with ExportStories class
  def ExportCards.write_task(story_csv, task)
    print " Task: ", task.name, "\n"
  
  #Filter out deleted users
    owner = task.owner ? task.owner : ""
    owner = check_user(owner)
    
    data = []
    data << "Task"
    data << task.name
    data << nil
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
    data << task.description ? task.description : ""
    data << task.notes ? task.notes : ""
  
    story_csv << FasterCSV::Row.new(STORY_FIELDS, data)  
  end
  
  
                      
  def ExportCards.write_card(story_csv, card)
    print "Story: ", card.work_product.name, "\n"
  
  #Filter out deleted users
    owner = card.owner ? card.owner : ""
    owner = check_user(owner)
    
    data = []
    data << "Story"
    data << card.work_product.name
    data << nil
    data << owner
    data << card.state
    data << card.blocked
    data << (card.release ? card.release.name : "")
    data << (card.iteration ? card.iteration.name : "")
    data << card.plan_estimate
    data << nil
    data << nil
    data << nil
    data << card.rank
    data << (card.description ? card.description : "")
    data << (card.notes ? card.notes : "")
  
    story_csv << FasterCSV::Row.new(STORY_FIELDS, data)
    
  # breaks if there are duplicate task names.. I think 
    if card.tasks
      card.tasks.each {|name, task| write_task(story_csv, task)}
  #    cards.tasks.values.flatten.each {|name, task| write_task(story_csv, task)}
    end
  
  end
  
  public
  # Only Works for UC Workspace
  # Dumb for now, iterates through each Card and exports a Story
  # Will even export a Story for a Card that is attached to a Defect - that is bad
  def ExportCards.export(stuff, filename)
    query_result = stuff.slm.find_all(:card, :project => stuff.project)
    print "Exporting ", query_result.total_result_count, " Cards\n"
  
    story_csv = FasterCSV.open(filename, "w")
    story_csv << STORY_FIELDS
  
    query_result.each {|card| write_card(story_csv, card)}
  end
end