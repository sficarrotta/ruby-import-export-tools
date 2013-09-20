require 'rally_rest_api'
require 'stuff'


class ExportReleases

  RELEASE_FIELDS = %w{Name Theme StartDate(YYYY-MM-DD) EndDate(YYYY-MM-DD) Resources State}

  protected
  
  def ExportReleases.write(release_csv, release)
    print "Release: ", release.name, "\n"
  
    data = []
    data << release.name
    data << release.theme ? release.theme : ""
    data << convert_date(release.release_start_date)
    data << convert_date(release.release_date)
    data << release.resources ? release.resources : ""
    data << release.state
  
    release_csv << FasterCSV::Row.new(RELEASE_FIELDS, data)
  
  end
  
  def ExportReleases.export(stuff, filename)
    query_result = stuff.slm.find_all(:release, :project => stuff.project) 
    
    print "Exporting ", query_result.total_result_count, " Releases\n"
  
    release_csv = FasterCSV.open(filename, "w") 
    release_csv << RELEASE_FIELDS
    
    query_result.each {|release| write(release_csv, release)}
  end
  
end