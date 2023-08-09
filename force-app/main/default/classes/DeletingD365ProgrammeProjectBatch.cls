global class DeletingD365ProgrammeProjectBatch implements Database.Batchable<sObject> {
  private String query;
    
  /*
  Execute Apex Jobs / Check on Setup => Environments => Jobs => Apex Jobs or Scheduled Jobs
  for(integer i = 0; i < 60; i++) {
    String sch = '0 ' + i + ' * * * ?';
    System.debug('i:' + i);
    ScheduledExternalProjectTeamBatch sqrb = new ScheduledExternalProjectTeamBatch();
    system.schedule('Every Hour plus ' + i + ' min', sch, sqrb);
    i = i + 2;
  }*/
    
  global DeletingD365ProgrammeProjectBatch (){
  }
    
  // The batch job starts
  global Database.Querylocator start(Database.BatchableContext bc){
    String query = 'SELECT Id FROM D365_Project_Stand_in__c WHERE unique_field__c = \'TBR\' LIMIT 10';
    System.debug('>>>> start ' + query);
    return Database.getQuerylocator(query);
  } 
  
  // The batch job executes and operates on one batch of records
  global void execute(Database.BatchableContext bc, List<sObject> scope){
            
    List<D365_Project_Stand_in__c> d365ToDelete = new List<D365_Project_Stand_in__c>();

    for(sObject d365 : scope) {
        D365_Project_Stand_in__c toDelete = (D365_Project_Stand_in__c)d365;      
        d365ToDelete.add(toDelete);
    }
      
    Try {  
    	DELETE d365ToDelete;
        System.debug('###d365ToDelete records were removed: ' + d365ToDelete.size());
    } catch(Exception ex) {
        System.debug('###d365ToDelete exception: ' + ex.getMessage());
    }
  }
  
  // The batch job finishes
  global void finish(Database.BatchableContext bc){
    AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
    System.debug('>>>> finish ' + job.Status);
  }
}