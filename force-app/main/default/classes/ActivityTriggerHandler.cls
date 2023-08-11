public class ActivityTriggerHandler {
    public void manageAfterInsertActivities(List<ampi__Activity__c> newActivities) {
        Set<Id> projIds = new Set<Id>();

        for (ampi__Activity__c newActivity : newActivities) {
            if (newActivity.Project__c != null && !projIds.contains(newActivity.Project__c)) {
                projIds.add(newActivity.Project__c);
            }
        }
        
        List<ampi__Project__c> projectRelatedToActivities = [SELECT Id, Name, RecordType.Name FROM ampi__Project__c WHERE Id IN : projIds];
		String projectId = null;   
        
        for(ampi__Activity__c newActivity : newActivities) {
            ampi__Project__c currentProject = null;
			Boolean changeProject = false;
            
            for (ampi__Project__c projectRelatedToActivity : projectRelatedToActivities) {
                if (newActivity.Project__c == projectRelatedToActivity.Id) {
                    currentProject = projectRelatedToActivity;
                }
            }
			
            if (currentProject != null) {
                if (projectId != newActivity.Project__c) {
                    projectId = newActivity.Project__c;
                    changeProject = true;
                }
                afterInsertActivitiesCreateBudgetAndFinancials(newActivity, currentProject, changeProject);
            }
        }
    }

    public void manageBeforeInsertActivities(List<ampi__Activity__c> newActivities) {
        Set<Id> projIds = new Set<Id>();

        for (ampi__Activity__c newActivity : newActivities) {
            if (newActivity.Project__c != null && !projIds.contains(newActivity.Project__c)) {
                projIds.add(newActivity.Project__c);
            }
        }
        
        List<ampi__activity__c> activitiesSameActivityId = [SELECT project__c, Name, Unique_Name__c FROM ampi__activity__c WHERE project__c IN : projIds];
        
		for (ampi__Activity__c newActivity : newActivities) {
            beforeInsertCheckActivitiesDuplicatedByUniqueNameAndProjectId(newActivity, activitiesSameActivityId);
            /*if (taskUpdated.Person_Responsible__c <> '') {
                String[] probableUser = taskUpdated.Person_Responsible__c.split(' ', 2);

                if (probableUser.size() == 2) {
                    List<User> userDetected = [SELECT Id FROM User WHERE Firstname =: probableUser[0] AND LastName =: probableUser[1]];
                    if (userDetected.size() > 0) {
                        taskUpdated.Person_Responsible_Link = userDetected[0].Id;
                    }
                }

                if (taskUpdated.Person_Responsible_Link == NULL) {
                    taskUpdated.addError('Person Responsible must contains firstname and lastname from the user to receive notifications');
                }
            }*/
        }    
    }

    public void manageBeforeUpdateActivities(List<ampi__Activity__c> oldActivities, List<ampi__Activity__c> newActivities) {
	 	Boolean hasCustomPermission = FeatureManagement.checkPermission('Manage_Restrictions');

        if (hasCustomPermission)
            return;
        
        Set<Id> projIds = new Set<Id>();
        for (ampi__Activity__c taskToCheck : oldActivities) {
            if (taskToCheck.Project__c != NULL && !projIds.contains(taskToCheck.Project__c)){
                projIds.add(taskToCheck.Project__c);
            }            
        }
        
        for (ampi__Activity__c taskToUpdate : newActivities) {
            if (taskToUpdate.Project__c != NULL && !projIds.contains(taskToUpdate.Project__c)){
                projIds.add(taskToUpdate.Project__c);
            }            
        }
        
        List<ampi__Project__c> projects = [SELECT Id, RecordType.Name, Phase__c, ampi__Project_Status__c, Name, Programme_Location__c, Planned_Implementation_Start_Date__c, Funding_organisation__c, Applicant_Accountable_Organisation__c, Contract_Eligibility_Start_Date__c, Transition_Project_Type__c FROM ampi__Project__c WHERE Id IN : projIds];
        
        for (ampi__Activity__c taskToCheck : oldActivities) { 
            //TO BE IMPLEMENTED
            // Activity relation with Project is by the Project__c or ampi__Implementation_Plan__r.ampi__Project__c
             
                Id currentProjectId = taskToCheck.Project__c;
            
                ampi__Project__c currentProject = null;
                for (ampi__Activity__c taskUpdated : newActivities) {
                    if (taskUpdated.Id == taskToCheck.Id) {
                        if (taskUpdated.Project__c == NULL) {
                            taskUpdated.addError('Cannot update the activity if the Project relation is not set');
                            return;
                        } else {
                            currentProjectId = taskUpdated.Project__c;
                        }
                    }
                }

                if (currentProjectId != NULL) {
                    for (ampi__Project__c proj : projects) {
                        if (proj.Id == currentProjectId) {
                            currentProject = proj;
                        }
                    }
                } 
            
            	if (currentProject == NULL) {
                    return;
                }
                    
                Set<String> restrictProjectPhasesAndStatuses = new Set<String> { 'In Implementation', 'Implementation', 'Closure', 'In Construction', 'Funding Approved', 'Plan Submitted', 'Application Approved', 'Partnership Agreement Signed'};
                Set<String> restrictActivityStatuses = new Set<String> { 'Planning', 'In Progress', 'Complete', 'Cancelled/NA'};
                
				ampi__Activity__c updateActivity = null;                    
				for (ampi__Activity__c taskUpdated : newActivities) {
                    if (taskUpdated.Id == taskToCheck.Id) {
                        updateActivity = taskUpdated;
                    }
                }                        

                beforeUpdateActivityRestrictionByParentActivityFromSameType(taskToCheck, updateActivity);
            	beforeUpdateActivityRestrictionByProjectStatus(taskToCheck, updateActivity, currentProject, restrictProjectPhasesAndStatuses, restrictActivityStatuses);
            	beforeUpdateActivityProjectResultStatement(taskToCheck, updateActivity);
            	beforeUpdateActivityImplementationPlan(taskToCheck, updateActivity);                        
            	beforeUpdateCheckActivityDuplicity(taskToCheck, updateActivity);                                    	
            	beforeUpdateProjectFromActivity(taskToCheck, updateActivity);                                    	
                beforeUpdateOverarchingActivityTypeRestrictions(taskToCheck, updateActivity);                                    	
            	beforeUpdateResultsBasedActivityTypeRestrictions(taskToCheck, updateActivity);                                    	
            	beforeUpdateActivityProjectRecordType(taskToCheck, updateActivity, currentProject); 
        }
    }

    public void manageBeforeDeleteActivities(List<ampi__Activity__c> oldActivities) {
		Boolean hasCustomPermission = FeatureManagement.checkPermission('Manage_Restrictions');

        if (hasCustomPermission)
            return;
        
        set<String> notValidProjectActivityStatus = new set<String> {'Funding approved', 'Plan submitted', 'Planning', 'In Progress', 'Complete'};
        set<String> notValidPhase = new set<String> {'Implementation', 'Closure', 'In Construction'};
        set<String> nextProjectStatusesAfterFundingApproved = new set<String> {'New','In Identification','Idea Submitted','Idea in Pipeline','Interest to Fund','Cancelled','Needs Assessment Started,','Needs Assessment Submitted','Principle GO','In Formulation','HA Submitted','Formal GO','Commit Funding','Plan Submitted','Concept in Formulation','Concept Submitted','Concept in Pipeline','Concept Rejected'};
            
		set<Id> projectIds = new set<Id>();
        for (ampi__Activity__c taskToCheck : oldActivities) { 
            if (taskToCheck.Project__c != null && !projectIds.contains(taskToCheck.Project__c)) {
                 	projectIds.add(taskToCheck.Project__c);   
            }
        }                        
        
		List<ampi__Project__c> currentProjects = [SELECT Id, Phase__c, ampi__Project_Status__c, Owner.Id FROM ampi__Project__c WHERE ID =: projectIds];
        
        for (ampi__Activity__c taskToCheck : oldActivities) { 
             if (taskToCheck.Project__c != NULL) {
                ampi__Project__c currentProject = null;
                
                for (ampi__Project__c project : currentProjects) {
                    if (taskToCheck.Project__c == project.Id) {
                     	currentProject = project;   
                    }                     
                }
                
                 if (taskToCheck.ampi__status__c != 'New') {
                    beforeDeleteTaskActivitiesForProjectPhaseAndStatusAndActivityStatus(taskToCheck, currentProject, notValidPhase, notValidProjectActivityStatus);                 
                    beforeDeleteActivityProjectByStatusAfterFundingApproved(taskToCheck, currentProject, nextProjectStatusesAfterFundingApproved);
                    beforeDeleteActivityNotProjectOwner(taskToCheck, currentProject);
                    beforeDeleteActivityNotNew(taskToCheck, currentProject);
                 }
             }
        }
    }
    
    private void beforeDeleteActivityNotProjectOwner(ampi__activity__c taskToCheck, ampi__project__c currentProject) {
        System.debug('####enter beforeDeleteRestrictionDeletionByProjectOwner trigger');
        String userId = UserInfo.getUserId();
            
        if (UserInfo.getUserId() != currentProject.Owner.Id) {
            	system.debug('###error deleting');
                taskToCheck.addError('Cannot delete this activity because you are not the project owner');
    	}                                    
	}
    
    private void beforeDeleteActivityNotNew(ampi__activity__c taskToCheck, ampi__project__c currentProject) {
        System.debug('####enter beforeDeleteActivityNotNew trigger');            
		if (taskToCheck.ampi__status__c != 'New') {
        	system.debug('###error deleting');
            taskToCheck.addError('Cannot delete this activity because the activity status is not "New"');
        }                                    
	}
    
    private void beforeDeleteActivityProjectByStatusAfterFundingApproved(ampi__activity__c taskToCheck, ampi__project__c currentProject, set<String> nextProjectStatusesAfterFundingApproved) {
        System.debug('####enter beforeDeleteActivityProjectStatus trigger');
            
        if (!nextProjectStatusesAfterFundingApproved.contains(currentProject.ampi__Project_Status__c)) {
           system.debug('###error deleting');
           taskToCheck.addError('Cannot delete this activity because the project status is after "Funding Approved"');
    	}                                    
	}
    
    private void beforeDeleteTaskActivitiesForProjectPhaseAndStatusAndActivityStatus(ampi__activity__c taskToCheck, ampi__project__c currentProject, set<String> notValidPhase, set<String> notValidProjectActivityStatus) {
        if(taskToCheck.ampi__status__c != null && taskToCheck.ampi__xx_Activity_Type__c == 'Task') {
            if (taskToCheck.Project__c != NULL && 
                            ((notValidPhase.contains(currentProject.Phase__c) || 
                            notValidProjectActivityStatus.contains(currentProject.ampi__Project_Status__c)) &&
                            (notValidProjectActivityStatus.contains(taskToCheck.ampi__status__c)))) {
                            system.debug('###error deleting');
                            taskToCheck.addError('Cannot delete this activity because is in status "' + taskToCheck.ampi__status__c + '" and the project is in ' + currentProject.Phase__c + ' phase and "' + currentProject.ampi__Project_Status__c + '" status');
        	}
		}
    }

    private void afterInsertActivitiesCreateBudgetAndFinancials(ampi__activity__c newActivity, ampi__project__c currentProject, Boolean changeProject) {
            if (currentProject.RecordType.Name == 'Standard' || currentProject.RecordType.Name == 'Emergency_Response') {
                ampi__reporting_period__c reportingPeriod = CreateObjects.manageMonitoringPeriodByProject(currentProject.Id, 1);
                String reportingPeriodId = reportingPeriod.Id;
                if (newActivity.ampi__Type__c == 'Results-Based' || newActivity.ampi__Type__c == 'Overarching') {
                        if (changeProject) {
                            reportingPeriod = CreateObjects.manageMonitoringPeriodByProject(newActivity.Project__c, 1);
                            reportingPeriodId = reportingPeriod.Id;
                        }   
                        
                        String categoryId = (newActivity.ampi__Type__c == 'Results-Based' ? 'Result based' : 'Overarching');
                        ampi__Budget__c newBudget = CreateObjects.createBudget(currentProject.Name + ' Budget', newActivity.Name, currentProject.Id, false);
                        ampi__Financial__c newFinancial = CreateObjects.createFinancialRelatedToActivity(currentProject.Name, newActivity.Id, categoryId, newBudget.Id, reportingPeriodId, 'Expenditure', false);
                }
            }
    }
    
    private void beforeInsertCheckActivitiesDuplicatedByUniqueNameAndProjectId(ampi__activity__c newActivity, List<ampi__activity__c> activitiesSameProject) {
        for(ampi__activity__c act : activitiesSameProject) {
            if (newActivity.project__c == act.project__c) {
                if (newActivity.Unique_Name__c == act.Unique_Name__c) {                    
                    // System.debug('#### beforeUpdateCheckActivityDuplicity 1 : ' + newActivity.Order_ID__c);
                    // System.debug('#### beforeUpdateCheckActivityDuplicity 1 : ' + newActivity.Unique_Name__c);
                    // System.debug('#### beforeUpdateCheckActivityDuplicity 1 : ' + newActivity.ampi__Type__c);                    
            		newActivity.addError('Duplicate Activity ID field with the activity name:"' + act.Name + '"');        
                }        
            }
        }
    }

    private void beforeUpdateActivityRestrictionByParentActivityFromSameType(ampi__Activity__c taskToCheck, ampi__Activity__c updateActivity) {
        if (updateActivity.ampi__Project_Objective__c != taskToCheck.ampi__Project_Objective__c) {  //TOBE: AMIMSP-1949
            beforeInsertActivityRestrictionByParentActivityFromSameType(updateActivity);            
        }
    }

    private void beforeInsertActivityRestrictionByParentActivityFromSameType(ampi__Activity__c updateActivity) {
            String activityType = updateActivity.ampi__Type__c;
            String currentParentActivity = updateActivity.ampi__Parent_Activity__c;

            if (currentParentActivity <> NULL && currentParentActivity <> '') {
                Integer existsByConditions = [SELECT Count() FROM ampi__activity__c WHERE Id =: currentParentActivity AND project__c =: updateActivity.project__c AND ampi__Type__c =: activityType AND ampi__Parent_Activity__c = NULL];

                if (existsByConditions == 0) {
                    updateActivity.addError('Cannot update Parent Activity from different activity type than ' + activityType);
                    return;
                }
            }
    }

    private void beforeUpdateActivityRestrictionByProjectStatus(ampi__Activity__c taskToCheck, ampi__Activity__c updateActivity, ampi__project__c currentProject, Set<String> restrictProjectPhasesAndStatuses, Set<String>restrictActivityStatuses) {
        if ((restrictProjectPhasesAndStatuses.contains(currentProject.Phase__c) || 
			 restrictProjectPhasesAndStatuses.contains(currentProject.ampi__Project_Status__c))) {

			if (updateActivity.ampi__status__c <> 'New' &&
                updateActivity.ampi__Project_Objective__c != taskToCheck.ampi__Project_Objective__c) {  //TOBE: AMIMSP-1949
            	updateActivity.addError('Cannot update Project Result Statement fields from the activity when project is in "' +currentProject.Phase__c + '" phase and "' + currentProject.ampi__Project_Status__c + '" status');
            	return;
           	}

            if (updateActivity.ampi__status__c == 'New' && 
            	updateActivity.ampi__status__c <> taskToCheck.ampi__status__c && 
                (restrictActivityStatuses.contains(taskToCheck.ampi__status__c))) {
                	updateActivity.addError('Cannot update Activity Status to "New" when the status activity is "Planning", "In Progress", "Complete" or "Cancelled/NA" and project status is "' + currentProject.ampi__Project_Status__c + '" or phase "' + currentProject.Phase__c + '".');
                    return;
			}
        
            beforeUpdateTaskActivityTypeRestrictions(taskToCheck, updateActivity, restrictActivityStatuses, currentProject);        	               
        }
    }

	private void beforeUpdateActivityProjectResultStatement(ampi__Activity__c taskToCheck, ampi__Activity__c updateActivity) {
                        if (taskToCheck.ampi__Project_Objective__c <> updateActivity.ampi__Project_Objective__c && updateActivity.ampi__Project_Objective__c <> null) {
                            for (ampi__Objective__c obj : [SELECT Id, ampi__Level__c, ampi__project__c from ampi__Objective__c WHERE Id =: updateActivity.ampi__Project_Objective__c AND (ampi__Level__c !=: 'Output' OR ampi__project__c !=: updateActivity.project__c)]) {
                                //if (obj.Id == taskUpdated.ampi__Project_Objective__c) {
                                //    System.debug('####taskUpdated notOutput ampi__Level__c:' + obj.ampi__Level__c);
                                //    if (obj.ampi__Level__c <> 'Output') {
                                        updateActivity.addError('Cannot update Project Result Statement from level different to "output" and Project Result Statement must be from the same project than the activity');
                                        return;
                                //    }
    
                                //    if (taskUpdated.project__c <> obj.ampi__project__c) {
                                //        taskUpdated.addError('Project Result Statement must be from the same project than the activity');
                                //    }
                                //}
                            }
                        }
	}

	private void beforeUpdateCheckActivityDuplicity(ampi__activity__c taskToCheck, ampi__activity__c updateActivity) {		
                        if (updateActivity.Activity_ID__c != taskToCheck.Activity_ID__c && updateActivity.Activity_ID__c != '') {
                            try {
                                Integer activitYNumberId = Integer.valueOf(updateActivity.Activity_ID__c);
                                Boolean duplicateActivity = false;
                                String ActivityName = '';
                                
                                //List<ampi__activity__c> activitiesSameActivityId = [SELECT Id, Name, Unique_Name__c, project__c FROM ampi__activity__c WHERE project__c =: taskUpdated.Project__c AND Id <>: taskUpdated.Id && Unique_Name__c =: taskUpdated.Unique_Name__c];		
								System.debug('#### beforeUpdateCheckActivityDuplicity 1 : ' + updateActivity.Unique_Name__c);
                                for (ampi__activity__c currentActivity : [SELECT Id, Name, Unique_Name__c, project__c FROM ampi__activity__c WHERE project__c =: updateActivity.Project__c AND Id !=: updateActivity.Id AND Unique_Name__c =: updateActivity.Unique_Name__c]) {
                                    //if (currentActivity.project__c == taskUpdated.Project__c) {
                                    //    if (currentActivity.Id <> taskUpdated.Id && currentActivity.Unique_Name__c == taskUpdated.Unique_Name__c) {
                                    duplicateActivity = true;
                                    ActivityName = currentActivity.Name;
                                    //    }
                                    //}
                                }
                                if (duplicateActivity == true) {
                                    updateActivity.addError('Duplicate Activity ID field with the activity name:"' + ActivityName + '"');
                                    return;
                                }

                                if (activitYNumberId > 9999 || activitYNumberId < 1) {
                                    updateActivity.addError('Activity ID must have between 1 o 4 digits');
                                    return;
                                }

                            } catch (Exception ex) {
                                updateActivity.addError('Cannot update Activity ID field from the activity. Must be numeric integer or empty');
                                return;
                            }                                        
                        }
	}
                 
	private void beforeUpdateActivityImplementationPlan(ampi__Activity__c taskToCheck, ampi__Activity__c updateActivity) {
                        //for (ampi__Implementation_Plan__c obj : iplan) {
                        if (taskToCheck.ampi__Implementation_Plan__c <> updateActivity.ampi__Implementation_Plan__c && updateActivity.ampi__Implementation_Plan__c <> null) {
                            for (ampi__Implementation_Plan__c obj : [SELECT Id, ampi__project__c from ampi__Implementation_Plan__c WHERE Id =: updateActivity.ampi__Implementation_Plan__c AND ampi__project__c !=: updateActivity.Project__c]) {
                                //if (obj.Id == taskUpdated.ampi__Implementation_Plan__c) {
                                //    if (obj.ampi__project__c <> taskUpdated.Project__c) {
                                        updateActivity.addError('Project field cannot be saved with value different than Project from Activity Schedule');
                                        return;
                                //    }
                                //}
                            }        
                        }
	}

	private void beforeUpdateOverarchingActivityTypeRestrictions(ampi__activity__c taskToCheck, ampi__activity__c updateActivity) {
        if (taskToCheck.ampi__Type__c == 'Overarching' && 
            (updateActivity.Activity_ID__c != taskToCheck.Activity_ID__c || 
             updateActivity.ampi__Type__c != taskToCheck.ampi__Type__c || 
             (taskToCheck.Thematic_Area__c <> null && updateActivity.Thematic_Area__c <> null && 
              updateActivity.Thematic_Area__c != taskToCheck.Thematic_Area__c))) {  //TOBE: AMIMSP-2055
              	System.debug('####updateActivity Overarching:' + updateActivity);
                updateActivity.addError('Cannot update Overarching Activity ID, Project Result Statement, Activity Type or Thematic Area fields from the activity');
                return;
		}
	}

	private void beforeUpdateTaskActivityTypeRestrictions(ampi__activity__c taskToCheck, ampi__activity__c updateActivity, Set<String> restrictActivityStatuses, ampi__project__c currentProject) {
        if(taskToCheck.ampi__status__c != null && taskToCheck.ampi__xx_Activity_Type__c == 'Task') {
                if (restrictActivityStatuses.contains(taskToCheck.ampi__status__c)) {
                    System.debug('####taskUpdated:' + updateActivity);
                    if (updateActivity.ampi__status__c <> 'New' && 
                        (updateActivity.ampi__Project_Objective__c != taskToCheck.ampi__Project_Objective__c || 
                        updateActivity.ampi__Type__c != taskToCheck.ampi__Type__c || 
                        updateActivity.Activity_ID__c != taskToCheck.Activity_ID__c ||
                        updateActivity.Thematic_Area__c != taskToCheck.Thematic_Area__c)) {
                            updateActivity.addError('Cannot update Activity ID, Project Result Statement, Activity Type or Thematic Area fields from the activity with status "' + taskToCheck.ampi__status__c + '" and the project is in "' +currentProject.Phase__c + '" phase and "' + currentProject.ampi__Project_Status__c + '" status');
                            return;
            		}  
				}  
		}  
	}

	private void beforeUpdateProjectFromActivity(ampi__activity__c taskToCheck,ampi__activity__c  updateActivity) {
                        if (taskToCheck.Project__c != null && updateActivity.Project__c != taskToCheck.Project__c) {
                            User currentUser = [SELECT Profile.Name FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
                            
                            if (currentUser.Profile.Name <> 'System Administrator') {
                                updateActivity.addError('Cannot update Project from the activity');
                                return;
                            }                            
                        }
	}

	private void beforeUpdateResultsBasedActivityTypeRestrictions(ampi__activity__c taskToCheck,ampi__activity__c  updateActivity) {
                        if (updateActivity.ampi__Type__c == 'Results-Based') {
                            if (updateActivity.ampi__Project_Objective__c <> null && updateActivity.ampi__Parent_Activity__c <> null) { //TOBE: AMIMSP-2142
                                updateActivity.addError('Cannot fill both fields "Project Result Statement" and "Parent Activity Activity"');
                                return;
                            }
                            
                            if (updateActivity.Thematic_Area__c <> null && updateActivity.Thematic_Area__c <> taskToCheck.Thematic_Area__c) {  
                                boolean existsPta = false;
                                Set<String> ptaAvailableValues = new Set<String>();
                                //List<ampi__Project_Thematic_Area__c> ptas = [SELECT Id, ampi__project__c, ampi__Thematic_Area__c, ampi__Thematic_Area__r.Name FROM ampi__Project_Thematic_Area__c WHERE ampi__project__c IN : projIds];
                                System.debug('#queries-4act:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
                                for (ampi__Project_Thematic_Area__c pta : [SELECT Id, ampi__Thematic_Area__c, ampi__Thematic_Area__r.Name FROM ampi__Project_Thematic_Area__c WHERE ampi__Project__c =: updateActivity.project__c]) {
                                    //if (pta.ampi__Project__c == taskUpdated.project__c) {
                                    if (pta.ampi__Thematic_Area__c == updateActivity.Thematic_Area__c) {
                                    	existsPta = true;
                                    }
                                    ptaAvailableValues.add(pta.ampi__Thematic_Area__r.Name);    
                                    //}                                    
                                }

                                if (!existsPta) {
                                    if (ptaAvailableValues.size() > 0) {
                                        updateActivity.addError('Cannot select a Service Type that is not related to the project. Please select one Service Type from this list: ' + String.join((Iterable<String>)ptaAvailableValues, ', '));
                                    } else {
                                        updateActivity.addError('Cannot select a Service Type that is not related to the project. Please go to "Setup" and check the "Service Type" value list.');
                                    }
                                }
                            }
                        }
	}

	private void beforeUpdateActivityProjectRecordType(ampi__activity__c taskToCheck,ampi__activity__c  updateActivity, ampi__project__c currentProject) {				
                        //TODO: service types from activities cannot be changed during these statuses or phases for the project
                        if (updateActivity.Thematic_Area__c != taskToCheck.Thematic_Area__c && taskToCheck.ampi__Type__c != 'Overarching') {
                            String recordTypeName = currentProject.RecordType.Name;
                            boolean constructionRestrictive = recordTypeName == 'Construction' && 
                                                                (currentProject.Name == '' || currentProject.Programme_Location__c == null || currentProject.Planned_Implementation_Start_Date__c == null) && 
                                                                (currentProject.ampi__Project_Status__c == 'In Identification' || currentProject.ampi__Project_Status__c == 'Closure' || currentProject.Phase__c == 'Formulation'  || currentProject.Phase__c == 'Implementation' || currentProject.Phase__c == 'Closure');

                            boolean transitionRestrictive = recordTypeName == 'Transition' && 
                                                                (currentProject.Name == '' || currentProject.Programme_Location__c == null || currentProject.Planned_Implementation_Start_Date__c == null || currentProject.Transition_Project_Type__c == null || currentProject.Transition_Project_Type__c == '') && 
                                                                (currentProject.ampi__Project_Status__c == 'In Implementation' || currentProject.Phase__c == 'Implementation' || currentProject.Phase__c == 'Closure');

                            boolean standardRestrictive = recordTypeName == 'Standard' && 
                                                                (currentProject.Name == '' || currentProject.Programme_Location__c == null || currentProject.Planned_Implementation_Start_Date__c == null || currentProject.Funding_organisation__c == null) && 
                                                                (currentProject.ampi__Project_Status__c == 'Funding Approved' || currentProject.ampi__Project_Status__c == 'In Implementation' || currentProject.ampi__Project_Status__c == 'Cancelled' || currentProject.Phase__c == 'Implementation' || currentProject.Phase__c == 'Closure');

                            boolean grantRestrictive = recordTypeName == 'Grant' && 
                                                                (currentProject.Name == '' || currentProject.Contract_Eligibility_Start_Date__c == null || currentProject.Applicant_Accountable_Organisation__c == null) && 
                                                                (currentProject.ampi__Project_Status__c == 'Application Approved' || currentProject.ampi__Project_Status__c == 'Application Rejected' || currentProject.ampi__Project_Status__c == 'In Implementation' || currentProject.ampi__Project_Status__c == 'Cancelled' || currentProject.Phase__c == 'Implementation' || currentProject.Phase__c == 'Closure');

                            boolean humanitarianRestrictive = recordTypeName == 'Emergency_Response' && 
                                                                (currentProject.Name == '' || currentProject.Programme_Location__c == null || currentProject.Planned_Implementation_Start_Date__c == null) && 
                                                                (currentProject.ampi__Project_Status__c == 'Plan submitted' || currentProject.ampi__Project_Status__c == 'In Implementation' || currentProject.Phase__c == 'Implementation' || currentProject.Phase__c == 'Closure');

                            if (constructionRestrictive || transitionRestrictive || standardRestrictive || grantRestrictive || humanitarianRestrictive) {
                                    String message = (constructionRestrictive ? 'The Service type cannot be modified after the "Project Status": "In Construction".' : 
                                                    (transitionRestrictive ? 'The Service type cannot be modified or deleted if the project is in the phase "Implementation" or "Closure".' : 
                                                    (standardRestrictive ? 'The Service type cannot be modified after the "Project Status": "Funding Approved".' : 
                                                    (grantRestrictive ? 'The Service type cannot be modified after the "Project Status": "Application Approved".' : 
                                                    (humanitarianRestrictive ? 'The Service type cannot be modified after the "Project Status": "Plan submitted".' : '')))));
                                    updateActivity.addError(message);
                            } 
                        }
	}
}