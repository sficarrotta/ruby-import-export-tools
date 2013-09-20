
require 'rally_rest_api'
require 'stuff'
require 'fastercsv'

class ImportDiscussions

  def parse_discussion(stuff, row)
    type = row['Type']
    name = row['Name']
    owner = row['Owner']
    text = row['Text']
    
    # Barry 10/28 - allow use of "story" in addition to h_r
    if (type.downcase == "story")
    	type = "Hierarchical_Requirement"
    end
    
    # Deal with actual object name references later
    # * adds the discussion text to all objects of that type
    if name == '*'
      query_result = stuff.slm.find_all(type.downcase, :project => stuff.project)
      query_result.each { |object|
        puts type + ":Discussion " + object.name + " - " + text
        stuff.slm.create(:conversation_post, 
          :artifact => object,
          :user_name => owner,
          :text => text,
# BM 10/29 Workaround for bug introduced in 2008.5          
# BM 10/29:workspace => object.workspace,
          :project => object.project)
      }
    # Barry 10/28 look up the artifact by name and just post to that artifact
    else 
    	query_result = stuff.slm.find(:artifact, :project => stuff.project, :project_scope_up => false, :project_scope_down => false) { equal :name,name}
    	if (query_result == nil || query_result.size ==0)
    		puts "Artifact '#{name}' not found!\n"
    	else
    		object = query_result.first
    		puts "Object:#{object} owner:#{owner} text:#{text} object.workspace:#{object.workspace} project:#{object.project}\n"
   	        puts type + ":Discussion " + object.name + " - " + text
	        stuff.slm.create(:conversation_post, 
	          :artifact => object,
	          :user_name => owner,
	          :text => text,
# BM 10/29 Workaround for bug introduced in 2008.5
# BM 10/29        :workspace => object.workspace,
	          :project => object.project)
    	end
    	
    end
    
  end
  
  def create_discussions(stuff, filename)
    input = FasterCSV.read(filename)
    header = input.first #ignores first line
    
    rows = []
    (1...input.size).each { |i| rows << FasterCSV::Row.new(header, input[i]) }
    
    rows.each { |row| parse_discussion(stuff, row)}
  end

end