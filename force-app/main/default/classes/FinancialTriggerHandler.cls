public class FinancialTriggerHandler {
    public void afterInsertSetOrderPerProject(List<ampi__Financial__c> newFinancials) {
            if (newFinancials.size() == 0) {
                return;
            }
            
            Integer order = 0;
            Integer initialOrderForGrantTransition = 0;
            Integer initialOrderForStandardER = 0;
            Integer standardERCount = 0;
            Integer grantTransitionCount = 0;

            Set<Id> projectIds = new Set<Id>();
            Boolean hasRecordsToUpdate = false; 
            Set<Id> ids = (new Map<Id, ampi__Financial__c>(newFinancials)).keySet();
            
            List<ampi__Financial__c> newFinancialsToUpdate = [SELECT Id, Is_ReadOnly__c, ampi__Activity__c, ampi__Budget__r.Id, Order_Project__c, ampi__Budget__r.ampi__Project__c, ampi__Budget__r.ampi__Project__r.Name, ampi__Budget__r.ampi__Project__r.RecordTypeId FROM ampi__Financial__c WHERE Id =: ids AND ampi__Budget__r.ampi__Project__c != NULL];
            //System.debug('#### newFinancialsToUpdate:' + newFinancialsToUpdate.size());
            if (newFinancialsToUpdate == null || newFinancialsToUpdate.size() == 0) {
                return;
            }
            
            if (newFinancialsToUpdate.size() > 0) {
                for (ampi__Financial__c financialUpdate : newFinancialsToUpdate)
                if (!projectIds.contains(financialUpdate.ampi__Budget__r.ampi__Project__c)) {
                    projectIds.add(financialUpdate.ampi__Budget__r.ampi__Project__c);
                }
            }
            
            //projectName = newFinancialsToUpdate[0].ampi__Budget__r.ampi__Project__r.Name;
            //projectRecordTypeId = newFinancialsToUpdate[0].ampi__Budget__r.ampi__Project__r.RecordTypeId;

            //List<ampi__Financial__c> orderOnFinancialByProject = [SELECT Id, Order_Project__c, ampi__Activity__c FROM ampi__Financial__c WHERE ampi__Budget__r.ampi__Project__c =: projectId AND Order_Project__c <> NULL ORDER BY Order_Project__c DESC LIMIT 1];
            // List<ampi__Financial__c> orderOnFinancialByProject = new List<ampi__Financial__c>();
            // System.debug('####Schema.SObjectType.ampi__project__c.getRecordTypeInfosByName():' + Schema.SObjectType.ampi__project__c.getRecordTypeInfosByDeveloperName());
            // System.debug('####Schema.SObjectType.ampi__project__c.getRecordTypeInfosByName() Standard:' + Schema.SObjectType.ampi__project__c.getRecordTypeInfosByDeveloperName().get('Standard'));
            // System.debug('####Schema.SObjectType.ampi__project__c.getRecordTypeInfosByName() Humanitarian/Emergency_Response:' + Schema.SObjectType.ampi__project__c.getRecordTypeInfosByDeveloperName().get('Emergency_Response'));

            Id standardRecordType = Schema.SObjectType.ampi__project__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
            Id ERRecordType = Schema.SObjectType.ampi__project__c.getRecordTypeInfosByDeveloperName().get('Emergency_Response').getRecordTypeId();
            Id grantRecordType = Schema.SObjectType.ampi__project__c.getRecordTypeInfosByDeveloperName().get('Grant').getRecordTypeId();
            Id constructionRecordType = Schema.SObjectType.ampi__project__c.getRecordTypeInfosByDeveloperName().get('Construction').getRecordTypeId();
            Id transitionRecordType = Schema.SObjectType.ampi__project__c.getRecordTypeInfosByDeveloperName().get('Transition').getRecordTypeId();

            //System.debug('#### orderOnFinancialByProject:' + orderOnFinancialByProject.size());                     
            
            Set<Id> objBudgets = new Set<Id>();
            Set<Id> objFinancialsReadOnly = new Set<Id>();
            //Set<Id> objDisbursements = new Set<Id>();

            List<ampi__Financial__c> financialOrderOnStandardERByProject = [SELECT Id, Order_Project__c, ampi__Activity__r.Project__c
                                                            FROM ampi__Financial__c WHERE 
                                                            (ampi__Activity__r.Project__r.RecordTypeId =: standardRecordType OR ampi__Activity__r.Project__r.RecordTypeId =: ERRecordType) AND
                                                            ampi__Activity__r.Project__c IN : projectIds AND 
                                                            ampi__Activity__r.ampi__Type__c IN ('Results-Based', 'Overarching') AND
                                                            Order_Project__c <> NULL AND
                                                            ampi__Type__c = 'Expenditure' ORDER BY Order_Project__c DESC];

            System.debug('###financialOrderOnStandardERByProject:' + financialOrderOnStandardERByProject);
            List<ampi__Financial__c> financialOrderGrantTransitionByProject = [SELECT Id, Order_Project__c, ampi__Budget__r.ampi__Project__c
                                                            FROM ampi__Financial__c WHERE 
                                                            ampi__Budget__r.ampi__Project__c IN : projectIds AND 
                                                            Order_Project__c <> NULL
                                                            ORDER BY Order_Project__c DESC];
			
        	System.debug('###financialOrderGrantTransitionByProject:' + financialOrderGrantTransitionByProject);            
            for(ampi__Financial__c newFinancial : newFinancialsToUpdate) {    
                    if (newFinancial.Is_ReadOnly__c) {
                        newFinancial.Is_ReadOnly__c = false;
                        objFinancialsReadOnly.add(newFinancial.Id);
                    }

                    Id projectId = newFinancial.ampi__Budget__r.ampi__Project__c;      
                    String projectName = newFinancial.ampi__Budget__r.ampi__Project__r.Name;  
                    Id projectRecordTypeId = newFinancial.ampi__Budget__r.ampi__Project__r.RecordTypeId;

                    //System.debug('#### projectRecordTypeId:' + projectRecordTypeId);
                    //System.debug('#### projectId:' + projectId);
                    //System.debug('#### projectName:' + projectName);

                    if (projectId != NULL) {
                        for (ampi__Financial__c fin : financialOrderOnStandardERByProject) {
                            if (fin.ampi__Activity__r != NULL && fin.ampi__Activity__r.Project__c == projectId && initialOrderForStandardER == 0) {
                                initialOrderForStandardER = Integer.ValueOf(fin.Order_Project__c);
                            }    
                        }    
                        
                        for (ampi__Financial__c fin : financialOrderGrantTransitionByProject) {
                            if (fin.ampi__Budget__r != NULL && fin.ampi__Budget__r.ampi__Project__c == projectId && initialOrderForGrantTransition == 0) {
                                initialOrderForGrantTransition = Integer.ValueOf(fin.Order_Project__c);
                            }    
                        }                        
                                    
                        boolean found = false;
                        if (projectRecordTypeId == standardRecordType || projectRecordTypeId == ERRecordType || projectRecordTypeId == constructionRecordType) {
                            if (newFinancial.ampi__Activity__c != NULL) {
                                //System.debug('####orderOnFinancialByProject Standard/ER:' + orderOnFinancialByProject.size());
                                found = true;
                                standardERCount += 1;
                                order = initialOrderForStandardER + standardERCount;
                            }
                        }

                        if (projectRecordTypeId == grantRecordType || projectRecordTypeId == transitionRecordType || 
                            (projectRecordTypeId == standardRecordType && newFinancial.ampi__Activity__c == NULL) ||
                            (projectRecordTypeId == ERRecordType && newFinancial.ampi__Activity__c == NULL)) {
                            found = true;
                            grantTransitionCount += 1;                            
                            order = initialOrderForGrantTransition + grantTransitionCount;
                            //System.debug('####orderOnFinancialByProject Grant/Transition:' + orderOnFinancialByProject.size());
                        }

                        if (found == false) {
                            order = order + 1;
                        }
                    } else {
                        order = order + 1;
                    }            
                    System.debug('#### new order: ' + order);  

                    if (newFinancial.Order_Project__c != order) {
                        hasRecordsToUpdate = true;                
                        newFinancial.Order_Project__c = order;                    
                    }  
                    
                    objBudgets.add(newFinancial.ampi__Budget__r.Id);
                    //objDisbursements.add(newFinancial.ampi__Disbursement__r.Id);
            }
            System.debug('####hasRecordsToUpdate 1:' + hasRecordsToUpdate);
            if (hasRecordsToUpdate) {
                UPDATE newFinancialsToUpdate;
                System.debug('####objFinancialsReadOnly.size() 2:' + objFinancialsReadOnly.size());
                if(objFinancialsReadOnly.size() > 0) {
                    newFinancialsToUpdate = [SELECT Id, Is_ReadOnly__c FROM ampi__Financial__c WHERE Id IN: objFinancialsReadOnly];
                    for(ampi__Financial__c newFinancial : newFinancialsToUpdate) {    
                        newFinancial.Is_ReadOnly__c = true;
                        System.debug('####newFinancial 3:' + newFinancial.Is_ReadOnly__c);
                    }
                    UPDATE newFinancialsToUpdate;
                }

                List<ampi__budget__c> updateBudgets = [SELECT Id, Order_Financial__c FROM ampi__budget__c WHERE Id IN: objBudgets];

                if (updateBudgets.size() > 0) {
                    Boolean hasChangesToUpdate = false;
                    for(ampi__budget__c updateBudget : updateBudgets) {
                        if (updateBudget.Order_Financial__c != (order + '')) {
                            updateBudget.Order_Financial__c = order + '';
                            hasChangesToUpdate = true;
                        }
                        
                    }
                    if (hasChangesToUpdate == true) {
                        UPDATE updateBudgets;
                    }
                }

                /*List<ampi__disbursement__c> updateDisbursements = [SELECT Id, Order_Financial__c FROM ampi__disbursement__c WHERE Id IN: objDisbursements];

                IF (updateDisbursements.size() > 0) {
                    for(ampi__disbursement__c updateDisbursement : updateDisbursements) {
                        updateDisbursement.Order_Financial__c = order + '';
                    }

                    UPDATE updateDisbursements;
                }*/
            }
    }   



    public void beforeDeleteRestrictionDeletion(List<ampi__Financial__c> newFinancials) {
        for(ampi__Financial__c acc : newFinancials){
            if (acc.ampi__Category__c == '3 CMG CI') {
                acc.addError('Financials from category "3 CMG CI" are not allowed to be removed or changed');
            } 

			if (acc.Is_ReadOnly__c == true) {
				Id profileId = userinfo.getProfileId();
                List<Profile> profiles = [Select Name from Profile where Id =: profileId AND Name = 'System Administrator'];

                if (profiles.size() == 0) {
                    acc.addError('Financials are not allowed to be removed or changed');                                                    
                }
            }
        } 
    }

    public void beforeUpdateRestrictionDeletion(List<ampi__Financial__c> oldFinancials, List<ampi__Financial__c> newFinancials) {
        for(ampi__Financial__c acc : newFinancials){
            if (acc.ampi__Category__c == '3 CMG CI') {
                for(ampi__Financial__c accold : oldFinancials) {
                    if (acc.Id == accold.Id && acc.Order_Project__c == accold.Order_Project__c && acc.Is_ReadOnly__c == accold.Is_ReadOnly__c) {
                        acc.addError('Financials from category "3 CMG CI" are not allowed to be removed or changed');
                    }
                }
            } 

            if (acc.Is_ReadOnly__c == true) {
                Id profileId = userinfo.getProfileId();
                List<Profile> profiles = [Select Name from Profile where Id =: profileId AND Name = 'System Administrator'];

                if (profiles.size() == 0) {
                    for(ampi__Financial__c accold : oldFinancials) {
                        if (acc.Id == accold.Id && acc.Order_Project__c == accold.Order_Project__c && acc.Is_ReadOnly__c == accold.Is_ReadOnly__c) {
                            acc.addError('Financials are not allowed to be removed or changed');
                        }
                    }
                }                
            }
        } 
    }

    public void beforeInsertFinancialCategory(List<ampi__Financial__c> newFinancials) {
        for(ampi__Financial__c acc : newFinancials){
            if (acc.ampi__Category__c == '3 IF4C' && acc.Is_ReadOnly__c == false) {
                acc.addError('Financials from category "3 IF4C" are not allowed to be created by users');
            } 
        } 
    }
}