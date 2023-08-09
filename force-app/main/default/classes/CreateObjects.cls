public class CreateObjects {
    //https://bluecanvas.io/blog/how-to-structure-and-manage-your-apex-codebase-for-scale-and-agility
	public static ampi__Budget__c createBudget(String name, String descr, String projectId, boolean isReadonly) {
		ampi__Budget__c newBudgetPSCI = new ampi__Budget__c();
        newBudgetPSCI.Name = name;
        newBudgetPSCI.ampi__Description__c = descr;
        newBudgetPSCI.ampi__Project__c = projectId;
        newBudgetPSCI.Auto_Created__c = true;
        newBudgetPSCI.Is_ReadOnly__c = isReadonly;       
        INSERT newBudgetPSCI;
        RETURN newBudgetPSCI;
	}
    
    public static Function__c createFunction(String name, String oun) {
		Function__c newFunction = new Function__c();
        newFunction.Name = name;
        newFunction.Operating_Unit_Number__c = oun;
        newFunction.Search_Name__c = name;
        INSERT newFunction;
        RETURN newFunction;
	}
    
    public static ampi__Financial__c createFinancial(String name, String activityId, String category, String budgetId, String reportingPeriodId, boolean isReadonly) {
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
            INSERT newFinancial;
        	RETURN newFinancial;
    }

    public static ampi__Financial__c createFinancialRelatedToActivity(String name, String activityId, String category, String budgetId, String reportingPeriodId, String atype, boolean isReadonly) {
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
            newFinancial.ampi__Type__c = atype;
            newFinancial.Is_ReadOnly__c = isReadonly;
            INSERT newFinancial;
        	RETURN newFinancial;
    }
    
    public static ampi__Disbursement__c createDisbursement(String projectId, String periodId, boolean isReadonly) {
     	   ampi__Disbursement__c newDisbursement = new ampi__Disbursement__c();
           newDisbursement.ampi__Project__c = projectId;
           newDisbursement.ampi__Reporting_Period__c = periodId;
           newDisbursement.Auto_Created__c = true; 
           newDisbursement.Is_ReadOnly__c = isReadonly;       
           INSERT newDisbursement;
           RETURN newDisbursement;
    }
    
    public static ampi__Reporting_Period__c manageMonitoringPeriodByProject(Id projectId, Integer durationInYears) {
        List<ampi__Reporting_Period__c> reportingPeriods = [SELECT Id FROM ampi__Reporting_Period__c 
                                                                		WHERE ampi__Project__c =: projectId
                                                                        ORDER BY ampi__Reporting_Period_End_Date__c DESC];

            system.debug('### reportingPeriods:' + reportingPeriods.size()); 
            String reportingPeriodId;  
                    
            if (reportingPeriods.size() == 0) {
                        ampi__Reporting_Period__c reportingPeriod = new ampi__Reporting_Period__c();
                        reportingPeriod.ampi__Label__c = 'Yearly';
                    	reportingPeriod.ampi__Report_Type__c = 'Yearly';
                        reportingPeriod.ampi__Reporting_Period_Start_Date__c = Date.newinstance(Date.today().year(), 1, 1);
                        reportingPeriod.ampi__Reporting_Period_End_Date__c = Date.newinstance(Date.today().year(), 12, 31);//reportingPeriod.ampi__Reporting_Period_Start_Date__c.addYears(durationInYears);
                        reportingPeriod.ampi__Project__c = projectId;

                        INSERT reportingPeriod;
                		RETURN reportingPeriod;
            } else {
    		    return reportingPeriods[0];
            }        
   	}

    /*public static List<ampi__Catalog_Objective__c> manageCatalogObjectivesFromProject(List<ampi__Catalog_Objective__c> catalogObjectives) {
        List<ampi__Catalog_Objective__c> newCatalogObjectives = new List<ampi__Catalog_Objective__c>(); 
                    for(ampi__Catalog_Objective__c catalogObjective : catalogObjectives) {
                        ampi__Catalog_Objective__c newCatalogObjective = new ampi__Catalog_Objective__c();
                        newCatalogObjective.Name = catalogObjective.Name; 
                        newCatalogObjective.ampi__Definition__c = catalogObjective.ampi__Definition__c; 
                        newCatalogObjective.ampi__Level__c = catalogObjective.ampi__Level__c;
                        newCatalogObjectives.add(newCatalogObjective);
                    }
                    
                    if (newCatalogObjectives.size() > 0) {
                        insert newCatalogObjectives;
                    }
        RETURN newCatalogObjectives;
    }
    
    public static Map<String, String> updateObjectives(List<ampi__Objective__c> newObjectives, List<ampi__Catalog_Objective__c> catalogObjectives, List<ampi__Catalog_Objective__c> newCatalogObjectives) {
        Map<String, String> catalogObjectiveMatchIds = new Map<String, String>();
        for (ampi__Catalog_Objective__c catalogObjective : catalogObjectives)
                        {
                            for (ampi__Catalog_Objective__c newCatalogObjective : newCatalogObjectives)
                            {
								if (catalogObjective.Name == newCatalogObjective.Name && 
                                    catalogObjective.ampi__Definition__c == newCatalogObjective.ampi__Definition__c && 
                                    catalogObjective.ampi__Level__c == newCatalogObjective.ampi__Level__c && 
                                    !catalogObjectiveMatchIds.containsKey(catalogObjective.Id)) {
                                    catalogObjectiveMatchIds.put(catalogObjective.Id, newCatalogObjective.Id);
                                }
                            }
                        }
                   for(ampi__Objective__c newObjective : newObjectives) {
                        if(catalogObjectiveMatchIds.containsKey(newObjective.ampi__Objective__c)) {
                        	newObjective.ampi__Objective__c = catalogObjectiveMatchIds.get(newObjective.ampi__Objective__c);
                        	UPDATE newObjective;
                        }
                    }
        
        //RETURN newObjectives;
        RETURN catalogObjectiveMatchIds;
    }

    public static List<ampi__Activity__c> updateParentActivityRecords(List<ampi__Activity__c> activities, List<ampi__Activity__c> newActivities, Map<string, string> activitiesMatchIds) {
        for(ampi__Activity__c activity : activities) {
            if(activity.ampi__Parent_Activity__c != NULL && activitiesMatchIds.containsKey((String)activity.ampi__Parent_Activity__c)) {
                for (ampi__Activity__c newActivity : newActivities) {
                    if (activity.Name == newActivity.Name) {
                        newActivity.ampi__Parent_Activity__c = activitiesMatchIds.get(activity.ampi__Parent_Activity__c);
                        UPDATE newActivity;
                    }
                }                        	
            }
        }
        
        //RETURN newObjectives;
        RETURN newActivities;
    }*/

    public static List<ampi__Activity__c> updateParentActivityRecordsByMetadata(List<Construction_Activity_Project__mdt> activities, List<ampi__Activity__c> newActivities) {
        Map<String, String> activitiesMatchIds = GetObjects.getDictionaryFromOldAndNewRecordsMetadata(activities, newActivities, 'Name__c', 'Name', 'Id__c', 'Id');
        System.debug('####activitiesMatchIds:' + activitiesMatchIds);
        for (ampi__Activity__c newActivity : newActivities) {
            for(Construction_Activity_Project__mdt activity : activities) {
                if(activity.Name__c == newActivity.Name && activity.ParentActivityId__c != 'none') {
                    system.debug('####activity.ParentActivityId__c:' + activity.ParentActivityId__c);
                    newActivity.ampi__Parent_Activity__c = activitiesMatchIds.get(activity.ParentActivityId__c);
                    system.debug('####newActivity.ampi__Parent_Activity__c:' + newActivity.ampi__Parent_Activity__c);
                    UPDATE newActivity;
                }
            }
        }
        
        //RETURN newObjectives;
        RETURN newActivities;
    }
    
    /*public static ampi__Disaggregation_Group__c createDisaggregatedGroup(List<ampi__Disaggregation_Group__c> disaggregatedGroups) {
        ampi__Disaggregation_Group__c newDisaggregatedGroup = new ampi__Disaggregation_Group__c();
                    	
                    for(ampi__Disaggregation_Group__c disaggregatedGroup : disaggregatedGroups) {
                        newDisaggregatedGroup = new ampi__Disaggregation_Group__c();
                        newDisaggregatedGroup.Name = disaggregatedGroup.Name;
                        insert newDisaggregatedGroup;
                    }
        RETURN newDisaggregatedGroup;
    }
    public static List<ampi__Disaggregated_Project_Indicator__c> manageDisaggregatedProjectIndicatorsByProject(List<ampi__Disaggregated_Project_Indicator__c> disaggregatedProjectIndicators, Map<string, string> projectIndicatorsMatchIds, String newDisaggregatedGroupId) {
        List<ampi__Disaggregated_Project_Indicator__c> newDisaggregatedProjectIndicators = new List<ampi__Disaggregated_Project_Indicator__c>();            
        
        for(ampi__Disaggregated_Project_Indicator__c disaggregatedProjectIndicator : disaggregatedProjectIndicators) {
                    	ampi__Disaggregated_Project_Indicator__c newDisaggregatedProjectIndicator = new ampi__Disaggregated_Project_Indicator__c();
                        newDisaggregatedProjectIndicator.ampi__Disaggregate_Results__c = disaggregatedProjectIndicator.ampi__Disaggregate_Results__c;
                        newDisaggregatedProjectIndicator.ampi__Disaggregate_Targets__c = disaggregatedProjectIndicator.ampi__Disaggregate_Targets__c;
                        newDisaggregatedProjectIndicator.ampi__Project_Indicator__c = projectIndicatorsMatchIds.containsKey(disaggregatedProjectIndicator.ampi__Project_Indicator__c) ? projectIndicatorsMatchIds.get(disaggregatedProjectIndicator.ampi__Project_Indicator__c) : '';
                        newDisaggregatedProjectIndicator.ampi__Disaggregation_Group__c = newDisaggregatedGroupId;
    					newDisaggregatedProjectIndicators.add(newDisaggregatedProjectIndicator);
                    }
                    
                    if (newDisaggregatedProjectIndicators.size() > 0) {
                    	insert newDisaggregatedProjectIndicators;
                    }
		RETURN newDisaggregatedProjectIndicators;
	}
    public static List<ampi__Disaggregation_Value__c> manageDisaggregationValuesByProject(List<ampi__Disaggregation_Value__c> disaggregationValues, String newDisaggregatedGroupId) {
        List<ampi__Disaggregation_Value__c> newDisaggregationValues = new List<ampi__Disaggregation_Value__c>(); 
					
                    for(ampi__Disaggregation_Value__c disaggregationValue : disaggregationValues) {
                    	ampi__Disaggregation_Value__c newDisaggregationValue = new ampi__Disaggregation_Value__c();
                    	newDisaggregationValue.Name = disaggregationValue.Name;
                        newDisaggregationValue.ampi__Order__c = disaggregationValue.ampi__Order__c;
                        newDisaggregationValue.ampi__Disaggregation_Group__c = newDisaggregatedGroupId;
                        newDisaggregationValues.add(newDisaggregationValue);
                    }
                    
                    
                    if (newDisaggregationValues.size() > 0) {
                    	insert newDisaggregationValues;
                    }
        RETURN newDisaggregationValues;
    }

    public static List<ampi__Project_Indicator_Objective__c> manageProjectIndicatorObjectivesForProject(List<ampi__Project_Indicator_Objective__c> projectIndicatorObjectives, Map<String, String> objectiveMatchIds, Map<String, String> catalogObjectiveMatchIds, Map<String, String> projectIndicatorsMatchIds) {
        List<ampi__Project_Indicator_Objective__c> newProjectIndicatorObjectives = new List<ampi__Project_Indicator_Objective__c>();
        for(ampi__Project_Indicator_Objective__c projectIndicatorObjective : projectIndicatorObjectives) {
                     	   ampi__Project_Indicator_Objective__c newProjectIndicatorObjective = new ampi__Project_Indicator_Objective__c();  
                           
                           //ampi__xx_Framework_Objective__c	Lookup(Project Result Statement) = 	ampi__Objective__c
                           newProjectIndicatorObjective.ampi__xx_Framework_Objective__c = (objectiveMatchIds.containsKey(projectIndicatorObjective.ampi__xx_Framework_Objective__c) ? objectiveMatchIds.get(projectIndicatorObjective.ampi__xx_Framework_Objective__c) : ''); //projectIndicatorObjective.ampi__xx_Framework_Objective__c; 
                           //ampi__Objective__c	Lookup(Result Statement) = ampi__Catalog_Objective__c
                           newProjectIndicatorObjective.ampi__Objective__c = (catalogObjectiveMatchIds.containsKey(projectIndicatorObjective.ampi__Objective__c) ? catalogObjectiveMatchIds.get(projectIndicatorObjective.ampi__Objective__c) : '');
                           
                           newProjectIndicatorObjective.ampi__Project_Indicator__c =  (projectIndicatorsMatchIds.containsKey(projectIndicatorObjective.ampi__Project_Indicator__c) ? projectIndicatorsMatchIds.get(projectIndicatorObjective.ampi__Project_Indicator__c) : '');
                           newProjectIndicatorObjectives.add(newProjectIndicatorObjective);
                    }
                    
                    if (newProjectIndicatorObjectives.size() > 0) {
                        insert newProjectIndicatorObjectives;
                    }
		RETURN newProjectIndicatorObjectives;
	}*/
    public static List<ampi__Project_Indicator_Geographic_Area__c> manageProjectIndicatorGeographicAreaByProjectId(List<ampi__Project_Indicator_Geographic_Area__c> pIGAs, Map<String, String> projectIndicatorsMatchIds) {
            List<ampi__Project_Indicator_Geographic_Area__c> newPIGAs = new List<ampi__Project_Indicator_Geographic_Area__c>();
                    
            for(ampi__Project_Indicator_Geographic_Area__c pIGA : pIGAs) {
                ampi__Project_Indicator_Geographic_Area__c newPIGARecord = new ampi__Project_Indicator_Geographic_Area__c();
                newPIGARecord.ampi__Geographic_Area__c=pIGA.ampi__Geographic_Area__c;

            	if (projectIndicatorsMatchIds.containsKey(pIGA.ampi__Project_Indicator__c)) {
                	newPIGARecord.ampi__Project_Indicator__c=projectIndicatorsMatchIds.containsKey(pIGA.ampi__Project_Indicator__c) ? projectIndicatorsMatchIds.get(pIGA.ampi__Project_Indicator__c) : '';                      
                    newPIGARecord.OwnerId=pIGA.OwnerId;
                    newPIGAs.add(newPIGARecord);
				}
			}

			if (newPIGAs.size() > 0) {
            	System.debug('13. ampi__Project_Indicator_Geographic_Area__c newPIGAs: '+ newPIGAs.size());
                insert newPIGAs;
            }
        	RETURN newPIGAs;
	}
    
    public static List<ampi__Project_Indicator_Reporting_Period__c> manageProjectIndicatorMonitoringPeriodsByProjectId(List<ampi__Project_Indicator_Reporting_Period__c> pIRPs, Map<String, String> projectIndicatorsMatchIds, Map<String, String> reportingPeriodMatchIds) { 
        List<ampi__Project_Indicator_Reporting_Period__c> newPIRPs = new List<ampi__Project_Indicator_Reporting_Period__c>();
        for(ampi__Project_Indicator_Reporting_Period__c pIRP : pIRPs) {
        	ampi__Project_Indicator_Reporting_Period__c newPIRPRecord = new ampi__Project_Indicator_Reporting_Period__c();
            //newPIRPRecord.ampi__Data_Tracked__c=pIRP.ampi__Data_Tracked__c;
			newPIRPRecord.ampi__Data_Tracked__c='Both';

            if (projectIndicatorsMatchIds.containsKey(pIRP.ampi__Project_Indicator__c) && reportingPeriodMatchIds.containsKey(pIRP.ampi__Reporting_Period__c)) {
            	newPIRPRecord.ampi__Project_Indicator__c=projectIndicatorsMatchIds.containsKey(pIRP.ampi__Project_Indicator__c) ? projectIndicatorsMatchIds.get(pIRP.ampi__Project_Indicator__c) : '';                      
                newPIRPRecord.ampi__Reporting_Period__c=reportingPeriodMatchIds.containsKey(pIRP.ampi__Reporting_Period__c) ? reportingPeriodMatchIds.get(pIRP.ampi__Reporting_Period__c) : '';
                newPIRPs.add(newPIRPRecord);
            }
        }

        if (newPIRPs.size() > 0) {
        	System.debug('12. ampi__Project_Indicator_Reporting_Period__c newPIRPs: '+ newPIRPs.size());
            System.debug('12. ampi__Project_Indicator_Reporting_Period__c newPIRPs: '+ newPIRPs);
            INSERT newPIRPs;
		}          
        RETURN newPIRPs;
    }
    
    public static List<ampi__Reporting_Period__c> manageReportingPeriodsByProject(List<ampi__Reporting_Period__c> reportingPeriods, String projectId) {
        List<ampi__Reporting_Period__c> newReportingPeriods = new List<ampi__Reporting_Period__c>();
        for(ampi__Reporting_Period__c reportingPeriod : reportingPeriods) {
                        ampi__Reporting_Period__c newReportingPeriodRecord = new ampi__Reporting_Period__c();
                        newReportingPeriodRecord.ampi__Available_For_Financials__c=reportingPeriod.ampi__Available_For_Financials__c;
                        newReportingPeriodRecord.ampi__Date_Submitted__c=reportingPeriod.ampi__Date_Submitted__c;
                        newReportingPeriodRecord.ampi__Exclude_From_IATI__c=reportingPeriod.ampi__Exclude_From_IATI__c;
                        newReportingPeriodRecord.ampi__Label__c=reportingPeriod.ampi__Label__c;
                        newReportingPeriodRecord.ampi__Project__c=projectId;
                        newReportingPeriodRecord.ampi__Report_Type__c=reportingPeriod.ampi__Report_Type__c;
                        newReportingPeriodRecord.ampi__Reporting_Period_End_Date__c=reportingPeriod.ampi__Reporting_Period_End_Date__c;
                        newReportingPeriodRecord.ampi__Reporting_Period_Start_Date__c=reportingPeriod.ampi__Reporting_Period_Start_Date__c;
                        newReportingPeriodRecord.ampi__Result_Status__c=reportingPeriod.ampi__Result_Status__c;
                        newReportingPeriodRecord.ampi__Results_Locked__c=reportingPeriod.ampi__Results_Locked__c;
                        newReportingPeriodRecord.ampi__Target_Status__c=reportingPeriod.ampi__Target_Status__c;
                        newReportingPeriodRecord.ampi__Targets_Locked__c=reportingPeriod.ampi__Targets_Locked__c;
                        newReportingPeriodRecord.ampi__xx_Active__c=reportingPeriod.ampi__xx_Active__c;
                        newReportingPeriodRecord.Create_Risk_Review_for_Period__c=reportingPeriod.Create_Risk_Review_for_Period__c;
                        newReportingPeriodRecord.RecordTypeId=reportingPeriod.RecordTypeId;
                        newReportingPeriods.add(newReportingPeriodRecord);
                    }

                    if (newReportingPeriods.size() > 0) {
                        System.debug('10. Reporting Periods newReportingPeriods: '+ newReportingPeriods.size());
                        INSERT newReportingPeriods;
                    }
        
        RETURN newReportingPeriods;

    }
    
    public static List<ampi__xx_Framework__c> manageNewFrameworks(List<ampi__xx_Framework__c> baseFrameworks, String newProjectId) {
        List<ampi__xx_Framework__c> newFrameworks = new List<ampi__xx_Framework__c>();
        for (ampi__xx_Framework__c framework : baseFrameworks)
        {
                        System.debug('4. Framework Name: '+ framework.Name);
                        ampi__xx_Framework__c newFrameworkRecord = new ampi__xx_Framework__c();
                        newFrameworkRecord.Name = framework.Name;
                        newFrameworkRecord.ampi__xx_Project__c =newProjectId;
                        newFrameworkRecord.ampi__xx_Description__c = framework.ampi__xx_Description__c;
                        newFrameworkRecord.ampi__xx_Framework_Locked__c = false; //framework.ampi__xx_Framework_Locked__c;
                        newFrameworkRecord.ampi__xx_Status__c = framework.ampi__xx_Status__c;
                        newFrameworkRecord.ampi__xx_Reviewer_Comments__c = framework.ampi__xx_Reviewer_Comments__c;       
                        newFrameworks.add(newFrameworkRecord);
		}
        
        if (newFrameworks.size() > 0) {
            INSERT newFrameworks;
        }
        RETURN newFrameworks;
    }
    
    public static ampi__Project_Geographic_Area__c createPGAsByProjectAndProgramme(String projectId, String programmeId) {
        ampi__Project_Geographic_Area__c newPGARecord = new ampi__Project_Geographic_Area__c();
        newPGARecord.ampi__Geographic_Area__c=programmeId;
        newPGARecord.ampi__Project__c=projectId;
        // newPGARecord.Unique_ID__c=projectId + ' - ' + newPGARecord.id + ' ' + Integer.valueof((Math.random() * 1000));
        INSERT newPGARecord;
        RETURN newPGARecord;
    }

    public static List<ampi__Project_Geographic_Area__c> managePGAsByProject(List<ampi__Project_Geographic_Area__c> pgas, String projectId, String countryId) {
         List<ampi__Project_Geographic_Area__c> newPGAs = new List<ampi__Project_Geographic_Area__c>();
                    
                    for(ampi__Project_Geographic_Area__c pga : pgas) {
                        ampi__Project_Geographic_Area__c newPGARecord = new ampi__Project_Geographic_Area__c();
                        newPGARecord.ampi__Active__c=pga.ampi__Active__c;
                        newPGARecord.ampi__Exclude_From_IATI__c=pga.ampi__Exclude_From_IATI__c;
                        if (countryId == '') {
                        	newPGARecord.ampi__Geographic_Area__c=pga.ampi__Geographic_Area__c;
                        } else {
                            newPGARecord.ampi__Geographic_Area__c=countryId;
                        }
                        newPGARecord.ampi__Project__c=projectId;
                        newPGARecord.Delete_PIGAs__c=pga.Delete_PIGAs__c;
                        if(Test.isRunningTest()){
                            newPGARecord.Unique_ID__c=projectId + ' - ' + newPGARecord.id + ' ' + Integer.valueof((Math.random() * 1000));
                        } else {
                            newPGARecord.Unique_ID__c=projectId + ' - ' + newPGARecord.id;
                        }
                        newPGAs.add(newPGARecord);
                    }

                    if (newPGAs.size() > 0) {
                        System.debug('11. PGAs newPGAs: '+ newPGAs.size());
                        INSERT newPGAs;
                    }
        RETURN newPGAs;
    }
    
   	public static List<ampi__Objective__c> manageNewObjectives(List<ampi__Objective__c> baseObjectives, String projectId, Map<String, String> frameworkMatchIds, Boolean isRecordRenamed) {
        List<ampi__Objective__c> newObjectives = new List<ampi__Objective__c>();

                    for (ampi__Objective__c objective : baseObjectives)
                    {
                        String newFrameworkValue = '';
                        if (frameworkMatchIds != null) {
                        	if (frameworkMatchIds.containsKey(objective.ampi__xx_Framework__c)) {
                                newFrameworkValue = frameworkMatchIds.get(objective.ampi__xx_Framework__c);
                            }
                        }
                        
                        ampi__Objective__c newObjectiveRecord = new ampi__Objective__c();
                        newObjectiveRecord.ampi__Description__c=objective.ampi__Description__c;
                        newObjectiveRecord.ampi__Label__c=objective.ampi__Label__c;
                        newObjectiveRecord.ampi__Level__c=objective.ampi__Level__c;
                        newObjectiveRecord.ampi__Objective__c=objective.ampi__Objective__c;
                        newObjectiveRecord.ampi__Project__c=projectId;
                        newObjectiveRecord.Order_Number__c=objective.Order_Number__c;
                        if (isRecordRenamed)
                            newObjectiveRecord.NOT_RENAME__C = true;
                        newObjectiveRecord.RecordTypeId=objective.RecordTypeId;
                        if (newFrameworkValue != '') {
                            newObjectiveRecord.ampi__xx_Framework__c=newFrameworkValue; //TODO: this will be from new frameworks
                        }
                        newObjectives.add(newObjectiveRecord);
					}
        
        if (newObjectives.size() > 0) {
            INSERT newObjectives;
        }
        RETURN newObjectives;
    }
    
    /*public static List<ampi__Implementation_Plan__c> manageNewActivitySchedule(List<ampi__Implementation_Plan__c> baseActivitySchedule, String projectId) {
                    List<ampi__Implementation_Plan__c> newActivitySchedules = new List<ampi__Implementation_Plan__c>();
                    
                    for (ampi__Implementation_Plan__c sched : baseActivitySchedule) {
                        ampi__Implementation_Plan__c newActivitySchedule = new ampi__Implementation_Plan__c();
                        newActivitySchedule.Name = sched.Name;
                        newActivitySchedule.ampi__Project__c = projectId;
                        newActivitySchedule.ampi__Active__c = sched.ampi__Active__c;
                        newActivitySchedules.add(newActivitySchedule);
                    } 
                    
                    if (newActivitySchedules.size() > 0) {
                        INSERT newActivitySchedules;
                    }
            RETURN newActivitySchedules;
    }*/

    public static List<ampi__Implementation_Plan__c> createNewActivitySchedule(String name, String projectId) {
            List<ampi__Implementation_Plan__c> newActivitySchedules = new List<ampi__Implementation_Plan__c>();
            ampi__Implementation_Plan__c newActivitySchedule = new ampi__Implementation_Plan__c();
            newActivitySchedule.Name = name;
            newActivitySchedule.ampi__Project__c = projectId;
            newActivitySchedule.ampi__Active__c = true;
            newActivitySchedules.add(newActivitySchedule);
                    
            if (newActivitySchedules.size() > 0) {
                INSERT newActivitySchedules;
            }
            RETURN newActivitySchedules;
    }

    public static void manageNewActivitiesFromMetadata(List<Construction_Activity_Project__mdt> activities, String projectId, String implementationPlanId) {
            Map<String, String> activityMatchIds = new Map<String, String>();
            List<ampi__Activity__c> newActivities = new List<ampi__Activity__c>();
            System.debug('####activities:' + activities);
            for (Construction_Activity_Project__mdt acti : activities) {
                            System.debug('####acti:' + acti);
                            ampi__Activity__c newActivity = new ampi__Activity__c();
                            newActivity.ampi__Implementation_Plan__c=implementationPlanId;
                            newActivity.Project__c=projectId;
                            newActivity.Name=acti.Name__c;
                            newActivity.ampi__Type__c=acti.Type__c;
                            newActivity.ampi__xx_Activity_Type__c=acti.ActivityType__c;

                            if (acti.Description__c != NULL && acti.Description__c <> 'none') {
                                newActivity.ampi__Description__c=acti.Description__c;
                            }

                            if (acti.StartDate__c != NULL && acti.StartDate__c.year() > 1900) {
                                newActivity.ampi__Actual_Start_Date__c=acti.StartDate__c;
                            }
                            if (acti.EndDate__c != NULL && acti.EndDate__c.year() > 1900) {
                                newActivity.ampi__Actual_End_Date__c=acti.EndDate__c;
                            }
                            if (acti.DueDate__c != NULL && acti.DueDate__c.year() > 1900) {
                                newActivity.ampi__xx_Due_Date__c=acti.DueDate__c;
                            }

                            newActivity.ampi__Status__c=(acti.Status__c == NULL || acti.Status__c == 'none' ? '' : acti.Status__c);
                            newActivity.Activity_ID__c = acti.ActivityID__c;
                            newActivity.Person_Responsible__c = (acti.PersonResponsible__c == NULL || acti.PersonResponsible__c == 'none' ? '' : acti.PersonResponsible__c);
                            newActivity.Persons_Involved__c = (acti.PersonsInvolved__c == NULL || acti.PersonsInvolved__c == 'none' ? '' : acti.PersonsInvolved__c);
                            
                            if (acti.ExpenditureDate__c != NULL && acti.ExpenditureDate__c > 0) {
                                newActivity.Expenditure_to_date__c=acti.ExpenditureDate__c;
                            }
                            //newActivity.Budget__c=acti.Budget__c;
                            //newActivity.Activity_ID__c=acti.Activity_ID__c;
                            //newActivity.ampi__xx_Due_Date__c=acti.ampi__xx_Due_Date__c;
                            // if (acti.ampi__Project_Objective__c != null && objectiveMatchIds.containsKey((String)acti.ampi__Project_Objective__c)) {
                            //     newActivity.ampi__Project_Objective__c = objectiveMatchIds.get((String)acti.ampi__Project_Objective__c);
                            // }
                            //newActivity.Person_Responsible__c=acti.Person_Responsible__c;
                            //newActivity.Persons_Involved__c=acti.Persons_Involved__c;
                            //newActivity.ampi__Percent_Complete__c =acti.ampi__Percent_Complete__c ;
                            newActivities.add(newActivity);
                        }
                        
                        if (newActivities.size() > 0) {
                            INSERT newActivities;
                            CreateObjects.updateParentActivityRecordsByMetadata(activities, newActivities);
                        }
    }

    /*public static void manageNewActivities(List<ampi__Activity__c> activities, String projectId, String implementationPlanId, Map<String, String> objectiveMatchIds) {
            Map<String, String> activityMatchIds = new Map<String, String>();
            List<ampi__Activity__c> newActivities = new List<ampi__Activity__c>();
            for (ampi__Activity__c acti : activities) {
                            ampi__Activity__c newActivity = new ampi__Activity__c();
                            newActivity.ampi__Implementation_Plan__c=implementationPlanId;
                            newActivity.Project__c=projectId;
                            newActivity.Expenditure_to_date__c=acti.Expenditure_to_date__c;
                            newActivity.Budget__c=acti.Budget__c;
                            newActivity.Activity_ID__c=acti.Activity_ID__c;
                            newActivity.Name=acti.Name;
                            newActivity.ampi__Type__c=acti.ampi__Type__c;
                            newActivity.ampi__xx_Activity_Type__c=acti.ampi__xx_Activity_Type__c;
                            newActivity.ampi__Description__c=acti.ampi__Description__c;
                            newActivity.ampi__xx_Due_Date__c=acti.ampi__xx_Due_Date__c;
                            newActivity.ampi__Actual_End_Date__c=acti.ampi__Actual_End_Date__c;
                            newActivity.ampi__Status__c=acti.ampi__Status__c;
                            newActivity.ampi__Actual_Start_Date__c=acti.ampi__Actual_Start_Date__c;
                            if (acti.ampi__Project_Objective__c != null && objectiveMatchIds.containsKey((String)acti.ampi__Project_Objective__c)) {
                                newActivity.ampi__Project_Objective__c = objectiveMatchIds.get((String)acti.ampi__Project_Objective__c);
                            }
                            newActivity.Person_Responsible__c=acti.Person_Responsible__c;
                            newActivity.Persons_Involved__c=acti.Persons_Involved__c;
                            newActivity.ampi__Percent_Complete__c =acti.ampi__Percent_Complete__c ;
                            newActivities.add(newActivity);
                        }

                        if (newActivities.size() > 0) {
                            INSERT newActivities;
                            activityMatchIds = GetObjects.getDictionaryFromOldAndNewRecords(activities, newActivities, 'Name', false, '');                        
                            CreateObjects.updateParentActivityRecords(activities, newActivities, activityMatchIds);
                        }
    }*/

    public static List<ampi__Project_Indicator__c> manageNewProjectIndicators(List<ampi__Project_Indicator__c> projectIndicators, String projectId, String typeOfResults, Boolean setDefaultValues) {
        List<ampi__Project_Indicator__c> newProjectIndicators = new List<ampi__Project_Indicator__c>();
                    
                    for (ampi__Project_Indicator__c projectIndicator : projectIndicators)
                    {
                        System.debug('8. Project Indicator ampi__Project_Indicator__c: '+ projectIndicator.ampi__Description__c);
                        ampi__Project_Indicator__c newProjectIndicatorRecord = new ampi__Project_Indicator__c();

                        newProjectIndicatorRecord.ampi__Active__c=projectIndicator.ampi__Active__c;
                        newProjectIndicatorRecord.ampi__Calculate_Total__c=projectIndicator.ampi__Calculate_Total__c;
                        newProjectIndicatorRecord.ampi__Catalog_Indicator__c=projectIndicator.ampi__Catalog_Indicator__c;
                        newProjectIndicatorRecord.ampi__Cross_Disaggregation_by_Sex__c=projectIndicator.ampi__Cross_Disaggregation_by_Sex__c;
                        newProjectIndicatorRecord.ampi__Cumulative__c=projectIndicator.ampi__Cumulative__c;
                        newProjectIndicatorRecord.ampi__Data_Source__c=projectIndicator.ampi__Data_Source__c;
                        newProjectIndicatorRecord.ampi__Cross_Disaggregation_by_Sex__c=projectIndicator.ampi__Cross_Disaggregation_by_Sex__c;
                        newProjectIndicatorRecord.ampi__Baseline__c=projectIndicator.ampi__Baseline__c;
						newProjectIndicatorRecord.Baseline_Qualitative__c=projectIndicator.Baseline_Qualitative__c;
                        newProjectIndicatorRecord.ampi__Target_LOP__c=projectIndicator.ampi__Target_LOP__c;
						newProjectIndicatorRecord.Target_Qualitative_LOP__c=projectIndicator.Target_Qualitative_LOP__c;

                        newProjectIndicatorRecord.ampi__Target_Frequency__c=projectIndicator.ampi__Target_Frequency__c;
                        newProjectIndicatorRecord.ampi__Reporting_Frequency__c=projectIndicator.ampi__Reporting_Frequency__c;
                        newProjectIndicatorRecord.ampi__Description__c=projectIndicator.ampi__Description__c;
                        newProjectIndicatorRecord.ampi__Disaggregation_Group__c=projectIndicator.ampi__Disaggregation_Group__c;
                        newProjectIndicatorRecord.ampi__Exclude_From_IATI__c=projectIndicator.ampi__Exclude_From_IATI__c;
                        newProjectIndicatorRecord.ampi__Geographic_Area_Text__c=projectIndicator.ampi__Geographic_Area_Text__c;
                        newProjectIndicatorRecord.ampi__Geographical_Disaggregation__c=projectIndicator.ampi__Geographical_Disaggregation__c;
                        newProjectIndicatorRecord.ampi__Number_of_Decimals_Places_Allowed__c=projectIndicator.ampi__Number_of_Decimals_Places_Allowed__c;
                        newProjectIndicatorRecord.ampi__Project__c=projectId;
                        newProjectIndicatorRecord.ampi__Red_Yellow_Threshold__c=projectIndicator.ampi__Red_Yellow_Threshold__c;
                        newProjectIndicatorRecord.ampi__Reporting_Frequency__c=projectIndicator.ampi__Reporting_Frequency__c;
                        newProjectIndicatorRecord.ampi__Reporting_Period_Text__c=projectIndicator.ampi__Reporting_Period_Text__c;
                        newProjectIndicatorRecord.ampi__Result_To_Date__c=projectIndicator.ampi__Result_To_Date__c;
                        newProjectIndicatorRecord.ampi__Target_Frequency__c=projectIndicator.ampi__Target_Frequency__c;
                        newProjectIndicatorRecord.ampi__Target_To_Date__c=projectIndicator.ampi__Target_To_Date__c;
                        newProjectIndicatorRecord.ampi__Targets_Are_Disaggregated__c=projectIndicator.ampi__Targets_Are_Disaggregated__c;
                        
                        if (typeOfResults == '') {
                            newProjectIndicatorRecord.ampi__Type_of_Results__c=projectIndicator.ampi__Type_of_Results__c;
                        } else {
                            newProjectIndicatorRecord.ampi__Type_of_Results__c=typeOfResults;                        
                        }
                        newProjectIndicatorRecord.ampi__Yellow_Green_Threshold__c=projectIndicator.ampi__Yellow_Green_Threshold__c;
                        newProjectIndicatorRecord.OwnerId=projectIndicator.OwnerId;
                        if (setDefaultValues) {
                            newProjectIndicatorRecord.Responsible_Person__c=projectIndicator.ampi__Type_of_Results__c;
                            newProjectIndicatorRecord.Source_of_Verification__c=projectIndicator.Source_of_Verification__c;
                            newProjectIndicatorRecord.Timing__c=projectIndicator.Timing__c;
                        } else {
                            newProjectIndicatorRecord.Responsible_Person__c='IPD';						
                            newProjectIndicatorRecord.Source_of_Verification__c='To be defined';
                        }
                        
                        //newProjectIndicatorRecord.Responsible_Person__c=projectIndicator.Responsible_Person__c;
						//newProjectIndicatorRecord.Source_of_Verification__c=projectIndicator.Source_of_Verification__c;
                        
                        newProjectIndicators.add(newProjectIndicatorRecord);
                    }
        if(newProjectIndicators.size() > 0) {
            INSERT newProjectIndicators;
        }
        
        return newProjectIndicators;
	}

    public static void updateParentObjectiveRecords(List<ampi__Objective__c> objectives, List<ampi__Objective__c> newObjectives, Map<String, String> objectiveMatchIds, Map<String, String> objectiveFrameworkIds) {
    		String parent_id = '';
                        Integer changes = 0;
                        for (ampi__Objective__c oldObjective : objectives)
                        {
                            parent_id = '';
                            if (String.isNotEmpty(oldObjective.ampi__Parent_Project_Objective__c)) 
                            {
                                if (objectiveMatchIds.containsKey(oldObjective.ampi__Parent_Project_Objective__c)) 
                                {
                                    parent_id = objectiveMatchIds.get(oldObjective.ampi__Parent_Project_Objective__c);
                                    System.debug('#### 6. parent id: ' + parent_id + ' / description ' + oldObjective.ampi__Description__c);
                                }                               
                                
                                if (parent_id != '')  
                                {
                                    for (ampi__Objective__c newObjective : newObjectives)
                                    {
										if (objectiveFrameworkIds.containsKey(newObjective.Id) && objectiveFrameworkIds.get(newObjective.Id) == newObjective.ampi__xx_Framework__c) 
										{
											if (objectiveMatchIds.containsKey(oldObjective.Id) && objectiveMatchIds.get(oldObjective.Id) == newObjective.Id) 
											{
												newObjective.ampi__Parent_Project_Objective__c = parent_id;
												newObjective.ampi__Label__c = oldObjective.ampi__Label__c;
												newObjective.Not_Rename__c = true;
												System.debug('#### 6a. value updated: ' + oldObjective.ampi__Label__c);
												changes++;
											}
										}
                                    }
                                }       
                            }                                                                                   
                        }

                        //UPDATING PARENT(ampi__Parent_Project_Objective__c) 
                        if (changes > 0) 
                        {
                            System.debug('#### 7. changes applied: ' + changes + ' / ' + newObjectives);
                            UPDATE newObjectives;
                        }    
        
    }

    /*public static void  updateParentObjectiveRecordsWithNoFramework(List<ampi__Objective__c> objectives, List<ampi__Objective__c> newObjectives, Map<String, String> objectiveMatchIds) {
    		for (ampi__Objective__c oldObjective : objectives)
            {
                if (oldObjective.ampi__Parent_Project_Objective__c != NULL) 
                {
                    for (ampi__Objective__c newObjective : newObjectives)
                    {                            
						    if (objectiveMatchIds.containsKey(oldObjective.Id) && objectiveMatchIds.get(oldObjective.Id) == newObjective.Id) 
							{
                                    newObjective.ampi__Parent_Project_Objective__c = objectiveMatchIds.get(oldObjective.ampi__Parent_Project_Objective__c);
									System.debug('#### 7. changes applied newObjective.ampi__Parent_Project_Objective__c: ');
							}
                    }
                }       
            }    
            system.debug('#### UPDATE newObjectives 1');
            UPDATE newObjectives;
            system.debug('#### UPDATE newObjectives 2');
    }*/
    
    public static void lockFrameworks(List<ampi__xx_Framework__c> newFrameworks) {
        for (ampi__xx_Framework__c newFrameworkRecord : newFrameworks) 
        {
        	newFrameworkRecord.ampi__xx_Framework_Locked__c = true;
        }
    	UPDATE newFrameworks;
	}
    
    /*public static void updateProject(ampi__project__c updateBaseProject, ampi__project__c baseProject) {
        if (updateBaseProject != null) {
                        updateBaseProject.Contract_Eligibility_Start_Date__c = baseProject.Contract_Eligibility_Start_Date__c;
                        updateBaseProject.Contract_Eligibility_End_Date__c = baseProject.Contract_Eligibility_End_Date__c;
                        updateBaseProject.ampi__Start_Date__c = baseProject.ampi__Start_Date__c;
                        updateBaseProject.ampi__End_Date__c = baseProject.ampi__End_Date__c;
                        UPDATE updateBaseProject; 
                    }
    }*/
    
}