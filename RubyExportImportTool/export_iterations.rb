require 'rally_rest_api'
require 'stuff'


class ExportIterations

  ITERATION_FIELDS = %w{Name Theme StartDate(YYYY-MM-DD) EndDate(YYYY-MM-DD) Resources State}

  protected
  
  def ExportIterations.write(iteration_csv, iteration)
    print "Iteration: ", iteration.name, "\n"
  
    data = []
    data << iteration.name
    data << iteration.theme ? iteration.theme : ""
    data << convert_date(iteration.start_date)
    data << convert_date(iteration.end_date)
    data << iteration.resources ? iteration.resources : ""
    data << iteration.state
  
    iteration_csv << FasterCSV::Row.new(ITERATION_FIELDS, data)
  end
  
  public
  
  def ExportIterations.export(stuff, filename)
    query_result = stuff.slm.find_all(:iteration, :project => stuff.project)
    
    print "Exporting ", query_result.total_result_count, " Iterations\n"
  
    iteration_csv = FasterCSV.open(filename, "w") 
    iteration_csv << ITERATION_FIELDS
  
    query_result.each {|iteration| write(iteration_csv, iteration)}
  end
  
end