@isTest
private class ProjectResultStatementTriggerHandlerTest {
    @isTest 
    static void beforeUpdateRestriction_PRSCheckError() {
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
        Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
        ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
		
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, gaProgramme.Id, '', '');
        
        ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__Thematic_Area__c thematicAreaYC2 = TestDataFactory.createThematicArea('YC2', 'Youth Care (similar to YF 2)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        ampi__Activity__c act2 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act2', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
                
		ampi__Objective__c newObjectiveImp = TestDataFactory.createProjectResultStatement('Impact', 1, '', projectTransition.Id);
        ampi__Objective__c newObjectiveImp2 = TestDataFactory.createProjectResultStatement('Impact', 2, '', projectTransition.Id);
        ampi__Objective__c newObjectiveOut = TestDataFactory.createProjectResultStatement('Output', 1, newObjectiveImp.Id, projectTransition.Id);
        ampi__Objective__c newObjectiveOut2 = TestDataFactory.createProjectResultStatement('Output', 2, newObjectiveImp.Id, projectTransition.Id);

        projectTransition.Service_Type_Assigned__c = true;
        projectTransition.ampi__Project_Status__c = 'In Implementation';
        projectTransition.Phase__c = 'Implementation';
        projectTransition.Planned_Implementation_Start_Date__c = Date.newinstance(Date.today().year(), 1, 1);
        projectTransition.Funding_organisation__c = accNA.Id;

        Update projectTransition;
        
		Test.startTest();
        Boolean exceptionOccurredUpdating = false;
        
        try{
            newObjectiveOut.ampi__Parent_Project_Objective__c = newObjectiveImp2.Id;
            update newObjectiveOut;
		}catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurredUpdating = e.getMessage().contains('Cannot update Related Project Result Statement fields from the Project');
        }

        System.assert(exceptionOccurredUpdating);

        Test.stopTest();        
    }

    @isTest 
    static void beforeDeleteRestriction_PRSCheckError() {
    	ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
        ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
		
        ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, gaProgramme.Id, '', '');
		
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__Thematic_Area__c thematicAreaYC2 = TestDataFactory.createThematicArea('YC2', 'Youth Care (similar to YF 2)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        ampi__Activity__c act2 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act2', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        
        ampi__Objective__c newObjectiveImp = TestDataFactory.createProjectResultStatement('Impact', 1, '', projectTransition.Id);
        ampi__Objective__c newObjectiveImp2 = TestDataFactory.createProjectResultStatement('Impact', 2, '', projectTransition.Id);
        ampi__Objective__c newObjectiveOut = TestDataFactory.createProjectResultStatement('Output', 1, newObjectiveImp.Id, projectTransition.Id);
        ampi__Objective__c newObjectiveOut2 = TestDataFactory.createProjectResultStatement('Output', 2, newObjectiveImp.Id, projectTransition.Id);

        projectTransition.Service_Type_Assigned__c = true;
        projectTransition.Planned_Implementation_Start_Date__c = Date.newinstance(Date.today().year(), 1, 1);
        projectTransition.Funding_organisation__c = accNA.Id;
        projectTransition.ampi__Project_Status__c = 'In Implementation';
        projectTransition.Phase__c = 'Implementation';        
        Update projectTransition;
        
		Test.startTest();
        Boolean exceptionOccurredUpdating = false;
        
        try{
            delete newObjectiveOut;
		}catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurredUpdating = e.getMessage().contains('Cannot delete Project Result Statement if the project');
        }

        System.assert(exceptionOccurredUpdating);

        Test.stopTest();        
    }

    @isTest 
    static void beforeInsertSetShortDescription_Checks() {
    	ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
        ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
		
        ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, gaProgramme.Id, '', '');
		
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__Thematic_Area__c thematicAreaYC2 = TestDataFactory.createThematicArea('YC2', 'Youth Care (similar to YF 2)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        ampi__Activity__c act2 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act2', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        
        ampi__Objective__c newObjectiveImp = TestDataFactory.createProjectResultStatement('Impact', 1, '', projectTransition.Id);
        ampi__Objective__c newObjectiveImp2 = TestDataFactory.createProjectResultStatement('Impact', 2, '', projectTransition.Id);
        ampi__Objective__c newObjectiveOut = TestDataFactory.createProjectResultStatement('Output', 1, newObjectiveImp.Id, projectTransition.Id);
        ampi__Objective__c newObjectiveOut2 = TestDataFactory.createProjectResultStatement('Output', 2, newObjectiveImp.Id, projectTransition.Id);

        String originalFullText = 'What is Lorem Ipsum? Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.';
        ampi__Objective__c newObjective = new ampi__Objective__c();
        newObjective.RecordTypeId = ampi__Objective__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('YouthCan! Project Result Statement').getRecordTypeId();
        newObjective.ampi__Description__c = originalFullText;
        newObjective.ampi__Label__c = 'Test Label Output rnd ';
        newObjective.ampi__Level__c = 'Output';
        newObjective.ampi__Parent_Project_Objective__c = newObjectiveImp.Id;
        newObjective.ampi__Project__c = projectTransition.Id;
        insert newObjective;
        
		Test.startTest();        
        System.assert(originalFullText.length() > newObjective.description_short__c.length());
        Test.stopTest();        
    }

    @isTest 
    static void beforeUpdateSetShortDescription_Checks() {
    	ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
        ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
		
        ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, gaProgramme.Id, '', '');
		
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__Thematic_Area__c thematicAreaYC2 = TestDataFactory.createThematicArea('YC2', 'Youth Care (similar to YF 2)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        ampi__Activity__c act2 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act2', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        
        ampi__Objective__c newObjectiveImp = TestDataFactory.createProjectResultStatement('Impact', 1, '', projectTransition.Id);
        ampi__Objective__c newObjectiveImp2 = TestDataFactory.createProjectResultStatement('Impact', 2, '', projectTransition.Id);
        ampi__Objective__c newObjectiveOut = TestDataFactory.createProjectResultStatement('Output', 1, newObjectiveImp.Id, projectTransition.Id);
        ampi__Objective__c newObjectiveOut2 = TestDataFactory.createProjectResultStatement('Output', 2, newObjectiveImp.Id, projectTransition.Id);

        String originalFullText = 'What is Lorem Ipsum? Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.';
        ampi__Objective__c newObjective = new ampi__Objective__c();
        newObjective.RecordTypeId = ampi__Objective__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('YouthCan! Project Result Statement').getRecordTypeId();
        newObjective.ampi__Description__c = 'Test Description Output rnd ';
        newObjective.ampi__Label__c = 'Test Label Output rnd ';
        newObjective.ampi__Level__c = 'Output';
        newObjective.ampi__Parent_Project_Objective__c = newObjectiveImp.Id;
        newObjective.ampi__Project__c = projectTransition.Id;
        INSERT newObjective;
        
		Test.startTest();        

        newObjective.ampi__Description__c = originalFullText;
        UPDATE newObjective;
        System.assert(originalFullText.length() > newObjective.description_short__c.length());

        Test.stopTest();        
    }
}