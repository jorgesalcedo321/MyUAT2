public class GetObjects {
    //https://bluecanvas.io/blog/how-to-structure-and-manage-your-apex-codebase-for-scale-and-agility
    //https://welkinsuite.com/blog/creating-salesforce-project-from-git-sources/
    //https://bestirtech.com/blog/2020/09/salesforce-apex-trigger-handler/
    
    public static String getRecordTypeNameByProjectRecordTypeId(String recordTypeId) {
        Map<ID,Schema.RecordTypeInfo> rt_Map = ampi__Project__c.sObjectType.getDescribe().getRecordTypeInfosById();
        return rt_map.get(recordTypeId).getDeveloperName();                
    }
    
    public static Map<String, String> getDictionaryFromOldAndNewRecords(List<SObject> oldRecords, List<SObject> newRecords, String fieldToCompare, boolean considerNewItems, String fieldToInclude) {
        Map<String, String> dictionaryMatchIds = new Map<String, String>(); 
        for (SObject oldRecord : oldRecords)
		{
        	for (SObject newRecord : newRecords)
            {
                //system.debug('### oldRecord.get(fieldToCompare):' + oldRecord.get(fieldToCompare));
                //system.debug('### newRecord.get(fieldToCompare):' + newRecord.get(fieldToCompare));
            	if (oldRecord.get(fieldToCompare) == newRecord.get(fieldToCompare) && !dictionaryMatchIds.containsKey((String)oldRecord.get('Id'))) {
                    //system.debug('### enter here:' + considerNewItems);
                    if (considerNewItems == false) {
                    	dictionaryMatchIds.put((String)oldRecord.get('Id'), (String)newRecord.get('Id'));
                    } else {
                        dictionaryMatchIds.put((String)newRecord.get('Id'), (String)newRecord.get(fieldToInclude));
                    }
                }
            }
        }
        system.debug('### getDictionaryFromOldAndNewRecords:' + dictionaryMatchIds);
        return dictionaryMatchIds;
    }

    public static Map<String, String> getDictionaryFromOldAndNewRecordsMetadata(List<SObject> oldRecords, List<SObject> newRecords, String fieldToCompare, String fieldToCompareNew, String oldIdName, String newIdName) {
        Map<String, String> dictionaryMatchIds = new Map<String, String>(); 
        for (SObject oldRecord : oldRecords)
		{
        	for (SObject newRecord : newRecords)
            {
                //system.debug('### oldRecord.get(fieldToCompare):' + oldRecord.get(fieldToCompare));
                //system.debug('### newRecord.get(fieldToCompare):' + newRecord.get(fieldToCompare));
            	if (oldRecord.get(fieldToCompare) == newRecord.get(fieldToCompareNew) && !dictionaryMatchIds.containsKey((String)oldRecord.get(oldIdName))) {
                    dictionaryMatchIds.put((String)oldRecord.get(oldIdName), (String)newRecord.get(newIdName));                    
                }
            }
        }
        system.debug('### getDictionaryFromOldAndNewRecordsMetadata:' + dictionaryMatchIds);
        return dictionaryMatchIds;
    }

    public static List<ampi__Implementation_Plan__c> getActivitySchedulesByProject(String projectId){ 
        return [SELECT Id, ampi__Project__c, Name, ampi__Active__c
                                                                    FROM ampi__Implementation_Plan__c 
                                                                    WHERE ampi__Project__c =: projectId ];
    }

    // public static List<ampi__Activity__c> getActivitiesByProject(String implementationPlanId){ 
    //     return[SELECT Id, Expenditure_to_date__c, Budget__c, ampi__Implementation_Plan__c, Activity_ID__c, Name, ampi__Type__c, ampi__xx_Activity_Type__c, ampi__Description__c, ampi__xx_Due_Date__c, ampi__Actual_End_Date__c, ampi__Status__c, Project__c, ampi__Actual_Start_Date__c, ampi__Project_Objective__c, ampi__Parent_Activity__c, Person_Responsible__c, Persons_Involved__c, ampi__Percent_Complete__c 
    //                                                           FROM ampi__Activity__c 
    //                                                           WHERE ampi__Implementation_Plan__c =: implementationPlanId];
    // }

public static List<ampi__Project_Indicator__c> getProjectIndicatorsByProject(String projectId){ 
        return [SELECT
                            ampi__Active__c,
                            ampi__Aim_Icon__c,
                            ampi__Calculate_Total__c,
                            ampi__Catalog_Indicator__c,
                            ampi__Cross_Disaggregation_by_Sex__c,
                            ampi__Cumulative__c,
                            ampi__Data_Source__c,
							Source_of_Verification__c,
							ampi__Baseline__c,
							Baseline_Qualitative__c,
                            ampi__Target_LOP__c,
							Target_Qualitative_LOP__c,
                            ampi__Data_Type__c,
                            ampi__Data_Type_Icon__c,
                            ampi__Description__c,
                            ampi__Disaggregation_Group__c,
                            ampi__Exclude_From_IATI__c,
                            ampi__Geographic_Area_Text__c,
                            ampi__Geographical_Disaggregation__c,
                            ampi__Number_of_Decimals_Places_Allowed__c,
                            ampi__Project__c,
                            ampi__Red_Yellow_Threshold__c,
                            ampi__Reporting_Frequency__c,
                            ampi__Reporting_Period_Text__c,
                            ampi__Result_To_Date__c,
                            ampi__Target_Frequency__c,
                            ampi__Target_Frequency_Formula__c,
                            ampi__Target_To_Date__c,
                            ampi__Targets_Are_Disaggregated__c,
                            ampi__Type_of_Results__c,
                            ampi__Yellow_Green_Threshold__c,
                            Info_Complete__c,
                            Milestone__c,
                            Name,
                            OwnerId,
                            Project_Record_Type__c,
                            Responsible_Person__c,
                            Result_Statement_Link__c,
                            Timing__c
                        FROM ampi__Project_Indicator__c WHERE ampi__Project__c =: projectId AND ampi__Active__c = true];
	}
    
    public static List<ampi__Reporting_Period__c> getReportingPeriodsByProject(String projectId) {
        return [SELECT
                        ampi__Available_For_Financials__c,
                        ampi__Date_Submitted__c,
                        ampi__Exclude_From_IATI__c,
                        ampi__Label__c,
                        ampi__Link__c,
                        ampi__Project__c,
                        ampi__Project_Reporting_Period_Name__c,
                        ampi__Report_Type__c,
                        ampi__Reporting_Period_End_Date__c,
                        ampi__Reporting_Period_Length__c,
                        ampi__Reporting_Period_Start_Date__c,
                        ampi__Result_Status__c,
                        ampi__Results_Locked__c,
                        ampi__Target_Status__c,
                        ampi__Targets_Locked__c,
                        ampi__xx_Active__c,
                        Create_Risk_Review_for_Period__c,
                        Id,
                        IsDeleted,
                        Name,
                        RecordTypeId
                    FROM ampi__Reporting_Period__c WHERE ampi__Project__c =: projectId];//'a0i1w000002wa0NAAQ'
    }
    public static List<ampi__Objective__c> getObjectivesByProjectId(String projectId) {
        return [SELECT
                                                            ampi__Description__c,
                                                            ampi__Label__c,
                                                            ampi__Label_Translated__c,
                                                            ampi__Level__c,
                                                            Order_Number__c,
                                                            ampi__Objective__c,
                                                            ampi__Parent_Project_Objective__c,
                                                            ampi__Project__c,
                                                            ampi__xx_Framework__c,
															Name, 
                                                            Id,
                                                            RecordTypeId
                                                            FROM ampi__Objective__c WHERE ampi__Project__c =: projectId];
    }
    
    public static List<ampi__Project_Geographic_Area__c> getPGAsByProject(String projectId) {
        return [SELECT
                        ampi__Active__c,
                        ampi__Exclude_From_IATI__c,
                        ampi__Geographic_Area__c,
                        ampi__IATI_Region_Code__c,
                        ampi__Project__c,
                        ampi__Type__c,
                        Case_Safe_ID__c,
                        Delete_PIGAs__c,
                        Duplicate_Catcher__c,
                        Name,
                        Unique_ID__c
                    FROM ampi__Project_Geographic_Area__c
                    WHERE ampi__Project__c  =: projectId];
    }
    
    public static List<ampi__Project__c> getProjectsByName(String name) {
        return [SELECT Id, 
                                                          	Contract_Eligibility_Start_Date__c,
                                                          	Contract_Eligibility_End_Date__c,
                                                           	ampi__Start_Date__c,
                                                           	ampi__End_Date__c FROM ampi__Project__c 
                											WHERE Name =: name];
                
    }
    
    public static List<ampi__xx_Framework__c> getFrameworksByProjectId(String projectId) {
        return [Select ampi__xx_Description__c,
                                                        ampi__xx_Framework_Locked__c,
                                                        ampi__xx_Project__c,
                                                        ampi__xx_Reviewer_Comments__c,
                                                        ampi__xx_Status__c,
                                                        Id,
                                                        Name
                                                        FROM ampi__xx_Framework__c WHERE ampi__xx_Project__c = :projectId];
    }
    
    public static List<ampi__Project_Indicator_Reporting_Period__c> getProjectIndicatorMonitoringPeriodsByProjectId(String projectId) {
        return [SELECT
                            ampi__Data_Tracked__c,
                            ampi__Parent_Label__c,
                            ampi__Parent_Report_Type__c,
                            ampi__Parent_Reporting_Period_End_Date__c,
                            ampi__Parent_Reporting_Period_Start_Date__c,
                            ampi__Project_Indicator__c,
                            ampi__Reporting_Period__c,
                            Id,
                            Name,
                            OwnerId
                        FROM ampi__Project_Indicator_Reporting_Period__c WHERE ampi__Project_Indicator__c IN (SELECT
                            Id
                        FROM ampi__Project_Indicator__c WHERE ampi__Project__c =: projectId)];
    }
    
    public static List<ampi__Project_Indicator_Geographic_Area__c> getProjectIndicatorGeographicAreaByProjectId(String projectId) {
        return [SELECT
                                    ampi__Geographic_Area__c,
                                    ampi__Project_Indicator__c,
                                    Name,
                                    OwnerId
                                FROM ampi__Project_Indicator_Geographic_Area__c
                                WHERE ampi__Project_Indicator__c IN (SELECT Id
                                FROM ampi__Project_Indicator__c WHERE ampi__Project__c =: projectId)];
    }
    
    // public static List<ampi__Project_Indicator_Objective__c> getProjectIndicatorObjectivesByProjectId(String projectId) { 
    //     RETURN [SELECT ampi__xx_Framework_Objective__c, ampi__Objective__c, ampi__Project_Indicator__c 
    //                                                                                          FROM ampi__Project_Indicator_Objective__c
    //                                                                                          WHERE ampi__Project_Indicator__c IN (SELECT Id FROM ampi__Project_Indicator__c WHERE ampi__project__c =: projectId)];
	// }
    
    // public static List<Id> getResultStatementIds(List<ampi__Project_Indicator_Objective__c> projectIndicatorObjectives) {
    //     List<Id> resultStatementIds = new List<Id>();
    //     for(ampi__Project_Indicator_Objective__c projectIndicatorObjective : projectIndicatorObjectives) {
	// 		if (!resultStatementIds.contains(projectIndicatorObjective.ampi__Objective__c)) {
    //         	resultStatementIds.add(projectIndicatorObjective.ampi__Objective__c);
    //         }                        
    //     }
    //     RETURN resultStatementIds;            
    // }
    
    // public static List<ampi__Catalog_Objective__c> getCatalogObjectivesByResultStatements(List<Id> resultStatementIds) {
    //     RETURN [SELECT Name, ampi__Definition__c, ampi__Level__c 
    //                                                                       FROM ampi__Catalog_Objective__c
    //                                                                       WHERE Id IN: resultStatementIds];
	// }
    
    // public static List<ampi__Disaggregated_Project_Indicator__c> getDisaggregatedProjectIndicatorsByProject(String projectId) {
    //     RETURN [SELECT 
	// 					Id, 
	// 					ampi__Disaggregate_Results__c,
	// 					ampi__Disaggregate_Targets__c,
	// 					ampi__Project_Indicator__c,
	// 					ampi__Disaggregation_Group__c 
	// 					FROM ampi__Disaggregated_Project_Indicator__c 
	// 					WHERE ampi__Project_Indicator__c IN (SELECT Id FROM ampi__Project_Indicator__c WHERE ampi__project__c =: projectId)];
    // }	
    
    // public static List<ampi__Disaggregation_Group__c> getDisaggregatedGroupsByGroupValue(String disaggregationGroupValue) {
    //     	RETURN [SELECT 
	// 					Id, 
	// 					Name 
	// 					FROM ampi__Disaggregation_Group__c 
	// 					WHERE Id =: disaggregationGroupValue];
	// }
    
    // public static List<ampi__Disaggregation_Value__c> getDisaggregationValuesPerGroupValue(String disaggregationGroupValue) {
    //     RETURN [SELECT Name, ampi__Order__c FROM ampi__Disaggregation_Value__c 
    //                                                                            WHERE ampi__Disaggregation_Group__c =: disaggregationGroupValue];
    // }
    
    public static ampi__Project__c getProjectById(String projectId){ 
        List<ampi__Project__c> projects = [SELECT Id, 
                                                          	Contract_Eligibility_Start_Date__c,
                                                          	Contract_Eligibility_End_Date__c,
                                                           	ampi__Start_Date__c,
                                                           	ampi__End_Date__c FROM ampi__Project__c WHERE Id =: projectId];
        if (projects.size() > 0) {
            RETURN projects[0];
        }
        RETURN NULL;
    }
}