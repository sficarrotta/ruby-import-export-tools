# Written by Mark Ringer @ Rally
# Not a Ruby developer
# Not really a developer anymore
# 
# Small Things
# Would be nice to create Users & Permissions
# 
# Next Steps
# Caching to make things faster
# Unit Testing
# Export/Import Custom Fields & Values
# Should page at 100 instead of the defaul, will be faster
# 
# Minor Issues
# Since we link things together by name, if there are two objects with the same name - oops
# Only works for a single project right now
# Check that you are in the proper Workspace type for creating things
# 

# Turns off some certificate warnings (and probably other things)
$VERBOSE = nil

# needed?
require 'rubygems'
require 'rally_rest_api'
require 'stuff'
require 'property'
require 'import_defects'
require 'import_iterations'
require 'import_releases'
require 'import_stories'
require 'import_test_folders'
require 'import_test_cases'
require 'export_test_cases'
require 'export_cards'
require 'export_defects'
require 'export_releases'
require 'export_iterations'
require 'export_stories'
require 'import_discussions'
require 'import_capacity'

prop_name = "default.properties"
if ARGV[0] != nil
  prop_name = ARGV[0]
end

properties = Properties.load_properties(prop_name)

base_url = properties["setup.base_url"]
if ARGV[1] != nil
  base_url = ARGV[1]
end

workspace_name = nil
if ARGV[2] != nil
  workspace_name = ARGV[2]
end

if (  (properties["releases.export"] != nil and properties["releases.export"].downcase == "true") or
      (properties["iterations.export"] != nil and properties["iterations.export"].downcase == "true") or
      (properties["defects.export"] != nil and properties["defects.export"].downcase == "true") or
      (properties["testcases.export"] != nil and properties["testcases.export"].downcase == "true") or 
      (properties["cards.export"] != nil and properties["cards.export"].downcase == "true") or
      (properties["userstories.export"] != nil and properties["userstories.export"].downcase == "true")
      )

# TODO Have Bob check for valid login
  slm = RallyRestAPI.new(:base_url => base_url,
    :username => properties["export.user.name"],
    :password => properties["export.user.password"])
  
  if workspace_name == nil
    workspace_name = properties["export.workspace"]
  end
  
  workspace = find_workspace(slm, workspace_name)
  project = find_project(workspace, properties["export.project"])
  
  stuff = Stuff.new
  stuff.slm = slm
  stuff.workspace = workspace
  stuff.project = project
  stuff.subscription_id = slm.user.subscription.subscription_id

  puts "Caching Users\n"
  cache_users(stuff)

  #Export
  
  if properties["releases.export"].downcase == "true"
    ExportReleases.export(stuff,properties["releases.export.filename"])
  end
  
  if properties["iterations.export"].downcase == "true"
    ExportIterations.export(stuff,properties["iterations.export.filename"])
  end
  
  if properties["defects.export"].downcase == "true"
    ExportDefects.export(stuff,properties["defects.export.filename"])
  end
  
  if properties["testcases.export"].downcase == "true"
    ExportTestCases.export(stuff,properties["testcases.export.filename"])
  end
  
  if properties["cards.export"].downcase == "true"
    ExportCards.export(stuff,properties["cards.export.filename"])
  end
  
  if properties["userstories.export"].downcase == "true"
    tasks = true
    if properties["userstories.export.tasks"].downcase == "false"
      tasks = false
    end
    ExportStories.export(stuff, properties["userstories.export.filename"], tasks)
  end
  
end # export section

# Setup for Import (this is ugly)
if (  (properties["releases.import"] != nil and properties["releases.import"].downcase == "true") or
      (properties["iterations.import"] != nil and properties["iterations.import"].downcase == "true") or
      (properties["stories.import"] != nil and properties["stories.import"].downcase == "true") or
      (properties["defects.import"] != nil and properties["defects.import"].downcase == "true") or
      (properties["testfolders.import"] != nil and properties["testfolders.import"].downcase == "true") or 
      (properties["testcases.import"] != nil and properties["testcases.import"].downcase == "true") or 
      (properties["discussions.import"] != nil and properties["discussions.import"].downcase == "true") or
      (properties["capacity.import"] != nil and properties["capacity.import"].downcase == "true")
   )
            
# TODO Have Bob check for valid login
  slm1 = RallyRestAPI.new(:base_url => base_url, 
    :username => properties["import.user.name"],
    :password => properties["import.user.password"])
    
  puts slm1.user.login_name
  puts workspace_name
  
  if workspace_name == nil
    workspace_name = properties["import.workspace"]
  end
  
  workspace = find_workspace(slm1, workspace_name)
  project = find_project(workspace, properties["import.project"])
 
  stuff1 = Stuff.new
  stuff1.slm = slm1
  stuff1.workspace = workspace
  stuff1.project = project
  stuff1.subscription_id = slm1.user.subscription.subscription_id

  # Import
  
  if properties["releases.import"].downcase == "true"
    puts "Creating Releases\n"
    create_releases(stuff1,properties["releases.import.filename"])
  end
  
  if properties["iterations.import"].downcase == "true"
    puts "Creating Iterations\n"
    create_iterations(stuff1,properties["iterations.import.filename"])
  end
  
  if properties["stories.import"].downcase == "true"
    ImportStories.create_stories(stuff1, properties["stories.import.filename"])
  end
  
  if properties["defects.import"].downcase == "true"
    ImportDefects.create_defects(stuff1, properties["defects.import.filename"])
  end

  if properties["testfolders.import"].downcase == "true"
    ImportTestFolders.create_test_folders(stuff1, properties["testfolders.import.filename"])
  end
    
  if properties["testcases.import"].downcase == "true"
    ImportTestCases.create_test_cases(stuff1, properties["testcases.import.filename"])
  end

  if properties["discussions.import"].downcase == "true"
    id = ImportDiscussions.new
    id.create_discussions(stuff1, properties["discussions.import.filename"])
  end
  
  if properties["capacity.import"].downcase == "true"
    ImportCapacity.create_capacity(stuff1, properties["capacity.import.filename"])
  end

# Complete hack to get the project scoping back to their defaults
  query_result = stuff1.slm.find_all(:iteration, :project => stuff1.project, :project_scope_up => false, :project_scope_down => true)

end # import section
