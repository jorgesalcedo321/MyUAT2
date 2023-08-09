public without sharing class crossTable {

    @AuraEnabled(cacheable=true)
    public static String getLanguageLocateFromCurrentUser() {
	    List<User> users = [SELECT LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()];
		//System.debug('###users:' + users);
        if (users.size() > 0) 
            return users[0].LocaleSidKey;
        
        return '';
    }
    @AuraEnabled(cacheable=true)
    public static ampi__geographical_area__c getDataFromProgrammeById(String puId) {
		List<ampi__geographical_area__c> gas = [SELECT Id, Program_Type__c FROM ampi__geographical_area__c WHERE Id =: puId];
		
        if (gas.size() > 0) {
            return gas[0];
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static ampi__project__c getDataFromProjectByPU(String puId) {
		List<ampi__project__c> projects = [SELECT Id, RecordType.Name  FROM ampi__project__c WHERE P_PU__c =: puId AND RecordType.Name = 'Shadow Project'];
		
        if (projects.size() > 0) {
            return projects[0];
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static ampi__project__c getDataFromProject(String projectId) {
		List<ampi__project__c> projects = [SELECt Id, Project_ID_Text__c, programme_location__c, programme_location__r.Name, RecordType.Name FROM ampi__project__c WHERE id =: projectId];
		
        if (projects.size() > 0) {
            return projects[0];
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getSourceDocumentFromIndicator(String projectId, String geographicAreaId) {
		List<String> pickListValuesList= new List<String>();
		Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('ampi__indicator__c');
		Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
		Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get('Source_Document__c').getDescribe().getPickListValues();

		for (Schema.PicklistEntry objPickList : lstPickListValues) {
            Boolean exists = resultsByProjectAndGeographicAreaIdAndSourceExists(projectId, geographicAreaId, objPickList.getLabel());
            if (exists) {
			    pickListValuesList.add(objPickList.getLabel());
            }
		}
        return pickListValuesList;
    }

    @AuraEnabled(cacheable=true)
    public static List<ampi__Reporting_Period__c> getMonitoringPeriodsByProjectId(String projectId) {
        List<ampi__Reporting_Period__c> soqlData = [SELECT ampi__Label__c, ampi__Report_Type__c, Id, ampi__Reporting_Period_Start_Date__c, ampi__Target_Status__c, ampi__Targets_Locked__c FROM ampi__Reporting_Period__c 
                WHERE ampi__Project__c =: projectId AND ampi__xx_Active__c = true AND IsDeleted = false
                ORDER BY ampi__Label__c ASC];       
                //AND ampi__Report_Type__c = 'Monthly'  
        return soqlData;
    }

    @AuraEnabled(cacheable=true)
    public static List<ampi__Project_Geographic_Area__c> getGeographicAreasByProjectId(String projectId) {
        List<ampi__Project_Geographic_Area__c> soqlData = [SELECT Id, ampi__Geographic_Area__c, ampi__Geographic_Area__r.Id, ampi__Geographic_Area__r.Name, ampi__Geographic_Area__r.ampi__Type__c FROM ampi__Project_Geographic_Area__c
                    WHERE ampi__Active__c = true AND IsDeleted = false AND ampi__Project__c =: projectId ORDER BY ampi__Geographic_Area__r.Name ASC];       
                //AND ampi__Report_Type__c = 'Monthly'  
        return soqlData;
    }
    

    @AuraEnabled(cacheable=true)
    public static List<ampi__Project_Thematic_Area__c> getServiceTypesByProjectId(String projectId) {
        List<ampi__Project_Thematic_Area__c> soqlData = [SELECT ampi__Thematic_Area__r.Abbreviation__c, ampi__Thematic_Area__r.Name, ampi__Thematic_Area__r.Id, Id FROM ampi__Project_Thematic_Area__c 
                WHERE ampi__Project__c =: projectId AND IsDeleted = false
                ORDER BY Name ASC];        
        return soqlData;
    }

    @AuraEnabled(cacheable=true)
    public static List<ampi__Project_Indicator__c> getIndicatorsByProjectId(String projectId) {
        List<ampi__Project_Indicator__c> filtered = new List<ampi__Project_Indicator__c>();
        List<ampi__Project_Indicator__c> soqlData = [SELECT ampi__Geographical_Disaggregation__c, ampi__Target_Frequency__c, ampi__Description__c, ampi__Description_Translated__c, ampi__Geographic_Area_Text__c, ampi__Catalog_Indicator__r.ampi__Description__c, ampi__Catalog_Indicator__r.Id, Id, 
                ampi__Catalog_Indicator__r.Level__c, ampi__Catalog_Indicator__r.Source_Document__c, ampi__Catalog_Indicator__r.ampi__Thematic_Area_Ids__c, ampi__Catalog_Indicator__r.ampi__Description_Translated__c FROM ampi__Project_Indicator__c 
                WHERE ampi__Project__c =: projectId AND ampi__Active__c = true AND IsDeleted = false
                ORDER BY ampi__Description_Translated__c ASC];        
        //ampi__Geographical_Disaggregation__c = 'Programme' 
        //  AND ampi__Target_Frequency__c = 'Monthly'                
        //ampi__Catalog_Indicator__r.ampi__Thematic_Area_Text__c ASC, 
        // if (geographicName == '') {
        return soqlData;
        // }

        // for(ampi__Project_Indicator__c pi : soqlData) {
        //     if (pi.ampi__Geographic_Area_Text__c.contains(geographicName)) {
        //         filtered.add(pi);
        //     }
        // }   
        // return filtered;
    }

    @AuraEnabled(cacheable=true)
    public static List<ampi__Disaggregated_Project_Indicator__c> getDisaggregatedGroupByProjectId(String projectId) {
        List<ampi__Disaggregated_Project_Indicator__c> soqlData = [SELECT ampi__Disaggregation_Group__c, ampi__Disaggregation_Group__r.Name, ampi__Project_Indicator__c FROM ampi__Disaggregated_Project_Indicator__c where ampi__Project_Indicator__r.ampi__project__c =: projectId ORDER BY ampi__Disaggregation_Group__r.Name ASC];        
        return soqlData;        
    }

    @AuraEnabled(cacheable=true)
    public static List<ampi__Disaggregation_Value__c> getDisaggregatedValuesByDisaggregatedGroups(List<Id> disaggregatedGroups) {
        return [SELECT Id, Name, ampi__Disaggregation_Group__c FROM ampi__Disaggregation_Value__c WHERE ampi__Disaggregation_Group__c IN : disaggregatedGroups ORDER BY ampi__Disaggregation_Group__r.Name DESC, Name DESC];
    }
    @AuraEnabled(cacheable=true)
    public static String getProjectGeographicAreaIdByProjectAndGeographicAreaId(String projectId, String geographicAreaId) {
        List<ampi__Project_Geographic_Area__c> soqlData = [SELECT Id FROM ampi__Project_Geographic_Area__c 
                WHERE ampi__Project__c =: projectId
                AND ampi__Geographic_Area__c =: geographicAreaId 
                AND ampi__Active__c = true AND IsDeleted = false];      

        if (soqlData.size() > 0) {
            return soqlData[0].Id;
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<ampi__project_indicator_reporting_period__c> getPIRPByProjectId(String projectId) {
        List<ampi__project_indicator_reporting_period__c> soqlData = [SELECT Id, ampi__Data_tracked__c, ampi__Parent_Report_Type__c, ampi__Parent_Label__c, ampi__Project_Indicator__c, ampi__Reporting_Period__c, ampi__Reporting_Period__r.ampi__Reporting_Period_End_Date__c, ampi__Reporting_Period__r.ampi__Target_Status__c 
                FROM ampi__project_indicator_reporting_period__c 
                WHERE ampi__Project_Indicator__r.ampi__Project__c =: projectId AND IsDeleted = false];      

        return soqlData;
    }

    @AuraEnabled(cacheable=true)
    public static List<ampi__project_indicator_geographic_area__c> getPIGAByProjectId(String projectId) {
        List<ampi__project_indicator_geographic_area__c> soqlData = [SELECT Id, ampi__Project_Indicator__c, ampi__Geographic_Area__c, ampi__project_indicator__r.ampi__Catalog_Indicator__c, ampi__Geographic_Area__r.Name 
                FROM ampi__project_indicator_geographic_area__c 
                WHERE ampi__Project_Indicator__r.ampi__Project__c =: projectId AND IsDeleted = false];      

        return soqlData;
    }

    @AuraEnabled(cacheable=false)
    public static List<ampi__result__c> getResultsByProjectAndGeographicAreaId(String projectId, String geographicAreaId) {
        if (geographicAreaId == 'All') {
            return [SELECT Id, 
                                                 ampi__Target_Value__c, 
                                                 ampi__Data_Tracked__c, 
                                                 ampi__Project_Indicator_Reporting_Period__c,
                                                 ampi__Project_Indicator_Geographic_Area__c,
                                                 ampi__Project_Indicator__r.ampi__Disaggregation_Group__c,
                                                 ampi__Project_Indicator__r.ampi__Targets_Are_Disaggregated__c,
                                                 ampi__Project_Indicator_Reporting_Period__r.ampi__Reporting_Period__c,
                                                 ampi__Project_Indicator_Geographic_Area__r.ampi__Geographic_Area__c,
                                                 ampi__Project_Indicator_Reporting_Period__r.ampi__Reporting_Period__r.ampi__label__c, 
                                                 ampi__Project_Indicator__r.ampi__Catalog_Indicator__r.ampi__Description__c,
                                                 ampi__Project_Indicator__r.ampi__Catalog_Indicator__r.Source_Document__c,
                                                 ampi__Project_Indicator__r.ampi__Project__r.ampi__Thematic_Area_Text__c,
                                                 ampi__Project_Indicator_Reporting_Period__r.ampi__Reporting_Period__r.ampi__Target_Status__c
                FROM ampi__result__c
                WHERE
                ampi__Data_Tracked__c IN ('Both', 'Target') AND
                ampi__Project_Indicator_Geographic_Area__r.ampi__Project_Indicator__r.ampi__Project__c =: projectId AND
                ampi__Project_Indicator_Reporting_Period__r.ampi__Project_Indicator__r.ampi__Project__c =: projectId AND 
                ampi__Project_Indicator__r.ampi__Project__c =: projectId AND 
                IsDeleted = false
                ORDER BY Name ASC];
        } else {
            return [SELECT Id, 
                                                 ampi__Target_Value__c, 
                                                 ampi__Data_Tracked__c, 
                                                 ampi__Project_Indicator_Reporting_Period__c,
                                                 ampi__Project_Indicator_Geographic_Area__c,
                                                 ampi__Project_Indicator__r.ampi__Disaggregation_Group__c,
                                                 ampi__Project_Indicator__r.ampi__Targets_Are_Disaggregated__c,
                                                 ampi__Project_Indicator_Reporting_Period__r.ampi__Reporting_Period__c,
                                                 ampi__Project_Indicator_Geographic_Area__r.ampi__Geographic_Area__c,
                                                 ampi__Project_Indicator_Reporting_Period__r.ampi__Reporting_Period__r.ampi__label__c, 
                                                 ampi__Project_Indicator__r.ampi__Catalog_Indicator__r.ampi__Description__c,
                                                 ampi__Project_Indicator__r.ampi__Catalog_Indicator__r.Source_Document__c,
                                                 ampi__Project_Indicator__r.ampi__Project__r.ampi__Thematic_Area_Text__c,
                                                 ampi__Project_Indicator_Reporting_Period__r.ampi__Reporting_Period__r.ampi__Target_Status__c 
                FROM ampi__result__c
                WHERE
                ampi__Data_Tracked__c IN ('Both', 'Target') AND
                ampi__Project_Indicator_Geographic_Area__r.ampi__Geographic_Area__c =: geographicAreaId AND
                ampi__Project_Indicator_Geographic_Area__r.ampi__Project_Indicator__r.ampi__Project__c =: projectId AND
                ampi__Project_Indicator_Reporting_Period__r.ampi__Project_Indicator__r.ampi__Project__c =: projectId AND 
                ampi__Project_Indicator__r.ampi__Project__c =: projectId AND 
                IsDeleted = false
                ORDER BY Name ASC];
        }
    }   

    public static Boolean resultsByProjectAndGeographicAreaIdAndSourceExists(String projectId, String geographicAreaId, String source) {
        List<ampi__result__c> soqlData = [SELECT Id 
                FROM ampi__result__c
                WHERE
                ampi__Data_Tracked__c IN ('Both', 'Target') AND
                ampi__Project_Indicator_Geographic_Area__r.ampi__Geographic_Area__c =: geographicAreaId AND
                ampi__Project_Indicator_Geographic_Area__r.ampi__Project_Indicator__r.ampi__Project__c =: projectId AND
                ampi__Project_Indicator_Reporting_Period__r.ampi__Project_Indicator__r.ampi__Project__c =: projectId AND 
                ampi__Project_Indicator__r.ampi__Project__c =: projectId AND 
                ampi__Project_Indicator__r.ampi__Catalog_Indicator__r.Source_Document__c =: source AND
                IsDeleted = false
                ORDER BY Name ASC];
                // ampi__Project_Indicator_Reporting_Period__r.ampi__Reporting_Period__r.ampi__Target_Status__c

        return (soqlData.size() > 0);
    }   

    @AuraEnabled
    public static String getDisaggregatedValueFromDisaggregatedGroup(List<ampi__Disaggregation_Value__c> disaggregatedValuesFromDisaggregatedGroups, String disaggregation_Group) {
        for (ampi__Disaggregation_Value__c dv : disaggregatedValuesFromDisaggregatedGroups) {
            if (dv.ampi__Disaggregation_Group__c == disaggregation_Group) {
                return dv.Id;
            }
        }
        return '';
    }

    @AuraEnabled
    public static String saveResultChangesInBulk(List<ampi__result__c> results, String projectId) {
        System.debug('#### enter saveResultChangesInBulk 1');
        System.debug('#### enter saveResultChangesInBulk 2:' + results);
        List<ampi__result__c> newResults = new List<ampi__result__c>();
        List<Changes> changes = new List<Changes>();

        List<Id> resultsToUpdate = new List<Id>();
        for(ampi__result__c result : results) {
            if ((result.Id == null || (result.Id + '') == '') && 
                (result.ampi__Project_Indicator_Reporting_Period__c != null && (result.ampi__Project_Indicator_Reporting_Period__c + '') != '') && 
                (result.ampi__Project_Indicator_Geographic_Area__c != null && (result.ampi__Project_Indicator_Geographic_Area__c + '') != '')) {
                newResults.add(new ampi__result__c(ampi__Target_Value__c = result.ampi__Target_Value__c, 
                                                   ampi__Results_Current_As_Of__c = result.ampi__Results_Current_As_Of__c,
                                                   ampi__Target_Created_Date__c = Datetime.now(),
                                                   ampi__Target_Last_Modified_Date__c = Datetime.now(),
                                                   ampi__Project_Indicator_Reporting_Period__c = result.ampi__Project_Indicator_Reporting_Period__c,
                                                   ampi__Project_Indicator_Geographic_Area__c = result.ampi__Project_Indicator_Geographic_Area__c,
                                                   ampi__Project_Indicator__c =  result.ampi__Project_Indicator__c,
                                                   ampi__Data_Tracked__c = result.ampi__Data_Tracked__c));
            } else if (result.Id != null || (result.Id + '') != '') {
                Integer index = (result.Id + '').lastIndexOf('-');
                String newId = (index > 0 ? (result.Id + '').substring(0, index) : result.Id);
                System.debug('#### enter saveResultChangesInBulk 2a newId:' + newId);
                resultsToUpdate.add(newId);    
                changes.add(new Changes(newId, result.ampi__Target_Value__c));
            }
        }

        try {
            if (newResults.size() > 0) {
                System.debug('#### enter saveResultChangesInBulk newResults 3:' + newResults);
                INSERT newResults;
            }
        } catch(DmlException e) {
            System.debug('#### enter saveResultChangesInBulk newResults 4 error:' + 'The following exception has occurred: ' + e.getMessage());
            return 'The following exception has occurred: ' + e.getMessage();
        }

        if (resultsToUpdate.size() > 0) {
            List<ampi__result__c> updateResults = [SELECT Id, ampi__Target_Value__c, ampi__Target_Last_Modified_Date__c FROM ampi__result__c WHERE Id IN :resultsToUpdate];
            System.debug('#### enter saveResultChangesInBulk changes new 5_:' + changes);
            for(ampi__result__c updateResult : updateResults) {
                for(Changes change : changes) {
                    if (updateResult.Id == change.ID) {
                        updateResult.ampi__Target_Value__c = change.Value;
                        updateResult.ampi__Target_Last_Modified_Date__c = Datetime.now();
                    }
                }
            } 
            try {
                System.debug('#### enter saveResultChangesInBulk updateResults new 5:' + updateResults);
                UPDATE updateResults;
            } catch(DmlException e) {
                System.debug('#### enter saveResultChangesInBulk updateResults new 6 error:' + 'The following exception has occurred: ' + e.getMessage());
                return 'The following exception has occurred: ' + e.getMessage();
            }
        }

        RETURN '';
    }

    //TODO: Checking if value is dissagregated
    // @AuraEnabled
    // public static String saveResultChangesInBulk(List<ampi__result__c> results, String projectId) {
    //     System.debug('#### enter saveResultChangesInBulk 1');
    //     System.debug('#### enter saveResultChangesInBulk 2:' + results);
    //     List<ampi__result__c> newResults = new List<ampi__result__c>();
    //     List<Changes> changes = new List<Changes>();
    //     System.debug('#### enter 0 disaggregatedGroupsProjectIndicator:');
    //     List<ampi__Disaggregated_Project_Indicator__c> disaggregatedGroupsProjectIndicator = getDisaggregatedGroupByProjectId(projectId);

    //     List<Id> disaggregatedGroupIds = new List<Id>();

    //     for(ampi__Disaggregated_Project_Indicator__c dpi : disaggregatedGroupsProjectIndicator) {
    //         if (dpi.ampi__Disaggregation_Group__c <> null && !disaggregatedGroupIds.contains(dpi.ampi__Disaggregation_Group__c)) {
    //             disaggregatedGroupIds.add(dpi.ampi__Disaggregation_Group__c);
    //         }
    //     }

    //     List<ampi__Disaggregation_Value__c> disaggregatedValuesFromDisaggregatedGroups = getDisaggregatedValuesByDisaggregatedGroups(disaggregatedGroupIds);
    //     List<ampi__Project_Indicator__c> pis = getIndicatorsByProjectId(projectId);

    //     System.debug('#### enter 1 disaggregatedGroupsProjectIndicator:' + disaggregatedGroupsProjectIndicator);
    //     List<Id> resultsToUpdate = new List<Id>();

    //     for(ampi__result__c result : results) {
    //         if ((result.Id == null || (result.Id + '') == '') && 
    //             (result.ampi__Project_Indicator_Reporting_Period__c != null && (result.ampi__Project_Indicator_Reporting_Period__c + '') != '') && 
    //             (result.ampi__Project_Indicator_Geographic_Area__c != null && (result.ampi__Project_Indicator_Geographic_Area__c + '') != '')) {
                
    //             boolean Targets_Are_Disaggregated = false;
    //             for(ampi__Project_Indicator__c pi : pis) {
    //                 if (pi.Id == result.ampi__Project_Indicator__c) {
    //                     Targets_Are_Disaggregated = pi.ampi__Targets_Are_Disaggregated__c;
    //                 }
    //             }
                
    //             String disaggregation_Value = (Targets_Are_Disaggregated) ? result.ampi__Disaggregation_Value__c : null;
    //             system.debug('####result:' + result);
    //             system.debug('####result.ampi__Project_Indicator__r.ampi__Targets_Are_Disaggregated__c:' + Targets_Are_Disaggregated);

    //             if (Targets_Are_Disaggregated) {
    //                 if (result.ampi__Disaggregation_Value__c == null) {
    //                     for (ampi__Disaggregated_Project_Indicator__c dPI : disaggregatedGroupsProjectIndicator) {
    //                         system.debug('####result.ampi__Project_Indicator__c:' + result.ampi__Project_Indicator__c);
    //                         system.debug('####dPI.ampi__Disaggregation_Group__c:' + dPI.ampi__Disaggregation_Group__c);                            
    //                         if (dPI.ampi__Project_Indicator__c == result.ampi__Project_Indicator__c) {
    //                             disaggregation_Value = getDisaggregatedValueFromDisaggregatedGroup(disaggregatedValuesFromDisaggregatedGroups, dPI.ampi__Disaggregation_Group__c);
    //                         }
    //                     }
    //                 }
    //             }
    //             System.debug('####disaggregation_Value: ' + disaggregation_Value);
    //             newResults.add(new ampi__result__c(ampi__Target_Value__c = result.ampi__Target_Value__c,
    //                                                ampi__Unknown_Target__c = (result.ampi__Unknown_Target__c == null && disaggregation_Value <> null ? result.ampi__Target_Value__c : result.ampi__Unknown_Target__c), //PoC for AMIMSP-2068
    //                                                ampi__Results_Current_As_Of__c = result.ampi__Results_Current_As_Of__c,
    //                                                ampi__Target_Created_Date__c = Datetime.now(),
    //                                                ampi__Disaggregation_Value__c = disaggregation_Value, //TODO
    //                                                ampi__Target_Last_Modified_Date__c = Datetime.now(),
    //                                                ampi__Project_Indicator_Reporting_Period__c = result.ampi__Project_Indicator_Reporting_Period__c,
    //                                                ampi__Project_Indicator_Geographic_Area__c = result.ampi__Project_Indicator_Geographic_Area__c,
    //                                                ampi__Project_Indicator__c =  result.ampi__Project_Indicator__c,
    //                                                ampi__Data_Tracked__c = result.ampi__Data_Tracked__c));
    //         } else if (result.Id != null || (result.Id + '') != '') {
    //             Integer index = (result.Id + '').lastIndexOf('-');
    //             String newId = (index > 0 ? (result.Id + '').substring(0, index) : result.Id);
    //             System.debug('#### enter saveResultChangesInBulk 2a newId:' + newId);
    //             resultsToUpdate.add(newId);    
    //             changes.add(new Changes(newId, result.ampi__Target_Value__c));
    //         }
    //     }

    //     try {
    //         if (newResults.size() > 0) {
    //             System.debug('#### enter saveResultChangesInBulk newResults 3:' + newResults);
    //             INSERT newResults;
    //         }
    //     } catch(DmlException e) {
    //         System.debug('#### enter saveResultChangesInBulk newResults 4 error:' + 'The following exception has occurred: ' + e.getMessage());
    //         return 'The following exception has occurred: ' + e.getMessage();
    //     }

    //     if (resultsToUpdate.size() > 0) {
    //         List<ampi__result__c> updateResults = [SELECT Id, ampi__Project_Indicator__c, ampi__Disaggregation_Value__c, ampi__Target_Value__c, ampi__Unknown_Target__c, ampi__Target_Last_Modified_Date__c, ampi__Project_Indicator__r.ampi__Targets_Are_Disaggregated__c FROM ampi__result__c WHERE Id IN :resultsToUpdate];
    //         System.debug('#### enter saveResultChangesInBulk changes new 5_:' + changes);
    //         for(ampi__result__c updateResult : updateResults) {
    //             for(Changes change : changes) {
    //                 if (updateResult.Id == change.ID) {

    //                     boolean Targets_Are_Disaggregated = false;
    //                     for(ampi__Project_Indicator__c pi : pis) {
    //                         if (pi.Id == updateResult.ampi__Project_Indicator__c) {
    //                             Targets_Are_Disaggregated = pi.ampi__Targets_Are_Disaggregated__c;
    //                         }
    //                     }                

    //                     String disaggregation_Value = (Targets_Are_Disaggregated) ? updateResult.ampi__Disaggregation_Value__c : null;

    //                     if (Targets_Are_Disaggregated) {
    //                         if (updateResult.ampi__Disaggregation_Value__c == null) {
    //                             for (ampi__Disaggregated_Project_Indicator__c dPI : disaggregatedGroupsProjectIndicator) {
    //                                 if (dPI.ampi__Project_Indicator__c == updateResult.ampi__Project_Indicator__c) {
    //                                     disaggregation_Value = getDisaggregatedValueFromDisaggregatedGroup(disaggregatedValuesFromDisaggregatedGroups, dPI.ampi__Disaggregation_Group__c);
    //                                 }
    //                             }
    //                         }
    //                     }

    //                     System.debug('####disaggregation_Value: ' + disaggregation_Value);

    //                     updateResult.ampi__Disaggregation_Value__c = disaggregation_Value;
    //                     updateResult.ampi__Target_Value__c = change.Value;
    //                     updateResult.ampi__Unknown_Target__c = change.Value; //PoC for AMIMSP-2068
    //                     updateResult.ampi__Target_Last_Modified_Date__c = Datetime.now();

    //                     System.debug('####updateResult: ' + updateResult);
    //                 }
    //             }
    //         } 
    //         try {
    //             System.debug('#### enter saveResultChangesInBulk updateResults new 5:' + updateResults);
    //             UPDATE updateResults;
    //         } catch(DmlException e) {
    //             System.debug('#### enter saveResultChangesInBulk updateResults new 6 error:' + 'The following exception has occurred: ' + e.getMessage());
    //             return 'The following exception has occurred: ' + e.getMessage();
    //         }
    //     }

    //     RETURN '';
    // }

    public class Changes {
        @AuraEnabled
        public Id ID {get;set;}
        @AuraEnabled
        public Decimal Value {get;set;}

        public Changes(Id ID, Decimal Value) {
            this.ID = ID;
            this.Value = Value;
        }
    } 
}