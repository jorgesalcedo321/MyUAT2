global class ExternalProjectTeamBatch implements Database.Batchable<sObject> {
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
    
  global ExternalProjectTeamBatch (){
  }
    
  // The batch job starts
  global Database.Querylocator start(Database.BatchableContext bc){
    String query = 'SELECT Id, Project_ID_Text__c, Account_Teams__c FROM ampi__project__c WHERE RecordType.Name IN (\'' + 'Transition' + '\') AND IsActive__c = true AND ampi__Project_status__c NOT IN (\'' + 'Project Closed' + '\',\'' + 'Closed'+ '\',\'' + '\',\'' + 'Cancelled'+ '\',\'' + 'Concept Rejected' + '\',\'' + 'Application Rejected' + '\') AND Account_Teams__c = \'\' LIMIT 10';
    System.debug('>>>> start ' + query);
    return Database.getQuerylocator(query);
  } 
  
  // The batch job executes and operates on one batch of records
  global void execute(Database.BatchableContext bc, List<sObject> scope){
            
    List<ampi__project__c> projectsToUpdate = new List<ampi__project__c>();

    for(sObject proj : scope) {
        Account acc = new Account();
        ampi__Project__c projToUpdate = (ampi__Project__c)proj;      
        acc.Name = projToUpdate.Project_ID_Text__c + ' - External Project Team';
        acc.RecordTypeId = '0121i0000008W2BAAU';
        acc.Shadow_Record__c = true;
        INSERT acc;
        
        projToUpdate.Account_Teams__c = acc.Id;      
        projectsToUpdate.add(projToUpdate);
        //System.debug('####Project ID: ' + projectsTransition + '---' + proj.Id + '/' + acc.Id);
    }
    UPDATE projectsToUpdate;
  }
  
  // The batch job finishes
  global void finish(Database.BatchableContext bc){
    AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
    System.debug('>>>> finish ' + job.Status);
  }
}