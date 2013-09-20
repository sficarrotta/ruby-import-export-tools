class BaseImport

  # Barry 7/28 Changes to support importation of tags
  def BaseImport.gather_tags(stuff, tagnames)
  
  	if (!tagnames)
  		return nil
  	end
  
  	tags = Array.new
	# find or create the tags
  	tagnames.split('|').each do |tagname| 
    		tag = find_tag(stuff,tagname)
    		tags.push(tag)
  	end
  	
  	return tags
  end
  
  # Used to find multiple folders with the passed name (ie. not just the first one)
  def BaseImport.find_tag(stuff, tagname)  
            if ( tagname != "" and tagname != nil )
              query_result = stuff.slm.find(
                :tag,
                :workspace => stuff.workspace
                ) {equal :name, tagname}
                
              if query_result.total_result_count == 0
                puts "creating #{tagname}\n"
              	return stuff.slm.create(:tag,{:workspace=>stuff.workspace,:name=>tagname})
              end
              return query_result.first
            end
  end
  
  def BaseImport.update_tags(stuff, artifact, tags)
  
  	if tags
  	    	tagfields = {}
  	    	tagfields[:tags] = gather_tags(stuff, tags)
  		artifact.update(tagfields)
	end
        	
  end



  def BaseImport.gather_artifact_fields(stuff, header, row)
    artifact_fields = {
#      :workspace => stuff.workspace,
      :project => stuff.project,
      :name => row["Name"],
      :owner => row["Owner"],
      :description => row["Description"],
      :notes => row["Notes"],
#      :tags => gather_tags(stuff, row["Tags"])
    }
  end
  
  def BaseImport.gather_custom_fields(header,row)
    custom_fields = {}
    
    find_custom_fields(header).each { |field| 
      custom_fields[field.to_sym] = row["Custom:"+field]
    }
    
    find_custom_links(header).each { |field| 
      row_value = row["CustomLink:" + field]
      if row_value != nil
        colon = row_value.index(":")
        id = row_value[0,colon]
        display_string = row_value[colon+1,row_value.length]
    
        custom_fields[field.to_sym] = {:link_i_d => id, :display_string => display_string}
      end
    }
    
    custom_fields
  end

  def BaseImport.find_custom_fields(header)
    custom = []

    header.each { |h|
    	# puts "* #{h}\n"
      if h.include? "Custom:"
        custom << h[7,h.length]
      end
    }
    custom
  end
  
  def BaseImport.find_custom_links(header)
    custom = []
    header.each { |h|
      if h.include? "CustomLink:"
        custom << h[11,h.length]
      end
    }
    custom
  end
  
end