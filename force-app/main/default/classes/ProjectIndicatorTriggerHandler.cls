public class ProjectIndicatorTriggerHandler {
    public void beforeInsertProjectIndicators_SetTypeResultAggregated(List<ampi__project_indicator__c> newProjectIndicators) {
        Set<Id> newIndicatorIds = new Set<Id>();
        Set<Id> newProjectIds = new Set<Id>();

        for(ampi__project_indicator__c pi : newProjectIndicators) {
            System.debug('####pi:' + pi);
            //ampi__Related_Indicator__c
            if (pi.ampi__Catalog_Indicator__c <> null && !newIndicatorIds.contains(pi.ampi__Catalog_Indicator__c)) {
                newIndicatorIds.add(pi.ampi__Catalog_Indicator__c);
            }

            if (pi.ampi__Project__c <> null && !newProjectIds.contains(pi.ampi__Project__c)) {
                newProjectIds.add(pi.ampi__Project__c);
            }
        }

        // SOS Implementing Organisation "Is PDB In Use?"=No. 
        // List<ampi__project_indicator__c> projectIndicatorsToUpdate = [SELECT ampi__Catalog_Indicator__r.ampi__Reporting_Frequency__c, ampi__Catalog_Indicator__r.ampi__Target_Frequency__c, Id, ampi__Type_of_Results__c FROM ampi__project_indicator__c WHERE Id IN :newIds AND ampi__Catalog_Indicator__r.Source_Document__c = 'Statistics Handbook V3' AND ampi__Catalog_Indicator__r.Level__c <> 'Staff' AND ampi__Type_of_Results__c <> 'Aggregated' AND ampi__Project__r.SOS_Implementing_Organisation__r.Is_PDB_In_Use__c = 'Yes'];
        // List<ampi__project_indicator__c> projectIndicatorsToUpdate = [SELECT ampi__Catalog_Indicator__r.ampi__Reporting_Frequency__c, ampi__Catalog_Indicator__r.ampi__Target_Frequency__c, Id, ampi__Type_of_Results__c, ampi__Catalog_Indicator__r.Source_Document__c, ampi__Catalog_Indicator__r.Level__c, ampi__Project__r.SOS_Implementing_Organisation__r.Is_PDB_In_Use__c FROM ampi__project_indicator__c WHERE Id IN :newIds];
        List<ampi__indicator__c> indicatorsRelated = [SELECT Id, ampi__Reporting_Frequency__c, ampi__Target_Frequency__c, Source_Document__c, Level__c FROM ampi__indicator__c WHERE Id IN :newIndicatorIds];
        List<ampi__Project__c> projectsRelated = [SELECT Id, SOS_Implementing_Organisation__r.Is_PDB_In_Use__c FROM ampi__project__c WHERE Id IN :newProjectIds];

        System.debug('####newIndicatorIds:' + newIndicatorIds);
        System.debug('####indicatorsRelated:' + indicatorsRelated);
        // System.debug('····projectIndicatorsToUpdate:' + projectIndicatorsToUpdate);
        System.debug('····Schema.sObjectType.ampi__project_indicator__c.isUpdateable():' + Schema.sObjectType.ampi__project_indicator__c.isUpdateable());
        // If (projectIndicatorsToUpdate.size() > 0 &&  Schema.sObjectType.ampi__project_indicator__c.isUpdateable()) {
        If (Schema.sObjectType.ampi__project_indicator__c.isUpdateable()) {
            for(ampi__project_indicator__c projectIndicatorToUpdate : newProjectIndicators) {

                String Source_Document = '';
                String Catalogue_Source_Unique_ID = '';
                String Level = '';
                String Reporting_Frequency = '';
                String Target_Frequency = '';
                String Is_PDB_In_Use = '';
                boolean indicatorExists = false;
                boolean projectExists = false;
                for(ampi__indicator__c ind : indicatorsRelated) {
                    //not for custom indicators (news)
                    if (ind.Id == projectIndicatorToUpdate.ampi__Catalog_Indicator__c) {
                        //TODO: && projectIndicatorToUpdate.Catalogue_Source_Unique_ID__c <> null) {
                        Source_Document = ind.Source_Document__c;
                        Level = ind.Level__c;
                        Reporting_Frequency = ind.ampi__Reporting_Frequency__c;
                        Target_Frequency = ind.ampi__Target_Frequency__c;
                        indicatorExists = true;
                    }
                }

                for(ampi__Project__c proj : projectsRelated) {
                    if (proj.Id == projectIndicatorToUpdate.ampi__project__c) {
                        Is_PDB_In_Use = proj.SOS_Implementing_Organisation__r.Is_PDB_In_Use__c;
                        projectExists = true;
                    }
                }
                System.debug('····projectExists: ' + projectExists);
                System.debug('····indicatorExits: ' + indicatorExists);
                System.debug('····projectIndicatorToUpdate.ampi__Type_of_Results__c: ' + projectIndicatorToUpdate.ampi__Type_of_Results__c);
                System.debug('····Source_Document__c: ' + Source_Document);
                System.debug('····Level__c: ' + Level);
                System.debug('····Is_PDB_In_Use__c: ' + Is_PDB_In_Use);
                System.debug('····Reporting_Frequency: ' + Reporting_Frequency);
                System.debug('····Target_Frequency: ' + Target_Frequency);

                if (projectExists && indicatorExists) {
                    if (projectIndicatorToUpdate.ampi__Type_of_Results__c <> 'Aggregated' && 
                        Source_Document == 'Statistics Handbook V3' && 
                        Level <> 'Staff' && 
                        Is_PDB_In_Use == 'Yes') {
                        projectIndicatorToUpdate.ampi__Type_of_Results__c = 'Aggregated';
                    }      

                    projectIndicatorToUpdate.ampi__Reporting_Frequency__c = Reporting_Frequency;
                    projectIndicatorToUpdate.ampi__Target_Frequency__c = Target_Frequency;
                    // System.debug('····pi vs indicator Target_Frequency: ' + projectIndicatorToUpdate.ampi__Target_Frequency__c + ' - ' + Target_Frequency);
                    // projectIndicatorToUpdate.ampi__Target_Frequency__c = '--';
                    // projectIndicatorToUpdate.ampi__Reporting_Frequency__c = '--';
                }
                System.debug('····projectIndicatorToUpdate: ' + projectIndicatorToUpdate);
            }
            // UPDATE projectIndicatorsToUpdate;
        }
    }
}