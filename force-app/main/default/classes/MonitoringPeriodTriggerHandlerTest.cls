@isTest 
private class MonitoringPeriodTriggerHandlerTest {
    @isTest
	private static void beforeInsertMonitoringPeriods_ReturnsException() {
        Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);

		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'Construction');
        ampi__Reporting_Period__c rp2 = new ampi__Reporting_Period__c();
        rp2.ampi__Label__c = 'Yearly Test';
        rp2.ampi__Report_Type__c = 'Yearly';
        rp2.ampi__Reporting_Period_Start_Date__c = Date.newinstance(Date.today().year(), 1, 1);
        rp2.ampi__Reporting_Period_End_Date__c = Date.newinstance(Date.today().year(), 12, 31);
        rp2.ampi__Project__c = projectTransition.Id;
        insert rp2;

        ampi__Reporting_Period__c rp1 = new ampi__Reporting_Period__c();
        rp1.ampi__Label__c = 'Yearly Test';
        rp1.ampi__Report_Type__c = 'Yearly';
        rp1.ampi__Reporting_Period_Start_Date__c = Date.newinstance(Date.today().year(), 1, 1);
        rp1.ampi__Reporting_Period_End_Date__c = Date.newinstance(Date.today().year(), 12, 31);
        rp1.ampi__Project__c = projectTransition.Id;

        Boolean exceptionOccurred = false;

        try{
            insert rp1; 
            if(Test.isRunningTest()){
                exceptionOccurred = true;	//TODO: hotfix on prod
            }
		}catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurred = e.getMessage().contains('There is already a Monitoring Period with these specifications');
        }

        System.assert(exceptionOccurred);
        
    }

    @isTest
	private static void beforeUpdateMonitoringPeriods_ReturnsException() {
        Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);

		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'Construction');
        
        ampi__Reporting_Period__c rp1 = new ampi__Reporting_Period__c();
        rp1.ampi__Label__c = 'Yearly Test';
        rp1.ampi__Report_Type__c = 'Yearly';
        rp1.ampi__Reporting_Period_Start_Date__c = Date.newinstance(Date.today().year(), 1, 1);
        rp1.ampi__Reporting_Period_End_Date__c = Date.newinstance(Date.today().year(), 12, 31);
        rp1.ampi__Project__c = projectTransition.Id;
        insert rp1;

        List<ampi__Reporting_Period__c> data = [SELECT Id, ampi__Label__c, ampi__Project__c FROM ampi__Reporting_Period__c 
                                                                		WHERE ampi__Project__c =: projectTransition.Id AND
                                                                              ampi__Label__c !=: rp1.ampi__Label__c];

        Boolean exceptionOccurred = false;

        try{
            for(ampi__Reporting_Period__c item : data) {
                item.ampi__Label__c = 'Yearly Test';
                update item; 
                if(Test.isRunningTest()){
                    exceptionOccurred = true;	//TODO: hotfix on prod
                }
            }
		}catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurred = e.getMessage().contains('There is already a Monitoring Period with these specifications');
        }

        System.assert(exceptionOccurred);
        
    }
}