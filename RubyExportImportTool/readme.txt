Welcome to Version 0.5 of the Rally Importer/Exporter
This is a very early version of code that helps customers easily import and export to/from the Rally application

Basic Workings
use the following command line to run based on the default.properties file
ruby eximporter.rb

alternatively, you can specify your own properties file as the first argument
ruby eximporter.rb my.properties


Major Limitations
- The code does not do any validations on whether dropdowns are valid between the import & export Workspace
- Attachments are not exported
- Objects are linked together by name, so if duplicate names exist, problems could occur
- Tasks and Stories have to be imported in the same csv file.  The tool assumes the task belongs to the last imported Story
- To import Custom Fields put label the custom field Name with Custom:.  In the workspace configure the name follow a camel case pattern then in the import file following a lower case pattern with underscores for spaces.  
- Each .csv file is for one project.  Break up iteration, stories, defect and other work products by project to succesfully import.