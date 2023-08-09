public class ProjectServiceTypeTriggerHandler {
    public void beforeInsertProjectServiceTypes(List<ampi__Project_Thematic_Area__c> newPTAs) {
           Set<Id> newPus = new Set<Id>();           
           for (ampi__Project_Thematic_Area__c pst : newPTAs) {
                System.debug('####pst:' + pst);
                System.debug('####pst.ampi__thematic_area__c:' + pst.ampi__thematic_area__c);
                
                List<ampi__Project_Thematic_Area__c> checkDuplicates = [SELECT Id, Programme_Unit__c, ampi__project__r.RecordType.Name FROM ampi__Project_Thematic_Area__c 
                                                                       WHERE ampi__project__c =: pst.ampi__project__c AND ampi__thematic_area__c =: pst.ampi__thematic_area__c AND ((Programme_Unit__c =: pst.Programme_Unit__c AND ampi__project__r.RecordType.Name NOT IN ('Standard','Grant','Humanitarian')) OR (ampi__project__r.RecordType.Name IN ('Standard','Grant','Humanitarian')))] ;

                //List<ampi__Project_Thematic_Area__c> checkDuplicates2 = [SELECT Id, ampi__project__r.RecordType.Name FROM ampi__Project_Thematic_Area__c 
                //                                                       WHERE ampi__project__c =: pst.ampi__project__c AND ampi__thematic_area__c =: pst.ampi__thematic_area__c AND ampi__project__r.RecordType.Name IN ('Standard','Grant','Humanitarian')];
                            
               if (checkDuplicates.size() > 0) {
                   Set<string> projectTypes = new Set<string>{'Standard','Grant','Humanitarian'};
                    boolean duplicated = false;
                    boolean serviceExists = false;
                    for (ampi__Project_Thematic_Area__c currentPST : checkDuplicates) {
                        if (currentPST.Programme_Unit__c == pst.Programme_Unit__c && !projectTypes.contains(currentPST.ampi__project__r.RecordType.Name)) {
                            duplicated = true;
                        }
                        if (projectTypes.contains(currentPST.ampi__project__r.RecordType.Name)) {
                            serviceExists = true; 
                        }
                    }
                   
                    if (duplicated) {
                    	pst.addError('Project Service Type can\'t be duplicated. Please check Service Type, Project and Programme Unit datafields.');
                        return;
                    }
                   
                    if (serviceExists) {
                        pst.addError('Selected Service type already exists. Please use different Service type for this project.');
                        return;
                    }
                }
                
                List<ampi__Project_Thematic_Area__c> ptaSameProject = [SELECT order_project__c FROM ampi__Project_Thematic_Area__c 
                                                                       WHERE ampi__project__c =: pst.ampi__project__c AND ampi__thematic_area__c =: pst.ampi__thematic_area__c AND order_project__c <> NULL ORDER BY order_project__c DESC];
                System.debug('#####ptaSameProject.size():' + ptaSameProject.size());
                if (ptaSameProject.size() > 0) {
                    pst.order_project__c = ptaSameProject[0].order_project__c + 1;
                }
                System.debug('#####pst.order_project__c:' + pst.order_project__c);
                
                if (pst.Programme_Unit__c != null) {
                    newPus.add(pst.Programme_Unit__c);                    
                }
            } 

            if (newPus.size() > 0) {
                List<ampi__Geographical_Area__c> gas = [SELECT Id, Extent_Information__c FROM ampi__Geographical_Area__c WHERE Id =: newPus];

                for (ampi__Geographical_Area__c ga : gas) {
                    for (ampi__Project_Thematic_Area__c pst : newPTAs) {
                        if (pst.Programme_Unit__c != null && pst.Programme_Unit__c == ga.Id) {
                            pst.PU_Extent_Information__c = ga.Extent_Information__c;                                                
                        }                
                    }
                }
                //UPDATE newPTAs;
            }
    }    

    public void beforeDeleteRestrictProjectServiceTypeDeletion(List<ampi__Project_Thematic_Area__c> oldServiceTypeProjects) {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Manage_Restrictions');
        if (hasCustomPermission) {
            Integer countUsers = [SELECT Count() FROM User WHERE Id =:UserInfo.getUserId() AND Profile.Name = 'System Administrator'];
            if (countUsers > 0) {
                return;
            }                            
        }

        System.debug('####enter beforeDeleteRestrictProjectServiceTypeDeletion!');
        for(ampi__Project_Thematic_Area__c acc : oldServiceTypeProjects){
            List<ampi__project__c> projectsData = [SELECT RecordType.Name, ampi__Project_Status__c, Phase__c FROM ampi__project__c WHERE Id =: acc.ampi__project__c];

            if (projectsData.size() > 0) {
                if ((projectsData[0].RecordType.Name == 'Transition' && projectsData[0].ampi__Project_Status__c == 'In Implementation') ||
                    (projectsData[0].RecordType.Name == 'Standard' && (projectsData[0].ampi__Project_Status__c == 'Funding Approved' || projectsData[0].Phase__c == 'Implementation' || projectsData[0].Phase__c == 'Closure')) ||
                    (projectsData[0].RecordType.Name == 'Grant' && (projectsData[0].ampi__Project_Status__c == 'Application Approved' || projectsData[0].ampi__Project_Status__c == 'In Implementation' || projectsData[0].Phase__c == 'Implementation' || projectsData[0].Phase__c == 'Closure')) ||
                    (projectsData[0].RecordType.Name == 'Humanitarian' && (projectsData[0].ampi__Project_Status__c == 'Plan Submitted' || projectsData[0].Phase__c == 'Implementation' || projectsData[0].Phase__c == 'Closure')) ||
                    (projectsData[0].RecordType.Name == 'Construction' && projectsData[0].ampi__Project_Status__c == 'Total Funding Available')) {
                    acc.addError('Service Type Projects are not allowed to be removed');
                }
            }
        } 
    }
}