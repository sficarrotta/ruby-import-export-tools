require 'rally_rest_api'
require 'time'
require 'stuff'
require 'import_scheduleable'

class ImportStories < ImportScheduleable

  @count = 0
  @story = nil
  
  def ImportStories.add_tasks( stuff, story )
      
      task = { :workspace => stuff.workspace,
               :project => stuff.project,
               :name => "My awesome task!",
               :state => "Defined",
               :estimate => 9.0,
               :work_product => story
      }
      
      rally_task = stuff.slm.create(:task, task)
      
      print "Created Task : #{rally_task.formatted_i_d}\n"

  end

  def ImportStories.create_story(stuff, fields)
  	return stuff.slm.create(:hierarchical_requirement, fields)
  end
  
  def ImportStories.validate_story(row)
    if (row['TaskEstimate'] != "" and row['TaskEstimate'] != nil)
      puts "WARNING: Ignoring TaskEstimate on Story #{row['Name']}"
    end
    
    if (row['TaskToDo'] != "" and row['TaskToDo'] != nil)
      puts "WARNING: Ignoring TaskToDo on Story #{row['Name']}"
    end
    
    if (row['TaskActual'] != "" and row['TaskActual'] != nil)
      puts "WARNING: Ignoring TaskActual on Story #{row['Name']}"
    end
  end
 
  #TODO Make this the same as the create but if the story exists, update it
  def ImportStories.update_story(stuff, header,row)
    name = row['Name']
    state = row['Status']
    description = row['Description']
    owner = row['Owner']
    blocked = row['Blocked']
    release_name = row['Release']
    iteration_name = row['Iteration']
    notes = row['Notes']
#   puts gather_custom_fieldsfields
    
#          :parent => find_parent(stuff, row['Parent']),
    if (row['Parent'] != nil)    
    	parent = find_parent(stuff, row['Parent'])
    	if (parent == nil)
    		puts "Unable to find parent story '#{row['Parent']}'"
    	end
    end
    
    print "Updating: ", name, "\n"
  
    story = nil
    if ( name != "" and name != nil)
      query_result = stuff.slm.find(:hierarchical_requirement, :project => stuff.project, :project_scope_up => true, :project_scope_down => true) { equal :name, name }
      story = query_result.results.first
  
      fields = {
        :project => stuff.project
      }

      # update parent
      if ( parent != nil)
        fields[:parent] = parent
      end
  
      if ( story != nil )  
        if ( state != nil )
          fields[:schedule_state] = state
        end
        
        if ( description != nil )
          fields[:description] = description
        end
        
        if ( owner != nil )
          fields[:owner] = owner
        end
        
        if ( blocked != nil )
          fields[:blocked] = blocked
        end
        
        if ( release_name != nil )
          release = find_release(stuff, release_name)
          if ( release != nil )
            fields[:release] = release
          end
        end
  
        if ( iteration_name != nil )
          iteration = find_iteration(stuff, iteration_name)
          if ( iteration != nil )
            fields[:iteration] = iteration
          end
        end         
        fields.merge!(gather_custom_fields(header, row))
        story.update(fields)
      end
    end
     
  end
    
  def ImportStories.parse_story(stuff, header, row)
    @count = @count + 1
    validate_story(row)
    
    fields = {
      :parent => find_parent(stuff, row['Parent']),
    }

    fields.merge!(gather_artifact_fields(stuff, header, row))
    fields.merge!(gather_scheduleable_fields(stuff, header, row))
    fields.merge!(gather_custom_fields(header, row))

    print "Story: ", row['Name'], "\n"
    story = create_story(stuff, fields)
    print "Created story #{story.formatted_i_d}\n"
    
    update_tags(stuff,story,row["Tags"])
    return story

  end
  
  def ImportStories.parse_story_row(stuff, header, row)
    if (row['Type'] == "Story")
      @story = parse_story(stuff, header, row)
      add_tasks(stuff, @story)
    end
    
    if (row['Type'] == "UpdateStory") 
      update_story(stuff, header, row)
      updatestoryname = row['Name']
      updatestoryname.gsub(/^\s+/, "").gsub(/\s+$/, $/)
      # requery for the story so that we can pass it into the parse_task method.
      # this allows us to add tasks as part of an UpdateStory operation.
        query_result = stuff.slm.find(:hierarchical_requirement, :project => stuff.project, :project_scope_up => true, :project_scope_down => true) { equal :name, updatestoryname }
       @story = query_result.results.first
       if @story == nil
       	puts "Unable to find story ", row['Name']
       end
              
    end
    
    if (row['Type'] == "Task")
      parse_task(stuff, @story, header, row)
    end
  
  end
  
  
  def ImportStories.create_stories(stuff, filename)
    input = FasterCSV.read(filename)
    header = input.first #header row
    
    rows = []
    (1...input.size).each { |i| rows << FasterCSV::Row.new(header, input[i]) }
    
    rows.each { |row| parse_story_row(stuff, header, row)}
  
    print "Created ", @count, " Stories"
  end

end