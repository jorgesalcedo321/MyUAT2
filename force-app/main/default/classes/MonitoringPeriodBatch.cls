global class MonitoringPeriodBatch implements Database.Batchable<sObject> {
  private String query;
    
  /*
  Execute Apex Jobs / Check on Setup => Environments => Jobs => Apex Jobs or Scheduled Jobs
  for(integer i = 0; i < 60; i++) {
    String sch = '0 ' + i + ' * * * ?';
    System.debug('i:' + i);
    ScheduledMonitoringPeriodBatch sqrb = new ScheduledMonitoringPeriodBatch();
    system.schedule('Every Hour plus ' + i + ' min', sch, sqrb);
    i = i + 4;
  }
  
  global MonitoringPeriodBatch (String soql){
    query = soql;
  }*/
    
  global MonitoringPeriodBatch (){
  }
    
  // The batch job starts
  global Database.Querylocator start(Database.BatchableContext bc){
    // String query = 'SELECT Id FROM ampi__project__c WHERE RecordType.Name IN (\'' + 'Standard' + '\', \'' + 'Grant' + '\', \'' + 'Transition' + '\', \'' + 'Humanitarian' + '\') AND IsActive__c = true AND ID NOT IN (SELECT ampi__project__c FROM ampi__reporting_period__c where ampi__Report_Type__c = \'' + 'Monthly' + '\' AND CALENDAR_YEAR(ampi__Reporting_Period_Start_Date__c) = 2023) LIMIT 20';
    // String query = 'SELECT Id FROM ampi__project__c WHERE RecordType.Name IN (\'' + 'Standard' + '\', \'' + 'Grant' + '\', \'' + 'Humanitarian' + '\') AND IsActive__c = true AND ampi__Project_status__c NOT IN (\'' + 'Project Closed' + '\',\'' + 'Cancelled'+ '\',\'' + 'Concept Rejected' + '\',\'' + 'Application Rejected' + '\') AND ID NOT IN (SELECT ampi__project__c FROM ampi__reporting_period__c where ampi__Report_Type__c = \'' + 'Monthly' + '\' AND CALENDAR_YEAR(ampi__Reporting_Period_Start_Date__c) = 2023) LIMIT 20';
    // String query = 'SELECT Id FROM ampi__project__c WHERE RecordType.Name IN (\'' + 'Shadow Project' + '\') AND IsActive__c = true AND ampi__Project_status__c NOT IN (\'' + 'Project Closed' + '\',\'' + 'Cancelled'+ '\',\'' + 'Concept Rejected' + '\',\'' + 'Application Rejected' + '\') AND ID NOT IN (SELECT ampi__project__c FROM ampi__reporting_period__c where ampi__Report_Type__c = \'' + 'Monthly' + '\' AND CALENDAR_YEAR(ampi__Reporting_Period_Start_Date__c) = 2023) AND Name LIKE \'National Office%\' LIMIT 20';     
    String query = 'SELECT Id FROM ampi__project__c WHERE RecordType.Name IN (\'' + 'Transition' + '\') AND IsActive__c = true AND ampi__Project_status__c NOT IN (\'' + 'Project Closed' + '\',\'' + 'Cancelled'+ '\',\'' + 'Concept Rejected' + '\',\'' + 'Application Rejected' + '\') AND ID NOT IN (SELECT ampi__project__c FROM ampi__reporting_period__c where ampi__Report_Type__c = \'' + 'Monthly' + '\' AND CALENDAR_YEAR(ampi__Reporting_Period_Start_Date__c) = 2023) LIMIT 20';     
    System.debug('>>>> start ' + query);
    return Database.getQuerylocator(query);
  } 
  
  // The batch job executes and operates on one batch of records
  global void execute(Database.BatchableContext bc, List<sObject> scope){
    System.debug('>>>> execute ' + scope.size());
	List<ampi__reporting_period__c> periods = new List<ampi__reporting_period__c>();

    for(sObject proj : scope) {
        for(Integer i = 1; i <= 12; i++) {
            ampi__reporting_period__c newPeriod = new ampi__reporting_period__c();
            newPeriod.ampi__Reporting_Period_Start_Date__c = Date.newInstance(2023, i, 1);
            newPeriod.ampi__Reporting_Period_End_Date__c = newPeriod.ampi__Reporting_Period_Start_Date__c.addMonths(1).addDays(-1);
            newPeriod.ampi__project__c = proj.Id;
            String month = (newPeriod.ampi__Reporting_Period_Start_Date__c.month() > 9 ? '' : '0') + newPeriod.ampi__Reporting_Period_Start_Date__c.month();
            newPeriod.ampi__label__c = newPeriod.ampi__Reporting_Period_Start_Date__c.year() + '-' + month;
            newPeriod.ampi__Report_Type__c = 'Monthly';
            periods.add(newPeriod);
        }
        System.debug('###proj.Id:' + proj.Id);
    }
    
    INSERT periods;    
  }
  
  // The batch job finishes
  global void finish(Database.BatchableContext bc){
    AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
    System.debug('>>>> finish ' + job.Status);
  }
}