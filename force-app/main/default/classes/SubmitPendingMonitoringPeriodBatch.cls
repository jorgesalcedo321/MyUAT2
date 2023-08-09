global class SubmitPendingMonitoringPeriodBatch implements Database.Batchable<sObject>{
	private String query;
    public Integer numberOfRecords;
    
  /*
  Execute Apex Jobs / Check on Setup => Environments => Jobs => Apex Jobs or Scheduled Jobs
  //String sch = '0 1 * * * ?';
Integer day = 44;
Integer hour = 14;
Integer month = 39;
Integer count = 1;
String sch = '0 ' + month + ' ' + hour + ' ' + day + ' * * ';   // 8:30am every 1st day of the month

for(Integer i=month; i<60; i++) {
    ScheduledSubmitPendingMonitoringPeriod sqrb = new ScheduledSubmitPendingMonitoringPeriod();
    sqrb.numberOfRecords = 1000;
    system.schedule('ScheduledSubmitPendingMonitoringPeriod Day:' + day + ' hour:' + hour + ' month:' + i + ' v:' + count, sch, sqrb);
    count++;
}
*/
    
  global SubmitPendingMonitoringPeriodBatch(Integer records){
      this.numberOfRecords = records;
  }
    
  // The batch job starts
  global Database.Querylocator start(Database.BatchableContext bc){
    String query = 'SELECT Id, ampi__Result_Status__c, ampi__Results_Locked__c FROM ampi__Reporting_Period__c WHERE (CALENDAR_YEAR(ampi__Reporting_Period_Start_Date__c) = 2022 OR CALENDAR_YEAR(ampi__Reporting_Period_End_Date__c) = 2022) AND ampi__Result_Status__c <> \'Submitted\' AND ampi__Project__r.RecordType.Name = \'Shadow Project\' LIMIT ' + this.numberOfRecords;
    System.debug('####query:' + query);
    return Database.getQuerylocator(query);
  } 
  
  // The batch job executes and operates on one batch of records
  global void execute(Database.BatchableContext bc, List<sObject> scope){            
    List<ampi__Reporting_Period__c> mpsToUpdate = new List<ampi__Reporting_Period__c>();
    for(sObject mp : scope) {
        ampi__Reporting_Period__c toUpdate = (ampi__Reporting_Period__c)mp;      
        toUpdate.ampi__Result_Status__c = 'Submitted';
        toUpdate.ampi__Results_Locked__c = true;
        toUpdate.ampi__Date_Submitted__c = date.today();
        mpsToUpdate.add(toUpdate);
    }
      
    Try {  
    	UPDATE mpsToUpdate;
        System.debug('###mpsToUpdate records were removed: ' + mpsToUpdate.size());
    } catch(Exception ex) {
        System.debug('###mpsToUpdate exception: ' + ex.getMessage());
    }
  }
  
  // The batch job finishes
  global void finish(Database.BatchableContext bc){
    AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
    System.debug('>>>> finish ' + job.Status);
  }
}