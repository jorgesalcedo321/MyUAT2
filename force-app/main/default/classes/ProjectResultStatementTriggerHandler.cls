public class ProjectResultStatementTriggerHandler {
    public void beforeInsertSetShortDescription(List<ampi__Objective__c> newProjectResultStatement) {
           Set<Id> newPus = new Set<Id>();           
           for (ampi__Objective__c obj : newProjectResultStatement) {
               if (obj.ampi__description__c <> null) {
                    String text = obj.ampi__description__c.length() >= 255 ? obj.ampi__description__c.substring(0, 255) : obj.ampi__description__c;
                    obj.description_short__c = text;
                }
            } 
    }   
    
    public void beforeUpdateSetShortDescription(List<ampi__Objective__c> oldProjectResultStatement, List<ampi__Objective__c> newProjectResultStatement) {
        system.debug('####enter beforeUpdateSetShortDescription shouldBeUpdated');
        // Boolean shouldBeUpdated = false;
        for (ampi__Objective__c prsToCheck : oldProjectResultStatement) { 
            ampi__Objective__c objectiveToUpdate;
            for (ampi__Objective__c prsUpdated : newProjectResultStatement) {
                if (prsToCheck.Id == prsUpdated.Id) {
                    objectiveToUpdate = prsUpdated;
                }
            }
            
            if (objectiveToUpdate.ampi__description__c <> null && objectiveToUpdate.ampi__description__c != prsToCheck.ampi__description__c) {
                    String text = objectiveToUpdate.ampi__description__c.length() >= 255 ? objectiveToUpdate.ampi__description__c.substring(0, 255) : objectiveToUpdate.ampi__description__c;
                    objectiveToUpdate.description_short__c = text;
                    // shouldBeUpdated = true;
                    system.debug('####beforeUpdateSetShortDescription shouldBeUpdated');
            }
        }

        // if (shouldBeUpdated == true) {
        //     UPDATE newProjectResultStatement;
        // }
    }

    public void beforeUpdateRestriction(List<ampi__Objective__c> oldProjectResultStatement, List<ampi__Objective__c> newProjectResultStatement) {
        Set<Id> projectIds = new Set<Id>();
        for (ampi__Objective__c prsToCheck : oldProjectResultStatement) { 
             if (prsToCheck.ampi__Project__c != NULL && !projectIds.contains(prsToCheck.ampi__Project__c)) {
                    projectIds.add(prsToCheck.ampi__Project__c);
             }
        }

        System.debug('#queries-beforeUpdateRestriction 1:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
    
        List<ampi__Project__c> projects = [SELECT Id, Phase__c, ampi__Project_Status__c FROM ampi__Project__c 
                                           WHERE Id IN : projectIds AND RecordType.Name = 'Standard' AND 
                                           (Phase__c = 'Implementation' OR Phase__c = 'Closure' OR ampi__Project_Status__c = 'Funding approved')];
 

        System.debug('#queries-beforeUpdateRestriction 2:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());

        for (ampi__Objective__c prsToCheck : oldProjectResultStatement) { 
             if (prsToCheck.ampi__Project__c != NULL) {
                //ampi__Project__c currentProject = [SELECT Id, Phase__c, ampi__Project_Status__c, RecordType.Name FROM ampi__Project__c WHERE ID =: prsToCheck.ampi__Project__c LIMIT 1];
                if (prsToCheck.ampi__Project__c != NULL) {                      
                       ampi__Project__c currentProject = null;
                       for (ampi__Project__c project : projects) {
                            if (project.Id == prsToCheck.ampi__Project__c) {
                                currentProject = project;
                            }
                        } 

                        if (currentProject != null) {
                            for (ampi__Objective__c prsUpdated : newProjectResultStatement) {
                                if (prsUpdated.Id == prsToCheck.Id  && prsUpdated.ampi__Parent_Project_Objective__c != prsToCheck.ampi__Parent_Project_Objective__c) {
                                        prsUpdated.addError('Cannot update Related Project Result Statement fields from the Project Result Statement if the project is in "' +currentProject.Phase__c + '" phase and "' + currentProject.ampi__Project_Status__c + '" status');
                                }
                            }
                        }
                }
             }
        }
    }

    public void beforeDeleteRestrictionPRSAccordingToProjectData(List<ampi__Objective__c> oldProjectResultStatement) {
        for (ampi__Objective__c prsToCheck : oldProjectResultStatement) { 
             if (prsToCheck.ampi__Project__c != NULL) {
                ampi__Project__c currentProject = [SELECT Id, Phase__c, ampi__Project_Status__c, RecordType.Name FROM ampi__Project__c WHERE ID =: prsToCheck.ampi__Project__c LIMIT 1];
                
                if (prsToCheck.ampi__Project__c != NULL && 
                        (currentProject.RecordType.Name == 'Standard' && 
                        (currentProject.Phase__c == 'Implementation' || 
                        currentProject.Phase__c == 'Closure' || 
                        currentProject.ampi__Project_Status__c == 'Funding approved'))) {                      
                            prsToCheck.addError('Cannot delete Project Result Statement if the project is in "' +currentProject.Phase__c + '" phase and "' + currentProject.ampi__Project_Status__c + '" status');                            
                }
             }
        }
    }
}