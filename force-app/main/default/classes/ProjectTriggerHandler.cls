public class ProjectTriggerHandler {
    public void manageProjectsBeforeInsertByRecordType(List<ampi__project__c> newProjects) {
        for (ampi__project__c proj : newProjects) {
         	string recordtypeName = GetObjects.getRecordTypeNameByProjectRecordTypeId(proj.RecordTypeId);   
            
            switch on recordtypeName {
                when 'Grant' {
                    afterInsertGrantProjectsWhenStatusIsEmpty(proj);
                }
                when else {
                    break;
                }
            }
        }    	 
    }
    
    public void manageProjectsBeforeDeleteByRecordType(List<ampi__project__c> oldProjects) {
        for (ampi__project__c oldProject : oldProjects) {
            beforeDeleteUpdateRestrictBaseProjectsDeletion(oldProject);
        }
    }
    
    public void manageProjectsAfterInsertByRecordType(List<ampi__project__c> newProjects) {
        for (ampi__project__c proj : newProjects) {
         	string recordtypeName = GetObjects.getRecordTypeNameByProjectRecordTypeId(proj.RecordTypeId);   
            System.debug('####Construction:' + recordtypeName);
            switch on recordtypeName {
                when 'Grant' {
                    afterInsertGrantProjects(proj);
                }
                when 'Sos_YouthCan_Project' {
                    afterInsertYouthCanProjects(proj);
                }
                when 'Construction' {
                    afterInsertConstructionProjects(proj);
                }
            }
            
            afterInsertCreateFinancialsForProjects(proj, recordtypeName);
        }    	 
    }
    
    public void manageProjectsBeforeUpdateByRecordType(List<ampi__project__c> oldProjects, List<ampi__project__c> newProjects) {
        for (ampi__project__c newProject : newProjects) {
         	string recordtypeName = GetObjects.getRecordTypeNameByProjectRecordTypeId(newProject.RecordTypeId);   
            ampi__project__c currentProject = null; 
            for (ampi__project__c oldProject : oldProjects) {
                if (oldProject.Id == newProject.Id) {
                	currentProject = oldProject;
                }
            }
            
            if (currentProject == NULL) {
                return;
            }
            
            System.debug('####afterUpdateInFormulationCreateMonitoringPeriodsForProjects ' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
            afterUpdateInFormulationCreateMonitoringPeriodsForProjects(currentProject, newProject);
            System.debug('####beforeDeleteUpdateRestrictBaseProjectsDeletion  ' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
            beforeDeleteUpdateRestrictBaseProjectsDeletion(currentProject);
            System.debug('....recordtypeName:' + recordtypeName);
            switch on recordtypeName {
                when 'Standard' {
                    System.debug('####beforeUpdateProjectISPAvailable  ' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
                    beforeUpdateProjectISPAvailable(currentProject, newProject, recordtypeName);
                    System.debug('####beforeUpdateProjectStatus  ' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
                    beforeUpdateProjectStatus(currentProject, newProject, recordtypeName);              
                }
                when 'Transition' {
                    beforeUpdateProjectISPAvailable(currentProject, newProject, recordtypeName);
                    beforeUpdateProjectStatus(currentProject, newProject, recordtypeName);   
                }
                when 'Grant', 'Emergency_Response', 'Construction' {
					beforeUpdateProjectStatus(currentProject, newProject, recordtypeName);   
                }
            }
            System.debug('####beforeUpdateDeleteProgrammeLocationPGA  ' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
            beforeUpdateDeleteProgrammeLocationPGA(currentProject, newProject);                    
        }    	 
    }

    private void afterInsertGrantProjectsWhenStatusIsEmpty(ampi__project__c proj) {
        System.debug('####afterInsertGrantProjectsWhenStatusIsEmpty');
        //for(ampi__project__c proj: newProjects)
        //{    
             //string recordtypeName = GetObjects.getRecordTypeNameByProjectRecordTypeId(proj.RecordTypeId);
             System.debug('####proj.Project_Status__c: '+ proj.ampi__Project_Status__c);
             //System.debug('####recordtypeName: '+ recordtypeName);
             if((proj.ampi__Project_Status__c == null || proj.ampi__Project_Status__c == '')) {
                 proj.ampi__Project_Status__c = 'In Identification';
                 System.debug('####updating...');
             }
         //}
    }
    
    private void afterInsertGrantProjects(ampi__project__c acc) {
            System.debug('1.Init Create_BaseInfo_For_Grant_Project');            
                    
			ampi__reporting_period__c reportingPeriod;
            String reportingPeriodId = '';
            System.debug('### acc.Monitoring_Period__c:' + acc.Monitoring_Period__c);
            if (acc.Monitoring_Period__c == null || acc.Monitoring_Period__c == '') {
            	ampi__Reporting_Period__c addedReportingPeriods = CreateObjects.manageMonitoringPeriodByProject(acc.Id, 1);
            	reportingPeriodId = addedReportingPeriods.Id;
            } else {
            	reportingPeriodId = acc.Monitoring_Period__c;
            }

            ampi__Budget__c newBudgetPSCI = CreateObjects.createBudget(acc.Name + ' Budget PSCI', acc.Name, acc.Id, false);
            ampi__Disbursement__c newDisbursement = CreateObjects.createDisbursement(acc.Id, reportingPeriodId, false);
            ampi__Financial__c newFinancialPSCI = CreateObjects.createFinancial('Project Support Costs & Income', '', '9 PSCI', newBudgetPSCI.Id, reportingPeriodId, true);
                            
            ampi__Budget__c newBudgetGrant = CreateObjects.createBudget(acc.Name + ' Budget Grant', acc.Name, acc.Id, false);
            ampi__Financial__c newFinancialGrant = CreateObjects.createFinancial('Grant Activities', '', '', newBudgetGrant.Id, reportingPeriodId, true);           
    }
    
    private void afterInsertConstructionProjects(ampi__project__c acc) {
        System.debug('1.Init Create_Result_Staments_For_Construction');
                //EXISTS PROJECT
                String activityScheduleName = 'Planning activities schedule';
                List<ampi__Implementation_Plan__c> newActivitySchedulesForMetadata = CreateObjects.createNewActivitySchedule(activityScheduleName, acc.Id);

                if (newActivitySchedulesForMetadata.size() > 0) {
                	List<Construction_Activity_Project__mdt> activitiesFromMetadata = Construction_Activity_Project__mdt.getAll().values();
                    CreateObjects.manageNewActivitiesFromMetadata(activitiesFromMetadata, acc.Id, newActivitySchedulesForMetadata[0].Id);
                }
                
                    
                ampi__reporting_period__c reportingPeriod;
                String reportingPeriodId = '';
                System.debug('### acc.Monitoring_Period__c:' + acc.Monitoring_Period__c);
                if (acc.Monitoring_Period__c == null || acc.Monitoring_Period__c == '') {
                        ampi__Reporting_Period__c addedReportingPeriods = CreateObjects.manageMonitoringPeriodByProject(acc.Id, 1);
                    	reportingPeriodId = addedReportingPeriods.Id;
                } else {
                        reportingPeriodId = acc.Monitoring_Period__c;
                }
                System.debug('####Construction0');
				ampi__Budget__c newBudgetPSCI = CreateObjects.createBudget(acc.Name + ' Budget PSCI', acc.Name, acc.Id, false);
        		System.debug('####Construction1');
                ampi__Disbursement__c newDisbursement = CreateObjects.createDisbursement(acc.Id, reportingPeriodId, false);
                ampi__Financial__c newFinancialPSCI = CreateObjects.createFinancial('Project Support Costs & Income', '', '9 PSCI', newBudgetPSCI.Id, reportingPeriodId, true);
                System.debug('####Construction2');
                ampi__Budget__c newBudgetGrant = CreateObjects.createBudget(acc.Name + ' Budget', acc.Name, acc.Id, false);
        		System.debug('####Construction3');
                ampi__Financial__c newFinancialGrant = CreateObjects.createFinancial('Construction Activities', '', 'Construction', newBudgetGrant.Id, reportingPeriodId, true);                    
    }
    
    private void afterInsertYouthCanProjects(ampi__project__c acc) {
        System.debug('1.Init Create_Result_Staments_For_YouthCan');
        
		List<ampi__Project__c> queryBaseProject = GetObjects.getProjectsByName('YouthCan project for base records');
        //EXISTS PROJECT
                if (queryBaseProject.size() > 0) {
                    ampi__Project__c baseProject = queryBaseProject[0];
                    System.debug('3. Get Project Template Id: '+ baseProject.Id);
                	
                    Map<String, String> frameworkMatchIds = new Map<String, String>();

                    List<ampi__xx_Framework__c> frameworks = GetObjects.getFrameworksByProjectId(baseProject.Id);
                    System.debug(frameworks);
                    
                    List<ampi__xx_Framework__c> newFrameworks = CreateObjects.manageNewFrameworks(frameworks, acc.Id);
                    
                    if (newFrameworks.size() > 0) {
                        newFrameworks = [SELECT Id, Name, ampi__xx_Framework_Locked__c From ampi__xx_Framework__c WHERE ampi__xx_Project__c =: acc.Id];
						//frameworkMatchIds = CreateObjects.getDictionaryFromOldAndNewFrameworks(frameworks, newFrameworks);
                        frameworkMatchIds = GetObjects.getDictionaryFromOldAndNewRecords(frameworks, newFrameworks, 'Name', false, '');
                    	System.debug('#### frameworkMatchIds:' + frameworkMatchIds);
                    }

                    Map<String, String> objectiveMatchIds = new Map<String, String>();
                    Map<String, String> objectiveFrameworkIds = new Map<String, String>();
					
                    List<ampi__Objective__c> objectives = GetObjects.getObjectivesByProjectId(baseProject.Id);
                    List<ampi__Objective__c> newObjectives = CreateObjects.manageNewObjectives(objectives, acc.Id, frameworkMatchIds, false); 

                    if (newObjectives.size() > 0) {
                        newObjectives = [SELECT Id, ampi__Description__c, ampi__xx_Framework__c, ampi__Parent_Project_Objective__c, ampi__Label__c From ampi__Objective__c WHERE ampi__Project__c =: acc.Id];
						
                        objectiveMatchIds = GetObjects.getDictionaryFromOldAndNewRecords(objectives, newObjectives, 'ampi__Description__c', false, '');
                        objectiveFrameworkIds = GetObjects.getDictionaryFromOldAndNewRecords(objectives, newObjectives, 'ampi__Description__c', true, 'ampi__xx_Framework__c');
                        
                        CreateObjects.updateParentObjectiveRecords(objectives, newObjectives, objectiveMatchIds, objectiveFrameworkIds);
                        CreateObjects.lockFrameworks(newFrameworks);
                    }

                    List<ampi__Project_Indicator__c> projectIndicators = GetObjects.getProjectIndicatorsByProject(baseProject.Id);
                    //ADD INFO IN TAB INDICATORS (PROJECT)
                    
					List<ampi__Project_Indicator__c> newProjectIndicators = CreateObjects.manageNewProjectIndicators(projectIndicators, acc.Id, '', false);
                    Map<String, String> projectIndicatorsMatchIds = new Map<String, String>();

                    if (newProjectIndicators.size() > 0) {
                        System.debug('9. Project Indicator newProjectIndicators: '+ newProjectIndicators.size());
                        newProjectIndicators = [SELECT Id, ampi__Description__c From ampi__Project_Indicator__c WHERE ampi__Project__c =: acc.Id];
						projectIndicatorsMatchIds = GetObjects.getDictionaryFromOldAndNewRecords(projectIndicators, newProjectIndicators, 'ampi__Description__c', false, '');
                    }
                    
                    //INSERTING: ampi__Reporting_Period__c
                    Map<String, String> reportingPeriodMatchIds = new Map<String, String>();
                    
                    List<ampi__Reporting_Period__c> reportingPeriods = GetObjects.getReportingPeriodsByProject(baseProject.Id);//'a0i1w000002wa0NAAQ'
					List<ampi__Reporting_Period__c> newReportingPeriods = CreateObjects.manageReportingPeriodsByProject(reportingPeriods, acc.Id);
                    
                    if (newReportingPeriods.size() > 0) {
                        System.debug('10. Reporting Periods newReportingPeriods: '+ newReportingPeriods.size());
                        newReportingPeriods = [SELECT Id, ampi__Label__c From ampi__Reporting_Period__c WHERE ampi__Project__c =: acc.Id];
					    reportingPeriodMatchIds = GetObjects.getDictionaryFromOldAndNewRecords(reportingPeriods, newReportingPeriods, 'ampi__Label__c', false, '');
                    }

                    //INSERTING: ampi__Project_Geographic_Area__c
                    List<ampi__Project_Geographic_Area__c> pGAs = GetObjects.getPGAsByProject(baseProject.Id);
 					List<ampi__Project_Geographic_Area__c> newPGAs = CreateObjects.managePGAsByProject(pGAs, acc.Id, '');
 
                    //TODO MISSING REFACTORING
                    //INSERTING: ampi__Project_Indicator_Reporting_Period__c
                    List<ampi__Project_Indicator_Reporting_Period__c> pIRPs = GetObjects.getProjectIndicatorMonitoringPeriodsByProjectId(baseProject.Id);
                    List<ampi__Project_Indicator_Reporting_Period__c> newPIRPs = CreateObjects.manageProjectIndicatorMonitoringPeriodsByProjectId(pIRPs, projectIndicatorsMatchIds, reportingPeriodMatchIds);
                    
                    //INSERTING: ampi__Project_Indicator_Geographic_Area__c
                    List<ampi__Project_Indicator_Geographic_Area__c> pIGAs = GetObjects.getProjectIndicatorGeographicAreaByProjectId(baseProject.Id);
					List<ampi__Project_Indicator_Geographic_Area__c> newPIGAs = CreateObjects.manageProjectIndicatorGeographicAreaByProjectId(pIGAs, projectIndicatorsMatchIds);
                }       
                            
    }
    
    private void afterInsertCreateFinancialsForProjects(ampi__project__c acc, String recordtypeName) {
    	System.debug('1.Init Create_Financials_For_Projects');
    	    /*List<ampi__Reporting_Period__c> addedReportingPeriods = GetObjects.getReportingPeriodsByProject(acc.Id);
            ampi__reporting_period__c reportingPeriod = new ampi__reporting_period__c();
			
            if (addedReportingPeriods.size() == 0) {*/
            ampi__reporting_period__c reportingPeriod;
            String reportingPeriodId = '';
            System.debug('### acc.Monitoring_Period__c:' + acc.Monitoring_Period__c);
            if (acc.Monitoring_Period__c == null || acc.Monitoring_Period__c == '') {
                ampi__Reporting_Period__c addedReportingPeriods = CreateObjects.manageMonitoringPeriodByProject(acc.Id, 1);
                reportingPeriodId = addedReportingPeriods.Id;
            } else {
                reportingPeriodId = acc.Monitoring_Period__c;
            }
            
        	System.debug('###Transition:' + acc.Transition_Project_Type__c);
        	System.debug('###Transition:' + recordtypeName);
            switch on recordtypeName {
                		when 'Transition' {
                            //String budgetName = (acc.Transition_Project_Type__c == 'Child Money Gift') ? 'CMG' : acc.Name + ' Budget PSCI';
                            //String financialType = (acc.Transition_Project_Type__c == 'Child Money Gift') ? '3 CMG' : 'PSCI';
                            //ampi__Budget__c newBudgetPSCI = CreateObjects.createBudget(budgetName, acc.Name, acc.Id, true);
                            //ampi__Disbursement__c newDisbursement = CreateObjects.createDisbursement(acc.Id, reportingPeriodId, true);
                            //ampi__Financial__c newFinancialPSCI = CreateObjects.createFinancial('Project Support Costs & Income', '', financialType, newBudgetPSCI.Id, reportingPeriodId, true);                        
                            String financialType = '';
                            String budgetName = '';
                            ampi__Budget__c newBudgetPSCI = null;
                            ampi__Disbursement__c newDisbursement = null;
                            ampi__Financial__c newFinancialPSCI = null;
                            if (acc.Transition_Project_Type__c == 'National services') {
                                    financialType = '1 NA ADMIN'; //'1 NA GSC';   
                                    budgetName = acc.Name + ' ' + financialType;
                                    newBudgetPSCI = CreateObjects.createBudget(budgetName, acc.Name, acc.Id, true);
                                    CreateObjects.createFinancial('National Administration', '', financialType, newBudgetPSCI.Id, reportingPeriodId, true);
    
                                    financialType = '1 P ADV';            
                                    budgetName = acc.Name + ' ' + financialType;             
                                    newBudgetPSCI = CreateObjects.createBudget(budgetName, acc.Name, acc.Id, true);
                                    CreateObjects.createFinancial('Programme & Advocacy', '', financialType, newBudgetPSCI.Id, reportingPeriodId, true);
    
                                    CreateObjects.createDisbursement(acc.Id, reportingPeriodId, true);
                            } else if (acc.Transition_Project_Type__c == 'Child Money Gift') {
                                    financialType = '3 CMG CI'; 
                                    budgetName = acc.Name + ' ' + financialType;
                                    newBudgetPSCI = CreateObjects.createBudget(budgetName, acc.Name, acc.Id, true);
                                    CreateObjects.createFinancial('CMG', '', financialType, newBudgetPSCI.Id, reportingPeriodId, true);
                                    CreateObjects.createDisbursement(acc.Id, reportingPeriodId, true);
                            } else if (acc.Transition_Project_Type__c == 'Fund Development') {
                                    financialType = '3 FD CI'; 
                                    budgetName = acc.Name + ' ' + financialType;
                                    newBudgetPSCI = CreateObjects.createBudget(budgetName, acc.Name, acc.Id, true);
                                    CreateObjects.createFinancial('FD Costs & Income', '', financialType, newBudgetPSCI.Id, reportingPeriodId, true);
                                    CreateObjects.createDisbursement(acc.Id, reportingPeriodId, true);
                            } else if (acc.Transition_Project_Type__c == 'IF4C') {
                                    financialType = '3 IF4C'; 
                                    budgetName = acc.Name + ' ' + financialType;
                                    newBudgetPSCI = CreateObjects.createBudget(budgetName, acc.Name, acc.Id, true);
                                    CreateObjects.createFinancial('IF4C Int. Income', '', financialType, newBudgetPSCI.Id, reportingPeriodId, true);
                                    CreateObjects.createDisbursement(acc.Id, reportingPeriodId, true);
                            } else {
                                budgetName = acc.Name + ' Budget PSCI';
                                financialType = '9 PSCI';
                                newBudgetPSCI = CreateObjects.createBudget(budgetName, acc.Name, acc.Id, true);
                                newDisbursement = CreateObjects.createDisbursement(acc.Id, reportingPeriodId, true);
                                newFinancialPSCI = CreateObjects.createFinancial('Project Support Costs & Income', '', financialType, newBudgetPSCI.Id, reportingPeriodId, true);                        
                            }
                 		} 
                		when 'Standard' {
                            ampi__Budget__c newBudgetPSCI = CreateObjects.createBudget(acc.Name + ' Budget PSCI', acc.Name, acc.Id, false);
                            ampi__Disbursement__c newDisbursement = CreateObjects.createDisbursement(acc.Id, reportingPeriodId, false);
                            ampi__Financial__c newFinancialPSCI = CreateObjects.createFinancial('Project Support Costs & Income', '', '9 PSCI', newBudgetPSCI.Id, reportingPeriodId, true);
                            
                            ampi__Budget__c newBudgetResultBased = CreateObjects.createBudget(acc.Name + ' Budget Result based', acc.Name, acc.Id, false);
                            //ampi__Financial__c newFinancialResultBased = CreateObjects.createFinancial('Results-based Activities', '', 'Result based', newBudgetResultBased.Id, reportingPeriodId);
                            ampi__Financial__c newFinancialResultBased = CreateObjects.createFinancial('Results-based Activities', '', '', newBudgetResultBased.Id, reportingPeriodId, true);
                            
                            ampi__Budget__c newBudgetOverarching = CreateObjects.createBudget(acc.Name + ' Budget Overarching', acc.Name, acc.Id, false);
                            //ampi__Financial__c newFinancialOverarching = CreateObjects.createFinancial('Overarching Activities', '', 'Overarching', newBudgetOverarching.Id, reportingPeriodId);
                            ampi__Financial__c newFinancialOverarching = CreateObjects.createFinancial('Overarching Activities', '', '', newBudgetOverarching.Id, reportingPeriodId, true);
            			} 
                		when 'Emergency_Response' {
                            // } else if(recordtypeName == 'Emergency Response') {
                            ampi__Budget__c newBudgetPSCI = CreateObjects.createBudget(acc.Name + ' Budget PSCI', acc.Name, acc.Id, false);
                            ampi__Disbursement__c newDisbursement = CreateObjects.createDisbursement(acc.Id, reportingPeriodId, false);
                            ampi__Financial__c newFinancialPSCI = CreateObjects.createFinancial('Project Support Costs & Income', '', '9 PSCI', newBudgetPSCI.Id, reportingPeriodId, true);
                            
                            ampi__Budget__c newBudgetResultBased = CreateObjects.createBudget(acc.Name + ' Budget Humanitarian', acc.Name, acc.Id, false);
                            ampi__Financial__c newFinancialResultBased = CreateObjects.createFinancial('Humanitarian Activities', '', '', newBudgetResultBased.Id, reportingPeriodId, true);
			            }
			}
    }
    
    private void beforeDeleteUpdateRestrictBaseProjectsDeletion(ampi__project__c acc) {
        if (acc.Name == 'Construction project for base records' || acc.Name == 'Grant project for base records' || acc.Name == 'YouthCan project for base records') {
        	acc.addError('Base Projects are not allowed to be removed or changed');            
        } 
    }

    private void beforeUpdateProjectISPAvailable(ampi__Project__c prsToCheck, ampi__Project__c prsUpdated, String recordTypeName) {
        System.debug('####enter beforeUpdateProjectISPAvailable:' + prsToCheck);
        System.debug('####enter beforeUpdateProjectISPAvailable new:' + prsUpdated);
            
        //List<ampi__Project_Thematic_Area__c> ptas = new List<ampi__Project_Thematic_Area__c>(); 
        List<ampi__Project_Thematic_Area__c> ptas = [SELECT Id, ampi__project__c, ISP_Available__c FROM ampi__Project_Thematic_Area__c WHERE ampi__project__c =: prsUpdated.Id];                        

        //WHERE Id =: prsToCheck.Id    
            if ((recordTypeName == 'Standard' || recordTypeName == 'Transition') && prsUpdated.ISP_Available__c == 'No') {
                    // List<ampi__Project_Thematic_Area__c> psts = [SELECT Id, ISP_Available__c FROM ampi__Project_Thematic_Area__c WHERE Programme_Unit__c =: prsUpdated.Id];
                    List<ampi__Project_Thematic_Area__c> updatePTAs = new List<ampi__Project_Thematic_Area__c>();
                        
                    for (ampi__Project_Thematic_Area__c pta : [SELECT Id, ISP_Available__c FROM ampi__Project_Thematic_Area__c WHERE ampi__project__c =: prsUpdated.Id AND ISP_Available__c <>: prsUpdated.ISP_Available__c]) {
                        pta.ISP_Available__c = prsUpdated.ISP_Available__c;
                        updatePTAs.add(pta);
                    }       

                    if (updatePTAs.size() == 0) {
                        return;
                    }             

                    Database.SaveResult[] updateResult = Database.update(updatePTAs, false);  
                    for (Database.SaveResult r : updateResult){  
                        if (!r.isSuccess()){  
                        	prsUpdated.addError('Project Service Type related records have missing mandatory fields');
                        } 
                    }                                
            }
    }

    private void beforeUpdateProjectStatus(ampi__Project__c prsToCheck, ampi__Project__c prsUpdated, String recordTypeName) {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Manage_Restrictions');
        Set<String> restrictProjectPhasesAndStatuses = new Set<String> { 'In Implementation', 'Implementation', 'Closure', 'In Construction', 'Funding Approved', 'Plan Submitted', 'Application Approved', 'Partnership Agreement Signed'};
        
        //List<AggregateResult> havePermissionToSkip = [SELECT count(Id) permissionCount FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getUserId() AND PermissionSet.Name = 'Manage_Restrictions'];
		//if(((Integer)havePermissionToSkip[0].get('permissionCount')) > 0) 
        if (hasCustomPermission)
            return;
        
        //Map<ID,Schema.RecordTypeInfo> rt_Map = ampi__project__c.sObjectType.getDescribe().getRecordTypeInfosById();
        Set<Id> projIds = new Set<Id> { prsToCheck.Id };
        
        //List<deliverable__c> agreementsForStandard = agreementQueries.getAgreementsFromProjects(projIds);            
        List<deliverable__c> agreementsForStandard = agreementQueries.getAgreementsFromProjects(projIds);            

            String errors = '';

                    System.debug('###prsUpdated.Name:' + prsUpdated.Name);
                    System.debug('###prsUpdated.Programme_Location__c:' + prsUpdated.Programme_Location__c);
                    System.debug('###prsUpdated.Planned_Implementation_Start_Date__c:' + prsUpdated.Planned_Implementation_Start_Date__c);
                    System.debug('###prsUpdated.ampi__Project_Status__c:' + prsUpdated.ampi__Project_Status__c);
                    System.debug('###prsUpdated.Phase__c:' + prsUpdated.Phase__c);                    
                    System.debug('###prsUpdated.Transition_Project_Type__c:' + prsUpdated.Transition_Project_Type__c);                    

                    Integer countActivities = [SELECT Count() FROM ampi__activity__c WHERE project__c = : prsUpdated.Id AND ampi__Type__c <> 'Overarching' AND (Thematic_Area__c = null OR Thematic_Area__c = '')];
                    boolean existsActivities = (countActivities > 0);

                    // Integer countActivities = 0;
                    // for(ampi__activity__c act : [SELECT Id, project__c FROM ampi__activity__c WHERE project__c = : prsToCheck.Id AND (Thematic_Area__c = null OR Thematic_Area__c = '') AND ampi__Type__c <> 'Overarching']) {
                    //     if (act.project__c == prsUpdated.Id) {
                    //         existsActivities = true;
                    //         countActivities++;
                    //     }
                    // }

                    boolean existsAgreements = agreementQueries.existsAgreementFromProject(agreementsForStandard, prsUpdated.Id);
                                        
                    boolean constructionRestrictive = recordTypeName == 'Construction' && 
                                                      (prsUpdated.Name == '' || prsUpdated.Programme_Location__c == null || prsUpdated.Planned_Implementation_Start_Date__c == null  || existsActivities) && 
                                                      (prsUpdated.ampi__Project_Status__c == 'In Identification' || prsUpdated.ampi__Project_Status__c == 'Closure' || prsUpdated.Phase__c == 'Formulation'  || prsUpdated.Phase__c == 'Implementation' || prsUpdated.Phase__c == 'Closure');

                    boolean transitionRestrictive = recordTypeName == 'Transition' && 
                                                      (prsUpdated.Name == '' || prsUpdated.Programme_Location__c == null || prsUpdated.Planned_Implementation_Start_Date__c == null || prsUpdated.Transition_Project_Type__c == null || prsUpdated.Transition_Project_Type__c == '' || existsActivities) && 
                                                      (prsUpdated.ampi__Project_Status__c == 'In Implementation' || prsUpdated.Phase__c == 'Implementation' || prsUpdated.Phase__c == 'Closure');

                    boolean standardRestrictive = recordTypeName == 'Standard' && 
                                                      (prsUpdated.Name == '' || prsUpdated.Programme_Location__c == null || prsUpdated.Planned_Implementation_Start_Date__c == null || prsUpdated.Funding_organisation__c == null || existsActivities) && 
                                                      (prsUpdated.ampi__Project_Status__c == 'Funding Approved' || prsUpdated.ampi__Project_Status__c == 'In Implementation' || prsUpdated.Phase__c == 'Implementation' || prsUpdated.Phase__c == 'Closure');

                    boolean standardAggreementRestrictive = recordTypeName == 'Standard' && prsUpdated.ampi__Project_Status__c == 'Funding Approved' && !existsAgreements;                                                      

                    boolean grantRestrictive = recordTypeName == 'Grant' && 
                                                      (prsUpdated.Name == '' || prsUpdated.Contract_Eligibility_Start_Date__c == null || prsUpdated.Applicant_Accountable_Organisation__c == null  || existsActivities) && 
                                                      (prsUpdated.ampi__Project_Status__c == 'Application Approved' || prsUpdated.ampi__Project_Status__c == 'In Implementation' || prsUpdated.Phase__c == 'Implementation' || prsUpdated.Phase__c == 'Closure');
                                                    //   || prsUpdated.ampi__Project_Status__c == 'Application Rejected'

                    boolean humanitarianRestrictive = recordTypeName == 'Emergency_Response' && 
                                                      (prsUpdated.Name == '' || prsUpdated.Programme_Location__c == null || prsUpdated.Planned_Implementation_Start_Date__c == null  || existsActivities) && 
                                                      (prsUpdated.ampi__Project_Status__c == 'Plan submitted' || prsUpdated.ampi__Project_Status__c == 'In Implementation' || prsUpdated.Phase__c == 'Implementation' || prsUpdated.Phase__c == 'Closure');

                    String humanitarianExtraValidation = (((recordTypeName == 'Emergency_Response' && (prsUpdated.Planned_Implementation_Start_Date__c == null || prsUpdated.Planned_Total_Project_Budget_EUR__c == null) && prsUpdated.ampi__Project_Status__c == 'In Formulation')) ? 'Mandatory fields missing for these conditions: "Planned Implementation Start Date", "Planned Total Project Budget (EUR)" are mandatory for "In Formulation" status.' : 
                    									//(recordTypeName == 'Emergency_Response' && (prsUpdated.Total_Confirmed_Funding__c == null || prsUpdated.Total_Confirmed_Funding__c == 0) && prsUpdated.ampi__Project_Status__c == 'Plan Submitted') ? '"Total Confirmed Funding" is mandatory for "Plan Submitted" status.' : Commented because of AMIMSP-1758
                                                        (recordTypeName == 'Emergency_Response' && (prsUpdated.Programme_Location__c == null || prsUpdated.ampi__Thematic_Area_Text__c == null || prsUpdated.ampi__Thematic_Area_Text__c == '' || prsUpdated.Approved_Total_Projec_Budget_Eur__c == null || prsUpdated.Planned_Implementation_End_Date__c == null) && prsUpdated.ampi__Project_Status__c == 'Partnership Agreement Signed') ? '"Programme Location", "Service Type", "Approved Total Project Budget (EUR)" and "Planned Implementation End Date" mandatory for "Partnership Agreement Signed" status.' : 
                                                        (recordTypeName == 'Emergency_Response' && (prsUpdated.Actual_Implementation_Start_Date__c == null && prsUpdated.ampi__Project_Status__c == 'In Implementation')) ? '"Actual Implementation Start Date" mandatory for "In Implementation" status.' : 
                                                        (recordTypeName == 'Emergency_Response' && (prsUpdated.Actual_Implementation_End_Date__c == null && prsUpdated.ampi__Project_Status__c == 'Project Closed')) ? '"Actual Implementation End Date" mandatory for "Project Closed" status.' : '');
    
                    //String GrantExtraValidation = ((recordTypeName == 'Grant' && (prsUpdated.Actual_Indirect_Beneficiaries__c == null && prsUpdated.ampi__Project_Status__c == 'In Implementation')) ? '"Actual Indirect Beneficiaries" mandatory for "In Implementation" status.' : 
                    //                              (recordTypeName == 'Grant' && (prsUpdated.Planned_Indirect_Beneficiaries__c == null && prsUpdated.Phase__c == 'Closure')) ? '"Planned Indirect Beneficiaries" mandatory for "Closure" Phase.' : '');
                    String constructionRestrictiveChanges = 'Not be possible to change the fields once the Construction project reached the status "in identification"';
                    System.debug('...prsUpdated.Programme_Location__c:' + prsUpdated.Programme_Location__c);
                    System.debug('...prsToCheck.Programme_Location__c:' + prsToCheck.Programme_Location__c);

                        if (prsToCheck.Programme_Location__c <> prsUpdated.Programme_Location__c && 
                            (restrictProjectPhasesAndStatuses.contains(prsUpdated.Phase__c) || 
                             restrictProjectPhasesAndStatuses.contains(prsUpdated.ampi__Project_Status__c))) {
                            String restrictiveChanges = 'Not be possible to change programme Location once the project is in the status "' + prsUpdated.ampi__Project_Status__c + '" and phase "' + prsUpdated.Phase__c + '"';
                            errors += restrictiveChanges;
                        }            

                        if (recordTypeName == 'Construction' && (prsToCheck.ampi__Project_Status__c == 'In Identification' || prsToCheck.Phase__c == 'Implementation' || prsToCheck.Phase__c == 'Closure') && (prsUpdated.Name <> prsToCheck.Name || prsUpdated.Programme_Location__c <> prsToCheck.Programme_Location__c)) {
                            // prsUpdated.addError(constructionRestrictiveChanges);
                            errors += constructionRestrictiveChanges;
                        }
                    

                    if (constructionRestrictive || transitionRestrictive || standardRestrictive || grantRestrictive || humanitarianRestrictive) {
                        String activitiesMessage = existsActivities ? 'Important: There are ' + countActivities + ' activities which do not have service type assigned.' : '';
                        String message = (constructionRestrictive ? 'Mandatory fields missing before moving to Project Status "In Identification" or "Closure" or phase "Formulation", "Implementation" or "Closure": ​Name, Programme Location, Planned Implementation Start Date.' + activitiesMessage : 
                                          (transitionRestrictive ? 'Mandatory fields missing before moving to Project Status "In Implementation" or phase "Implementation" or "Closure": ​Name, Programme Location, Planned Implementation Start Date, Transition Project Type.' + activitiesMessage: 
                                          (standardRestrictive ? 'Mandatory fields missing before moving to Project Status "Funding Approved", "In Implementation" or phase "Implementation" or "Closure": ​Name, Programme Location, Planned Implementation Start Date, Funding Organisation.' + activitiesMessage : 
                                          (grantRestrictive ? 'Mandatory fields missing before moving to Project Status "Application Approved", "In Implementation" or phase "Implementation" or "Closure": ​Name, Contract Eligibility Start Date, SOS Lead Organisation.' + activitiesMessage : 
                                          (humanitarianRestrictive ? 'Mandatory fields missing before moving to Project Status "Plan submitted" or phase "Plan Submitted" or "Implementation": ​Name, Programme Location, Planned Implementation Start Date.' + activitiesMessage : '')))));
                        System.debug('###message:' + message);
                        // prsUpdated.addError(message);
                        errors += message;
                    }  

                    if (humanitarianExtraValidation <> '') {
                        prsUpdated.addError(humanitarianExtraValidation);
                        errors += humanitarianExtraValidation;
                    }

                    // TODO: Commented because of the merge from UAT to agreement
                    if (standardAggreementRestrictive) {
                        errors += 'Not possible to change "Funding Approved" project status if the agreement is not in "Aggreement signed" status.';                        
                    }

                    if (errors <> '') {
                        System.debug('...errors:' + errors);
                        prsUpdated.addError(errors);
                        return;
                    }
    }
    
    private void beforeUpdateDeleteProgrammeLocationPGA(ampi__Project__c prsToCheck, ampi__Project__c prsUpdated) {
        System.debug('####enter beforeUpdateDeleteProgrammeLocationPGA:' + prsToCheck);
        System.debug('####enter beforeUpdateDeleteProgrammeLocationPGA new:' + prsUpdated);
        //Map<ID,Schema.RecordTypeInfo> rt_Map = ampi__project__c.sObjectType.getDescribe().getRecordTypeInfosById();
        List<D365_Project_Stand_in__c> psi = new List<D365_Project_Stand_in__c>();
            
            boolean exists = false;
                    
                 if (prsToCheck.Programme_Location__c <> prsUpdated.Programme_Location__c) {
                    /*List<ampi__result__c> results = [SELECT Id FROM ampi__result__c WHERE ampi__Geographical_Area__c =: prsToCheck.Programme_Location__c AND ampi__Project_Indicator__r.ampi__Project__c  =: prsToCheck.Id AND (ampi__Target_Value__c <> NULL OR ampi__Result_Value__c <> NULL)];
                    
                    if (results.size() > 0) {
                    }*/
                     
                    List<ampi__project_geographic_area__c> pgas = [SELECT Id, ampi__Active__c FROM ampi__project_geographic_area__c WHERE ampi__Geographic_Area__c =: prsToCheck.Programme_Location__c AND ampi__Project__c =: prsToCheck.Id];
                    for (ampi__project_geographic_area__c pga : pgas) {
                        pga.ampi__Active__c = false;
                    }
                    UPDATE pgas;
                            
                    List<D365_Project_Stand_in__c> psiToRemove = [SELECT Id, unique_field__c FROM D365_Project_Stand_in__c WHERE Project_Programme_Location__c =: prsToCheck.Programme_Location__c AND Project__c =: prsToCheck.Id];
                    for(D365_Project_Stand_in__c currentPsi : psiToRemove) {
                        currentPsi.unique_field__c = 'TBR';
                    	psi.add(currentPsi);     
                    }                    
                 }
        
        if (psi.size() > 0) {
            try {
          		UPDATE psi;   
                System.debug('###beforeUpdateDeleteProgrammeLocationPGA success: ' + psi.size());
            } catch(Exception ex) {
                System.debug('###beforeUpdateDeleteProgrammeLocationPGA error: ' + ex.getMessage());
            }
        }  
    }
    
    private void afterUpdateInFormulationCreateMonitoringPeriodsForProjects(ampi__project__c acc, ampi__project__c  newProject) {
    	if (acc.Phase__c == 'Formulation' && acc.Phase__c == newProject.Phase__c) {
             ExtraCreateObjects.createMonitoringPeriodByProjectAndMonth(acc.Id);
        }
    }
}