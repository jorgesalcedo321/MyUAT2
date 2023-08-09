public without sharing class ExtraCreateObjects {    
    public static ampi__Financial__c createFinancialWithPU(String name, String activityId, String category, String budgetId, String reportingPeriodId, boolean isReadonly, String puId) {
			ampi__Financial__c newFinancial = new ampi__Financial__c();
            newFinancial.Name = name;
            if (activityId != '') {
                newFinancial.ampi__Activity__c = activityId;
            }
        	newFinancial.ampi__Category__c = category;
            newFinancial.ampi__Budget__c = budgetId;
            newFinancial.ampi__Reporting_Period__c = reportingPeriodId;
            newFinancial.ampi__Amount_Planned__c = 0;
            newFinancial.ampi__Amount_Actual__c = 0;
            newFinancial.Is_ReadOnly__c = isReadonly;
            newFinancial.PU__c = puId;
            INSERT newFinancial;
        	RETURN newFinancial;
    }
    
    public static void createMonitoringPeriodByProjectAndMonth(Id projectId) {
        String reportType = 'Monthly';
        Integer count = 0, reportingPeriodCounts = 0;
        System.debug('####createMonitoringPeriodByProjectAndMonth 1:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
            
        List<ampi__Reporting_Period__c> reportingPeriods = [SELECT ampi__Reporting_Period_Start_Date__c FROM ampi__Reporting_Period__c 
                                                            WHERE ampi__Project__c =: projectId AND 
                                                            	  CALENDAR_YEAR(ampi__Reporting_Period_Start_Date__c) =: Date.today().year() AND 
																  ampi__Report_Type__c = 'Monthly' ORDER BY ampi__Reporting_Period_Start_Date__c  ASC];
                    
        System.debug('####createMonitoringPeriodByProjectAndMonth 2:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        if (reportingPeriods.size() < 12) {
            	List<Monitoring_Period_Config__mdt> mpconf = Monitoring_Period_Config__mdt.getAll().values();
                Integer monthsToInsert = 0;
            
            	if (mpconf.size() > 0) {
                    monthsToInsert = Integer.ValueOf(mpconf[0].Number_MP_Generated_Projects__c);
                }
            
                //List<ampi__Reporting_Period__c> rps = new List<ampi__Reporting_Period__c>();
                for(Integer i = 1; i <= 12; i++) {
                    try {
                        reportingPeriodCounts = 0;
                        Date initialDate = Date.newinstance(Date.today().year(), i, 1); 
                        Date endDate = initialDate.addMonths(1).addDays(-1);
                        for (ampi__Reporting_Period__c rp : reportingPeriods) {
                            if (initialDate == rp.ampi__Reporting_Period_Start_Date__c) {
                            	reportingPeriodCounts++;
                            }
                        }
                        
                        if (reportingPeriodCounts == 0 && count < monthsToInsert) {
                            ampi__Reporting_Period__c reportingPeriod = new ampi__Reporting_Period__c();
                            reportingPeriod.ampi__Label__c = initialDate.year() + '-' + (initialDate.month() + '').leftPad(2,'0');
                            reportingPeriod.ampi__Report_Type__c = reportType;
                            reportingPeriod.ampi__Reporting_Period_Start_Date__c = initialDate;
                            reportingPeriod.ampi__Reporting_Period_End_Date__c = endDate;//reportingPeriod.ampi__Reporting_Period_Start_Date__c.addYears(durationInYears);
                            reportingPeriod.ampi__Project__c = projectId;
                            INSERT reportingPeriod;
                            System.debug('####createMonitoringPeriodByProjectAndMonth 3:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
                            count++;
                        }
                    } catch(Exception ex) {
                        System.debug('#### MP ex: Month ' + i + ':' + ex.getMessage());
                    }
                    //rps.add(reportingPeriod);
                }
                //INSERT rps;                		
            }        
   	}

    @AuraEnabled(cacheable=true)
    public static String CheckIfCanUpdateResultByProject(String projectId) {
            User currentUser = [SELECT id,Contact.AccountId,Name,Profile.UserLicense.Name, Alias FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
            List<string> roles = ExtraCreateObjects.GetRolesAllowedToUpdateResults();
            List<ampi__project_indicator__c> pi = [SELECT id, ampi__project__c, ampi__project__r.RecordType.Name, ampi__project__r.SOS_Implementing_Organisation__c FROM ampi__project_indicator__c WHERE ampi__project__c =: projectId];                    
            
            if (pi.size() > 0) {
                System.debug('####pi[0].ampi__project__c: ' + pi[0].ampi__project__c);
                System.debug('####currentUser.Id: ' + currentUser.Id);
                System.debug('####roles: ' + roles);
                System.debug('####pi[0].ampi__project__r.RecordType.Name: ' + pi[0].ampi__project__r.RecordType.Name);                        
                if (pi[0].ampi__project__r.RecordType.Name == 'Shadow Project') {
                    if (currentUser.Contact.AccountId != pi[0].ampi__project__r.SOS_Implementing_Organisation__c) {
                        return 'INSUFFICIENT_ACCESS_OR_READONLY error for Contact "Organisation" field is different to the project "SOS Implemetation Organisation" field.';
                                // res.addError('INSUFFICIENT_ACCESS_OR_READONLY on "ampi__result__c" row Id:' + res.Id);                                
                    }
                } else {
                    List<Team_member__c> tms = [SELECT Id FROM Team_member__c WHERE Project__c =: pi[0].ampi__project__c AND User__c =: currentUser.Id AND Role__c IN : roles AND Active__c = true];
                    System.debug('####tms.size(): ' + tms.size());        
                    if(tms.size() == 0) {
                        return 'INSUFFICIENT_ACCESS_OR_READONLY error for User is not registered as a "Team member" on the project as Project Contributor or Youthcan roles.';
                        // res.addError('INSUFFICIENT_ACCESS_OR_READONLY on "ampi__result__c" row Id:' + res.Id);
                    }
                }                        
            }
            return ''; 
    }  

    public static String CheckIfCanUpdateResultByProjectIndicator(User currentUser, String project_Indicator, List<string> roles) {
            List<ampi__project_indicator__c> pi = [SELECT id, ampi__project__c, ampi__project__r.RecordType.Name, ampi__project__r.SOS_Implementing_Organisation__c FROM ampi__project_indicator__c WHERE Id =: project_Indicator];                    
            if (pi.size() > 0) {
                System.debug('####pi[0].ampi__project__c: ' + pi[0].ampi__project__c);
                System.debug('####currentUser.Id: ' + currentUser.Id);
                System.debug('####roles: ' + roles);
                System.debug('####pi[0].ampi__project__r.RecordType.Name: ' + pi[0].ampi__project__r.RecordType.Name);                        
                if (pi[0].ampi__project__r.RecordType.Name == 'Shadow Project') {
                    if (currentUser.Contact.AccountId != pi[0].ampi__project__r.SOS_Implementing_Organisation__c) {
                        return 'INSUFFICIENT_ACCESS_OR_READONLY error for Contact "Organisation" field is different to the project "SOS Implemetation Organisation" field.';
                                // res.addError('INSUFFICIENT_ACCESS_OR_READONLY on "ampi__result__c" row Id:' + res.Id);                                
                    }
                } else {
                    List<Team_member__c> tms = [SELECT Id FROM Team_member__c WHERE Project__c =: pi[0].ampi__project__c AND User__c =: currentUser.Id AND Role__c IN : roles AND Active__c = true];
                    System.debug('####tms.size(): ' + tms.size());        
                    if(tms.size() == 0) {
                        return 'INSUFFICIENT_ACCESS_OR_READONLY error for User is not registered as a "Team member" on the project as Project Contributor or Youthcan roles.';
                        // res.addError('INSUFFICIENT_ACCESS_OR_READONLY on "ampi__result__c" row Id:' + res.Id);
                    }
                }                        
            }
            return ''; 
    }  

    public static List<string> GetRolesAllowedToUpdateResults() {
        return new List<string> {'YouthCan! Global MEL Advisor','YouthCan! Global Project Manager','YouthCan! Key Account Manager','YouthCan! Regional Coordinator','YouthCan! Coordinator','YouthCan! Partner','Project Contributor'};
    }
}