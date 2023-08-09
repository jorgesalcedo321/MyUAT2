@isTest
private class UtilTestCases {
    @isTest(SeeAllData=true)
    static void createProjectIndicatorObjective_From_ProjectManagerUser() {
        User u = [SELECT Id, profileId, email, username FROM User WHERE Id = '0053N00000AiWxB' LIMIT 1];
        System.runAs(u) {
            //CREAR REGISTROS: Create Project Indicator Objective record
            //Crear un registro ampi__Project_Indicator_Objective__c donde:
            ampi__Project_Indicator_Objective__c pio = new ampi__Project_Indicator_Objective__c();
            pio.ampi__Project_Indicator__c = 'a0f3N000002ULm6QAG';
            pio.ampi__xx_Framework_Objective__c = 'a0Q7T000000kJFYUA2';
            
            try {
                INSERT pio;    
            } catch(Exception ex) {
                System.debug('####exception:' + ex.getMessage());
            }    
        }
    }
}