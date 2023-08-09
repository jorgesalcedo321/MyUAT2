public class GeographicAreaTriggerHandler {
    public void manageBeforeInsertGA(List<ampi__Geographical_Area__c> newPUs) {
        Map<ID,Schema.RecordTypeInfo> rt_Map = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosById();
        
        for(ampi__Geographical_Area__c ga: newPUs) {    
             String recordTypeName = rt_map.get(ga.RecordTypeId).getDeveloperName();                
             if (recordTypeName == 'Country') {                 
                 checkGACountry(ga);
             }             
         }
    }
    
    public void manageBeforeUpdateGA(List<ampi__Geographical_Area__c> oldPUs, List<ampi__Geographical_Area__c> newPUs) {
        for (ampi__Geographical_Area__c newPU : newPUs) {
            ampi__Geographical_Area__c currentGA = null;
        	for (ampi__Geographical_Area__c oldPU : oldPUs) {
                if (oldPU.Id == newPU.Id) {
                    currentGA = oldPU;
                }
            }
            
        	beforeUpdateProgrammeRecords(currentGA, newPU);
            beforeUpdateProjectServiceTypeUpdate(currentGA, newPU);
            beforeUpdateGeographicalAreaISPAvailable(currentGA, newPU);
        }
    	
    }
        
    private void checkGACountry(ampi__Geographical_Area__c ga) {                     
                     if (ga.Code__c != NULL && ga.Code__c.length() == 3) {
                         List<ampi__Geographical_Area__c > gas = [SELECT Id FROM ampi__Geographical_Area__c WHERE Code__c=:ga.Code__c AND RecordType.Name = 'Country'];
                         if (gas.size() > 0) {
                             ga.addError('Country code must be unique');
                         }
                     } else {
                         ga.addError('Country code must have 3 characters');                     
                     }
	}
    
    private void beforeUpdateProgrammeRecords(ampi__Geographical_Area__c oldPU, ampi__Geographical_Area__c newPU) {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Manage_Restrictions');

        if (hasCustomPermission)
            return;
                
        Set<Id> pusToUpdate = new Set<Id>();
             Map<ID,Schema.RecordTypeInfo> rt_Map = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosById();
             //System.debug('###rt_map.get(oldPU.RecordTypeId).getDeveloperName():' + rt_map.get(oldPU.RecordTypeId).getDeveloperName());
             //All Programmes with the “Active” value “NO” as well as all Programmes without any active projects/released PUs (or the like in future) have to have an Operation End Date.
             if ((rt_map.get(oldPU.RecordTypeId).getDeveloperName() == 'Organisational_Unit' && (oldPU.ampi__Type__c == 'National Office Programme')) || 
                 (rt_map.get(oldPU.RecordTypeId).getDeveloperName() == 'Programme_Location')) {
                 List<ampi__project__c> projectsRelated = [SELECT Id FROM ampi__project__c WHERE programme_location__c =: oldPU.Id];
                 //System.debug('####projectsRelated:' + projectsRelated.size());
                 //List<ampi__geographical_area__c> programmeInfoRelated = [SELECT Id FROM ampi__geographical_area__c WHERE ampi__Parent_Geographical_Area__c =: oldPU.Id];
                 //System.debug('####programmeInfoRelated:' + programmeInfoRelated.size());
                 List<ampi__geographical_area__c> puRelated = [SELECT Id FROM ampi__geographical_area__c WHERE ampi__Parent_Geographical_Area__c =: oldPU.Id];
                 //System.debug('####puRelated:' + puRelated.size());
                     
                 System.debug('####newPU.Active__c:' + newPU.Active__c);
                 if (oldPU.Id == newPU.Id && newPU.Active__c == 'No' && (newPU.Operation_End_Date__c == null  || newPU.Date_Founded__c > newPU.Operation_End_Date__c) && projectsRelated.size() == 0 && puRelated.size() == 0) {
                 	newPU.addError('Operation End Date field must be completed because the Programme is inactive and has no projects and programme units related and has to be greater than Operational Start Date');                    
                }
             }             
        }
    
    private void beforeUpdateProjectServiceTypeUpdate(ampi__Geographical_Area__c oldPU, ampi__Geographical_Area__c newPU) {
        Set<Id> pusToUpdate = new Set<Id>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosById();
        System.debug('####rt_map.get(oldPU.RecordTypeId).getDeveloperName():' + rt_map.get(oldPU.RecordTypeId).getDeveloperName());
        System.debug('####oldPU.ampi__Type__c:' + oldPU.ampi__Type__c);
        if (rt_map.get(oldPU.RecordTypeId).getDeveloperName() == 'Organisational_Unit' && (oldPU.ampi__Type__c == 'Programme Unit' || oldPU.ampi__Type__c == 'National Management Unit')) {
        	if (oldPU.Extent_Information__c != newPU.Extent_Information__c) {
            	pusToUpdate.add(oldPU.Id);
            }
        }
        System.debug('####pusToUpdate.size():' + pusToUpdate.size());
        if (pusToUpdate.size() > 0) {
            List<ampi__Project_Thematic_Area__c> psts = [SELECT PU_Extent_Information__c, Id, Programme_Unit__c FROM ampi__Project_Thematic_Area__c WHERE Programme_Unit__c IN : pusToUpdate];
            for (ampi__Project_Thematic_Area__c pst : psts) {
                if (newPU.Id == pst.Programme_Unit__c) {
                	pst.PU_Extent_Information__c = newPU.Extent_Information__c;
                    System.debug('####newPU.Extent_Information__c:' + newPU.Extent_Information__c);
                }
            }
            UPDATE psts;
        }
    }

    private void beforeUpdateGeographicalAreaISPAvailable(ampi__Geographical_Area__c prsToCheck, ampi__Geographical_Area__c prsUpdated) {
        System.debug('##### enter beforeUpdateGeographicalAreaISPAvailable');
        
		if (prsUpdated.ISP_Available__c != prsToCheck.ISP_Available__c) {
        	List<string> projIds = new List<string>();
                    
            String IPS_value = prsUpdated.ISP_Available__c;                
                    //TODO: comented because of ticket AMIMSP-2043
                    /*if (prsUpdated.ISP_Available__c == 'No' || prsUpdated.ISP_Available__c == 'Temporarily closed for international sponsorship') {
                        System.debug('##### enter beforeUpdateGeographicalAreaISPAvailable ISP Different same Id');
                        
                        List<ampi__project__c> projs = [SELECT Id, ISP_Available__c FROM ampi__project__c WHERE programme_location__c =: prsUpdated.Id AND ISP_Available__c <> :IPS_value AND RecordType.Name IN ('Standard', 'Transition')];

                        for (ampi__project__c proj : projs) {
                            projIds.add(proj.Id);
                            proj.ISP_Available__c = IPS_value;
                        }

                        if (projs.size() == 0) {
                            continue;
                        }

                        Database.SaveResult[] updateResult = Database.update(projs, false);  
                        for (Database.SaveResult r : updateResult){  
                            if (!r.isSuccess()){  
                                prsUpdated.addError('Project related records have missing mandatory fields');                            
                            }  
                        }                                                 
                    }*/
        }
    }

	/*public void beforeCheckMandatoryFieldsForPUsAndNMUs(List<ampi__Geographical_Area__c> oldPUs, List<ampi__Geographical_Area__c> newPUs) {  
        System.debug('####beforeCheckMandatoryFieldsForPUsAndNMUs');
        for (ampi__Geographical_Area__c oldPU : oldPUs) {
             if (oldPU.ampi__Type__c == 'Programme Unit' || oldPU.ampi__Type__c == 'National Management Unit') {
                 for (ampi__Geographical_Area__c newPU : newPUs) {                     
                    if (oldPU.Id == newPU.Id && (newPU.Active__c == null || newPU.ampi__Parent_Geographical_Area__c == null || newPU.Program_Unit_Type__c == null || newPU.Thematic_Area__c == null || newPU.Parent_MA__c == null)) {
        				newPU.addError('Programme Units and National Management Units have mandatory fields: Type, Active, Parent Geographical Area, Programme Unit Type, Service Type and Parent MA');                            
    				}                         
                }
             }             
        }
    }*/
}