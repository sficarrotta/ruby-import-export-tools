require 'rally_rest_api'
require 'stuff'
require 'fastercsv'

class ExportDefects

  DEFECT_FIELDS = %w{Name Requirement Severity Priority State Environment Resolution SubmittedBy Owner Package	
                     FoundIn FixedIn TargetBuild VerifiedIn ReleaseNote AffectsDoc Description Notes}                  
    
  protected

  def ExportDefects.write(defect_csv, defect)
    print "Defect: ", defect.name, "\n"
  
    data = []
    data << defect.name
    data << (defect.requirement ? defect.requirement.name : "")
    data << defect.severity
    data << defect.priority  
    data << defect.state
    data << defect.environment
    data << defect.resolution
    
    submitted_by = defect.submitted_by ? defect.submitted_by : ""
    data << check_user(submitted_by)
  
    owner = defect.owner ? defect.owner : ""
    data << check_user(owner)
  
    data << defect.package ? defect.package : ""
    data << defect.found_in_build ? defect.found_in_build : ""
    data << defect.fixed_in_build ? defect.fixed_in_build : ""
    data << defect.target_build ? defect.target_build : ""
    data << defect.verified_in_build ? defect.verified_in_build : ""
    data << defect.release_note
    data << defect.affects_doc
    data << defect.description ? defect.description : ""
    data << defect.notes ? defect.notes : ""
  
    defect_csv << FasterCSV::Row.new(DEFECT_FIELDS, data)
  end

  public

  def ExportDefects.export(stuff, filename)
    
#    TypeDefinition.get_type_definition(stuff.workspace, "Defect").custom_attributes.each { |td| puts td.inspect }
#  
#    return
  
    query_result = stuff.slm.find_all(:defect, :project => stuff.project)
    
    print "Exporting ", query_result.total_result_count, " Defects\n"
  
    defect_csv = FasterCSV.open(filename, "w") 
    defect_csv << DEFECT_FIELDS
    
    query_result.each {|defect| write(defect_csv, defect)}
  end
end