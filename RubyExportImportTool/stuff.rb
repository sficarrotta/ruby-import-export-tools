require 'rally_rest_api'

class Stuff
    attr_accessor :slm, :workspace, :project, :subscription_id   
end

# The following code is used to make sure that we don't export user names that have been deleted
$users = {}

def toISO8601(date)
  dt = DateTime.new(date)
end

#Convert from ISO-8601 to YYYY-MM-DD
def convert_date(date)
  if ( date == nil )
    return nil
  end
  string_date = date.to_s
  t = string_date.rindex('T')
  string_date = string_date.slice(0,t)
  string_date  
end

def add_user(user)
  $users[user.login_name] = user
  print user.login_name + " "
end

# TODO Does this find all users or just the ones in the current Workspace?
def cache_users(stuff)
  query_result = stuff.slm.find_all(:user)
  query_result.each {|user| add_user(user)}
  puts "\n"
end

def check_user(owner)
  if (owner != "")
    if $users[owner] != nil
      return $users[owner].login_name
    end
  end
  nil
end

#Helper Methods

def find_workspace(slm, name)
  workspace = slm.user.subscription.workspaces.find { |w| w.name == name }
  if workspace == nil
    print "Workspace ", name, " not found\n"
  end
  workspace
end

# Returns nil (Parent) if Project Name is "Parent" added to find open projects
def find_project(workspace, name)
  project = nil
  if ( name != "Parent")
    project = workspace.projects.find { |p| p.name == name && p.state == "Open" }
    if project == nil
      print "Project ", name, " not found\n"
    end
  end
  project
end


def find_iteration(stuff, iteration_name)
  iteration = nil
  if ( iteration_name != "" and iteration_name != nil)
    query_result = stuff.slm.find(:iteration, :project => stuff.project, :project_scope_up => false, :project_scope_down => false) { equal :name, iteration_name }
    if query_result.results.length != 0
      iteration = query_result.results.first
#    else
#      print "ERROR: Could not find Iteration: ", iteration_name, "\n"
    end
  end
  iteration
end

def find_release(stuff, release_name)
  release = nil
  if ( release_name != "" and release_name != nil)
    query_result = stuff.slm.find(:release, :project => stuff.project, :project_scope_up => false, :project_scope_down => false) { equal :name, release_name }
    if query_result.results.length != 0
      release = query_result.results.first
#    else
#      print "ERROR: Could not find Release: ", release_name, "\n"
    end
  end
  release
end

#For User Stories
def find_parent(stuff, parent_name)
  parent = nil
  if ( parent_name != "" and parent_name != nil)
    query_result = stuff.slm.find(:hierarchical_requirement, :project => stuff.project, :workspace => stuff.workspace, :project_scope_up => true, :project_scope_down => true) { equal :name, parent_name }
#    query_result = stuff.slm.find(:hierarchical_requirement, :project => stuff.project) { equal :name, parent_name }
    if query_result.results.length == 0
      print "ERROR: Could not find Parent: ", parent_name, "\n"
    else
      parent = query_result.results.first
    end
  end 
  parent
end


