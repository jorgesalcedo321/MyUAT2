public class MonitoringPeriodTriggerHandler {
    public void beforeInsertMonitoringPeriods(List<ampi__Reporting_Period__c> newReportingPeriod) {
        for(ampi__Reporting_Period__c rp : newReportingPeriod) {
            Integer matchReportingPeriods = [SELECT Count() FROM ampi__Reporting_Period__c 
                                                                		WHERE ampi__Project__c =: rp.ampi__Project__c AND
                                                                              ampi__Report_Type__c =: rp.ampi__Report_Type__c AND
                                                                              ampi__Label__c =: rp.ampi__Label__c];

            if (matchReportingPeriods > 0) {
                rp.addError('There is already a Monitoring Period with these specifications assigned to this Project. Please review and update where required.');
            }   
        }
    }

    public void beforeUpdateMonitoringPeriods(List<ampi__Reporting_Period__c> newReportingPeriod) {
        //System.debug('####newReportingPeriod:' + newReportingPeriod.size());
        for(ampi__Reporting_Period__c rp : newReportingPeriod) {
            /*System.debug('####newReportingPeriod.ampi__Project__c:' + rp.ampi__Project__c);
            System.debug('####newReportingPeriod.ampi__Report_Type__c:' + rp.ampi__Report_Type__c);
            System.debug('####newReportingPeriod.Id:' + rp.Id);
            System.debug('####newReportingPeriod.ampi__Label__c:' + rp.ampi__Label__c);*/
            Integer matchReportingPeriods = [SELECT Count() FROM ampi__Reporting_Period__c 
                                                                		WHERE ampi__Project__c =: rp.ampi__Project__c AND
                                                                              ampi__Report_Type__c =: rp.ampi__Report_Type__c AND
                                                                              Id !=: rp.Id AND
                                                                              ampi__Label__c =: rp.ampi__Label__c];
            System.debug('####matchReportingPeriods:' + matchReportingPeriods);
            if (matchReportingPeriods > 0) {
                rp.addError('There is already a Monitoring Period with these specifications assigned to this Project. Please review and update where required.');
            }   
        }
    }
}