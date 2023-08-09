public class ProjectGeographicAreaTriggerHandler {
     public void manageAfterUpdatePGAs(List<ampi__project_geographic_area__c> newPGAs, Map<Id, ampi__Project_Geographic_Area__c> oldProjectGeographicAreas) {
        deletePIGAs(newPGAs, oldProjectGeographicAreas);
     }
    
     public void manageAfterInsertPGAs(List<ampi__project_geographic_area__c> newPGAs) {
        Set<Id> projIds = new Set<Id>();
        for(ampi__project_geographic_area__c pga : newPGAs) {
            if (pga.ampi__Project__c <> null && !projIds.contains(pga.ampi__Project__c)) {
                projIds.add(pga.ampi__Project__c);
            }
        }
         
         List<ampi__project_thematic_area__c> currentPSTs = [SELECT Id, ampi__Thematic_Area__c, Programme_Unit__c, ampi__Project__c FROM ampi__project_thematic_area__c WHERE ampi__Project__c IN :projIds];
        
        for(ampi__project_geographic_area__c newPGA : newPGAs){
            afterInsertStandardAndTransition(newPGA);
            afterInsertProjectServiceType(newPGA, currentPSTs);
        }
     }
    
     public void manageBeforeInsertPGAs(List<ampi__project_geographic_area__c> newPGAs) {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Manage_Restrictions');

        if (hasCustomPermission)
            return;
         
        for(ampi__project_geographic_area__c newPGA : newPGAs){
            beforeInsertProjectServiceTypeValidation(newPGA);
        }
     }
    
     private void beforeInsertProjectServiceTypeValidation(ampi__project_geographic_area__c newPGA) {        
            List<ampi__project_geographic_area__c> checkDuplicates = [SELECT Id, ampi__Active__c FROM ampi__project_geographic_area__c WHERE ampi__Geographic_Area__c =: newPGA.ampi__geographic_area__c AND ampi__project__c =: newPGA.ampi__project__c];

            if (checkDuplicates.size() > 0) {
                Boolean foundInactiveDuplicates = false;
                String errorMessage = 'Project Geographic Area relation is already added and it\'s active.';
                for (ampi__project_geographic_area__c pga : checkDuplicates) {
                    if (pga.ampi__Active__c == false) {
                        // pga.ampi__Active__c = true;
                        errorMessage = 'Project Geographic Area relation is already added and it\'s inactive. Please activate this relation in the menu \'Project Geographic Area\' filtered by the project name.';
                        newPGA.addError(errorMessage);
                    }
                }
            }

            //    ampi__geographical_area__c currentGA = [SELECT Name,ampi__Type__c, Thematic_Area__r.ampi__Active__c FROM ampi__geographical_area__c WHERE Id =: acc.ampi__geographic_area__c LIMIT 1];
        	List<ampi__geographical_area__c> gas = [SELECT Name,ampi__Type__c, Thematic_Area__r.ampi__Active__c FROM ampi__geographical_area__c WHERE Id =: newPGA.ampi__geographic_area__c];

        	ampi__geographical_area__c currentGA = (gas.size() == 0 ? null : gas[0]);
			If (currentGA == null) {				
				return;
			}    
            
            if (currentGA.ampi__Type__c == 'Programme Unit' || currentGA.ampi__Type__c == 'National Management Unit') {
                system.debug('####currentGA.Thematic_Area__r.ampi__Active__c:' + currentGA.Thematic_Area__r.ampi__Active__c);
                if (currentGA.Thematic_Area__r.ampi__Active__c == null || currentGA.Thematic_Area__r.ampi__Active__c == false) {
                    newPGA.addError('Service type is missing or inactive for Programme unit. Please add or update the Service type');
                    return;
                }
            }
     }

     private void afterInsertStandardAndTransition(ampi__project_geographic_area__c newPGA) {
    	Boolean hasChanged = false;
    	
            /*String gaId = acc.ampi__Geographic_Area__c;
            List<ampi__Geographical_Area__c> gas = [SELECT Id FROM ampi__Geographical_Area__c WHERE Id =: gaId AND ampi__Type__c = 'Programme Unit'];
            System.debug('##### gas:' + gas.size());
            System.debug('##### gaId:' + gaId);

            if (gas.size() > 0) {
                acc.Is_PU__c = true;
                hasChanged = true;
            }*/
            
            system.debug('#### acc.ampi__project__c:' + newPGA.ampi__project__c);
            set<String> transitionProjectTypes = new set<String> {'National services','Child Money Gift','Fund Development','IF4C'};
            set<String> transitionProjectTypesFinancialCategory = new set<String> {'Grant','Running Costs','Emergency'};
            set<String> programmeTypes = new set<String> {'Programme Unit','National Management Unit'};
            ampi__project__c currentProject = [SELECT Name, RecordTypeId, Id, Transition_Project_Type__c FROM ampi__project__c WHERE Id =: newPGA.ampi__project__c LIMIT 1];
            ampi__geographical_area__c currentGA = [SELECT Code__c, Name, ampi__Type__c, Thematic_Area__r.Name, Id FROM ampi__geographical_area__c WHERE Id =: newPGA.ampi__geographic_area__c LIMIT 1];
            
            system.debug('#### currentProject.RecordTypeId:' + currentProject.RecordTypeId);
            string recordtypeName = GetObjects.getRecordTypeNameByProjectRecordTypeId(currentProject.RecordTypeId);
            system.debug('#### GetObjects.getRecordTypeNameByProjectRecordTypeId:' + recordtypeName);
            if (recordtypeName == 'Transition' && 
                programmeTypes.contains(currentGA.ampi__Type__c) && 
                !transitionProjectTypes.contains(currentProject.Transition_Project_Type__c)) {
                ampi__reporting_period__c reportingPeriod = CreateObjects.manageMonitoringPeriodByProject(newPGA.ampi__project__c, 1);
                System.debug('####currentProject.Transition_Project_Type__c: ' + currentProject.Transition_Project_Type__c);
                System.debug('####currentGA.Code__c: ' + currentGA.Id);
                
                String gaCode = (currentProject.Transition_Project_Type__c == 'Grant' || currentProject.Transition_Project_Type__c == 'Running Costs' ? currentGA.Id + '': '');

                ampi__Budget__c newBudgetGrant = CreateObjects.createBudget(currentProject.Name +  ' ' + currentGA.Name, currentProject.Name +  ' ' + currentGA.Name, currentProject.Id, false);
                System.debug('#####currentGA.Thematic_Area__r.Name:' + currentGA.Thematic_Area__r.Name);

                String category = (currentGA.ampi__Type__c == 'National Management Unit' && (currentGA.Thematic_Area__r.Name == NULL || currentGA.Thematic_Area__r.Name == '')) ? 'NB' : currentGA.Thematic_Area__r.Name;
                String financialCategory = '';

                if (transitionProjectTypesFinancialCategory.contains(currentProject.Transition_Project_Type__c)) {                    
                    financialcategory = getFinancialCategoryByServiceType(category);
                }

                financialCategory = financialCategory == '' ? category : financialCategory;
                
                if (gaCode == '' || gaCode == null) {
                    ampi__Financial__c newFinancialGrant = CreateObjects.createFinancial(currentGA.Name, '', financialCategory, newBudgetGrant.Id, reportingPeriod.Id, true);            	
                } else {
                    ampi__Financial__c newFinancialGrant = ExtraCreateObjects.createFinancialWithPU(currentGA.Name, '', financialCategory, newBudgetGrant.Id, reportingPeriod.Id, true, gaCode);            	
                }                    
            }
     }
    
     //@future
     //https://help.salesforce.com/s/articleView?id=000386220&type=1
     //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_invoking_future_methods.htm
     private void afterInsertProjectServiceType(ampi__project_geographic_area__c newPGA, List<ampi__project_thematic_area__c> currentPSTs) {
    	List<Id> pgas = new List<Id>();
        Set<String> transitionTypesToAvoid = new Set<String> { 'National services','Fund Development','IF4C','Child Money Gift' };
        Set<String> recordTypeProjects = new Set<String> {'Standard','Grant','Humanitarian'};
        List<ampi__project_Thematic_area__c> newPSTs = new List<ampi__project_Thematic_area__c>();
        
            ampi__project_geographic_area__c currentPGA = [SELECT ampi__project__r.Transition_Project_Type__c, ampi__Project__r.RecordType.Name, ampi__geographic_area__r.ampi__Type__c, ampi__geographic_area__r.Thematic_Area__c, ampi__geographic_area__r.Thematic_Area__r.ampi__Active__c, ampi__Geographic_Area__r.ISP_Available__c, ampi__Geographic_Area__r.Extent_Information__c FROM ampi__project_geographic_area__c WHERE Id =: newPGA.Id LIMIT 1];

            if (currentPGA.ampi__project__r.RecordType.Name == 'Construction' || 
                (currentPGA != null && currentPGA.ampi__project__r != null && 
                 currentPGA.ampi__project__r.RecordType.Name == 'Transition' && 
                 (currentPGA.ampi__project__r.Transition_Project_Type__c == null || transitionTypesToAvoid.contains(currentPGA.ampi__project__r.Transition_Project_Type__c)))) {
                System.debug('###currentPGA Not creating projects');
                return;            
            } 

            if (currentPGA.ampi__geographic_area__r.ampi__Type__c == 'Programme Unit' || currentPGA.ampi__geographic_area__r.ampi__Type__c == 'National Management Unit') {
                pgas.add(newPGA.Id);
                
                boolean duplicated = false;
                for (ampi__project_thematic_area__c currentPST : currentPSTs) {
                    if (newPGA.ampi__Project__c == currentPST.ampi__Project__c) {
                        System.debug('####acc.ampi__Project__r.RecordType.Name:' + currentPGA.ampi__Project__r.RecordType.Name);
                        System.debug('####currentPST.ampi__thematic_area__c:' + currentPST.ampi__thematic_area__c);
                        System.debug('####currentPST.Programme_Unit__c == acc.ampi__geographic_area__c:' + currentPST.Programme_Unit__c);
                        if (recordTypeProjects.contains(currentPGA.ampi__Project__r.RecordType.Name)) {
                            if (currentPST.ampi__thematic_area__c == currentPGA.ampi__geographic_area__r.Thematic_Area__c) {
                                duplicated = true;     
                            }
                        } else {
                            if (currentPST.ampi__thematic_area__c == currentPGA.ampi__geographic_area__r.Thematic_Area__c && currentPST.Programme_Unit__c <> NULL && currentPST.Programme_Unit__c == newPGA.ampi__geographic_area__c ) {
                                duplicated = true;
                            }
                        }
                    }
                }
                System.debug('###duplicated:' + duplicated);                
                if (!duplicated) {
                    ampi__project_thematic_area__c pst = new ampi__project_thematic_area__c();
                    pst.ampi__Project__c = newPGA.ampi__Project__c;
                    pst.Programme_Unit__c = newPGA.ampi__geographic_area__c;
                    pst.ampi__Thematic_Area__c =  currentPGA.ampi__geographic_area__r.Thematic_Area__c;
                    pst.ISP_Available__c = currentPGA.ampi__Geographic_Area__r.ISP_Available__c; 
                    pst.PU_Extent_Information__c = currentPGA.ampi__Geographic_Area__r.Extent_Information__c;
                    newPSTs.add(pst);
                }
            }

        if (newPSTs.size() > 0) {
            INSERT newPSTs;
        }

        if (pgas.size() > 0) {
            List<ampi__project_geographic_area__c> updateDeletePIGAS = [SELECT Id, Delete_PIGAs__c FROM ampi__project_geographic_area__c WHERE Id IN : pgas];
            
            for(ampi__project_geographic_area__c acc : updateDeletePIGAS){
                acc.Delete_PIGAs__c = true;
            }
            UPDATE updateDeletePIGAS;
        }
    }
    
     private void deletePIGAs(List<ampi__Project_Geographic_Area__c> projectGeographicAreas, Map<Id, ampi__Project_Geographic_Area__c> oldProjectGeographicAreas){
		Set<Id> gAreasIds = new Set<Id>();
		Set<Id> pIds = new Set<Id>();
		for(ampi__Project_Geographic_Area__c pga : projectGeographicAreas){
			if(pga.Delete_PIGAs__c && !oldProjectGeographicAreas.get(pga.Id).Delete_PIGAs__c){
				gAreasIds.add(pga.ampi__Geographic_Area__c);
				pIds.add(pga.ampi__Project__c);
			}
		}
		System.debug('#### ' + gAreasIds.size());
		if (gAreasIds.size()>0) {
			List<ampi__Project_Indicator_Geographic_Area__c> PIGAs = [SELECT Id, ampi__Geographic_Area__c, ampi__Geographic_Area__r.Thematic_Area__c, ampi__Project_Indicator__c, ampi__Project_Indicator__r.ampi__Project__c, ampi__Project_Indicator__r.ampi__Catalog_Indicator__c FROM ampi__Project_Indicator_Geographic_Area__c WHERE ampi__Geographic_Area__c IN: gAreasIds];// AND ampi__Project_Indicator__r.ampi__Project__c IN: pIds];
			if(PIGAs.size()>0){
				System.debug('#### ' + PIGAs.size());
					//delete PIGAs;
				List<ampi__Geographical_Area__c> gAreas = [SELECT Id, Thematic_Area__c FROM ampi__Geographical_Area__c WHERE Id IN: gAreasIds];
				Set<Id> thematicAreaIds = new Set<Id>();
				if(gAreas.size()>0){
					System.debug('#### ' + gAreas.size());
					for(ampi__Geographical_Area__c ga : gAreas){
						thematicAreaIds.add(ga.Thematic_Area__c);
					}
					if(thematicAreaIds.size()>0){
						System.debug('#### ' + thematicAreaIds.size());
						List<ampi__Indicator_Thematic_Area__c> ITAs = [SELECT Id, ampi__Indicator__c, ampi__Required__c, ampi__Thematic_Area__c FROM ampi__Indicator_Thematic_Area__c WHERE ampi__Thematic_Area__c IN: thematicAreaIds];
						Map<Id, Set<Id>> ITAThematicArea = new Map<Id, Set<Id>>();
						for(Id id : thematicAreaIds){
							Set<Id> ITAIndicators = new Set<Id>();	
							for(ampi__Indicator_Thematic_Area__c ITA : ITAs){
								if(id == ITA.ampi__Thematic_Area__c){
									ITAIndicators.add(ITA.ampi__Indicator__c);
								}
							}
							ITAThematicArea.put(id, ITAIndicators);
						}					
						
						System.debug('#### ' + ITAThematicArea.size());
						List<ampi__Project_Indicator_Geographic_Area__c> PIGAs2Delete = new List<ampi__Project_Indicator_Geographic_Area__c>();
						for(ampi__Project_Indicator_Geographic_Area__c PIGA : PIGAs){
							Boolean found = false;
							if(ITAThematicArea.containsKey(PIGA.ampi__Geographic_Area__r.Thematic_Area__c)){
								if(ITAThematicArea.get(PIGA.ampi__Geographic_Area__r.Thematic_Area__c).contains(PIGA.ampi__Project_Indicator__r.ampi__Catalog_Indicator__c)){
									found = true;	
								}
							}
							if(!found){
								PIGAs2Delete.add(PIGA);		
							}
						}
						if(PIGAs2Delete.size()>0){
							delete PIGAs2Delete;
						}
					}
					else{
						delete PIGAs;
					}
				}
			}
		}
	 }
    
	 private String getFinancialCategoryByServiceType(String category) {
        String financialcategory = '';
        if (category == 'YC' || category == 'SIL') {
                        financialcategory = 'SIL';
                    } else if (category == 'SFC' || category == 'FLC') {
                        financialcategory = 'FLC';
                    } else if (category == 'FS' || category == 'DFE') {
                        financialcategory = 'DFE';
                    } else if (category == 'CT' || category == 'CPT') {
                        financialcategory = 'CPT';
                    } else if (category == 'ER' || category == 'HA') {
                        financialcategory = 'HA';
                    } else if (category == 'CFE') {
                        financialcategory = 'CFE';
                    }
        return financialcategory;
     }
     
    @InvocableMethod(label='Remove D365 Project Stand In') 
    public Static void RemoveD365ProjectStandIn(List<FlowInputs> request) {
        List<D365_Project_Stand_in__c> psiToRemove = [SELECT Id FROM D365_Project_Stand_in__c WHERE Project_Programme_Location__c =: request[0].programmeId AND Project__c =: request[0].projectId];
        DELETE psiToRemove;
	}

	public class FlowInputs{    
    	@InvocableVariable
        public Id projectId;
        @InvocableVariable
        public Id programmeId;
    }
}