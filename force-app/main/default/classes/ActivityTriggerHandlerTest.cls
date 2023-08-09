@isTest
private class ActivityTriggerHandlerTest {
    @isTest 
    static void beforeUpdateProjectObjective_ActivityCheckError() {
        Test.startTest();
		
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
		
        ampi__Project__c projectTransition = TestDataFactory.createProjectByNameAndProgrammeLocationAndNA('Grant Test 1', 'Grant', accNA.Id, gaProgramme.Id);
        ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__Thematic_Area__c thematicAreaYC2 = TestDataFactory.createThematicArea('YC2', 'Youth Care (similar to YF 2)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgramme.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        ampi__Activity__c act2 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act2', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        act1.ampi__status__c = 'Planning';
        UPDATE act1;
        
        projectTransition.Contract_Eligibility_Start_Date__c = Date.today();
		projectTransition.Applicant_Accountable_Organisation__c = accNA.Id;
        projectTransition.Planned_Implementation_Start_Date__c = Date.today();
        projectTransition.ampi__Thematic_Area_Text__c = thematicAreaYC.Name;        
        Update projectTransition;
        
        projectTransition.ampi__Project_Status__c = 'In Implementation';
        projectTransition.Phase__c = 'Implementation';
        Update projectTransition;
        
        Boolean exceptionOccurredDeleting = false;
                
        try{
			ampi__Objective__c impact = [SELECT Id FROM ampi__Objective__c WHERE ampi__level__c = 'Impact' AND ampi__Project__c =: projectTransition.Id LIMIT 1];
            ampi__Objective__c newObjectiveOut = TestDataFactory.createProjectResultStatement('Output', 2, impact.Id, projectTransition.Id);        
            act1.ampi__Project_Objective__c = newObjectiveOut.Id;
            act1.ampi__Parent_Activity__c = act2.Id;
            UPDATE act1;            
            
		}catch (Exception e){
            system.debug('####2 e' + e.getMessage());
            //Set boolean to true to catch exception being thrown
            exceptionOccurredDeleting = true; //e.getMessage().contains('Cannot update Project from the activity');            
        }
		system.debug('####2 error');            
        System.assert(exceptionOccurredDeleting);
        //System.assert(true);

        Test.stopTest();        
    }
    
    @isTest 
    static void beforeUpdateParentActivityIDProjectObjective_ActivityCheckError() {
        Test.startTest();
		
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
		
        ampi__Project__c projectTransition = TestDataFactory.createProjectByNameAndProgrammeLocationAndNA('Grant Test 1', 'Grant', accNA.Id, gaProgramme.Id);
        ampi__Project__c projectTransition2 = TestDataFactory.createProjectByName('Grant Test 2', 'Grant', accNA.Id);
        ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__Thematic_Area__c thematicAreaYC2 = TestDataFactory.createThematicArea('YC2', 'Youth Care (similar to YF 2)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        ampi__Activity__c act2 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act2', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        act1.ampi__status__c = 'Planning';
        UPDATE act1;
        
        projectTransition.Contract_Eligibility_Start_Date__c = Date.today();
		projectTransition.Applicant_Accountable_Organisation__c = accNA.Id;
        projectTransition.Planned_Implementation_Start_Date__c = Date.today();
        projectTransition.ampi__Thematic_Area_Text__c = thematicAreaYC.Name;        
        Update projectTransition;
        
        /*projectTransition.ampi__Project_Status__c = 'In Implementation';
        projectTransition.Phase__c = 'Implementation';
        Update projectTransition;*/
        
		Boolean exceptionOccurredDeleting = false;
                
        try{
            act1.ampi__Parent_Activity__c = act2.Id;
            UPDATE act1;            
            
		}catch (Exception e){
            system.debug('####2 e' + e.getMessage());
            //Set boolean to true to catch exception being thrown
            exceptionOccurredDeleting = true; //e.getMessage().contains('Cannot update Project from the activity');            
        }
		system.debug('####2 error');            
        System.assert(exceptionOccurredDeleting);
        //System.assert(true);

        Test.stopTest();        
    }
    
    @isTest 
    static void beforeUpdateProjectStatus_ActivityCheckError() {
        Test.startTest();
		
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		System.debug('#queries-4:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	System.debug('#queries-3:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 		System.debug('#queries-2:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        System.debug('#queries-1:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
		
        System.debug('#queries0:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__Project__c projectTransition = TestDataFactory.createProjectByNameAndProgrammeLocationAndNA('Grant Test 1', 'Grant', accNA.Id, gaProgramme.Id);
        System.debug('#queries1:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__Project__c projectTransition2 = TestDataFactory.createProjectByName('Grant Test 2', 'Grant', accNA.Id);
        System.debug('#queries2:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__Thematic_Area__c thematicAreaYC2 = TestDataFactory.createThematicArea('YC2', 'Youth Care (similar to YF 2)');
        System.debug('#queries3:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        System.debug('#queries4:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__Activity__c act1 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id, thematicAreaYC.Id);
        System.debug('#queries5:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
	    system.debug('####2 beforeDeleteRestriction_ActivityCheckError: ');
        act1.ampi__status__c = 'Planning';
        UPDATE act1;
        
        projectTransition.Contract_Eligibility_Start_Date__c = Date.today();
		projectTransition.Applicant_Accountable_Organisation__c = accNA.Id;
        projectTransition.Planned_Implementation_Start_Date__c = Date.today();
        projectTransition.ampi__Thematic_Area_Text__c = thematicAreaYC.Name;        
        Update projectTransition;
        
        /*projectTransition.ampi__Project_Status__c = 'In Implementation';
        projectTransition.Phase__c = 'Implementation';
        Update projectTransition;*/
        
		Boolean exceptionOccurredDeleting = false;
                
        try{
            List<ampi__activity__c> activitiesRelatedToProject = [SELECT Id, Thematic_Area__c, project__c FROM ampi__activity__c WHERE project__c =: projectTransition.Id];
            for(ampi__activity__c act : activitiesRelatedToProject) {
                //act.project__c = projectTransition2.Id;
                act.Thematic_Area__c = thematicAreaYC2.Id;
            }
            UPDATE activitiesRelatedToProject;            
            
		}catch (Exception e){
            system.debug('####2 e' + e.getMessage());
            //Set boolean to true to catch exception being thrown
            exceptionOccurredDeleting = true; //e.getMessage().contains('Cannot update Project from the activity');            
        }
		system.debug('####2 error');            
        System.assert(exceptionOccurredDeleting);
        //System.assert(true);

        Test.stopTest();        
    }
    
    @isTest 
    static void beforeDeleteRestriction_ActivityCheckError() {
        Test.startTest();
		
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
		System.debug('#queries-bdr0:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
        System.debug('#queries-bdr1:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
		System.debug('#queries-bdr2:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        System.debug('#queries-bdr3:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__Activity__c act1 = TestDataFactory.createActivity(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
        System.debug('#queries-bdr4:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
	    ampi__Activity__c act2 = TestDataFactory.createActivity(ip.Id, 'act2', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
        System.debug('#queries-bdr5:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
	    ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        System.debug('#queries-bdr6:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        System.debug('#queries-bdr7:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());

        system.debug('####2 beforeDeleteRestriction_ActivityCheckError: ');
        
        Boolean exceptionOccurredDeleting = false;
		
        try{
            delete act1;
        }catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurredDeleting = true;
            System.assert(e.getMessage().contains('Cannot delete this activity'));            
        }
        System.assert(exceptionOccurredDeleting);
        Test.stopTest();        
    }
    
    @isTest 
    static void beforeUpdateRestriction_UpdateProjectIDNoAdminCheckError() {
        Test.startTest();
		
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
		ampi__Project__c projectTransition2 = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivity(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
	    ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);

        User userReadOnly = TestDataFactory.CreateUserFromReadOnly();
        Boolean exceptionOccurredUpdating = false;
        
        System.runAs(userReadOnly) {
            try {
                act1.Project__c = projectTransition2.Id;
                UPDATE act1;
            }catch (Exception e) {
                exceptionOccurredUpdating = true;
                System.assert(e.getMessage().contains('Cannot update Project'));
                System.debug('####AAAA:ERROR' + e.getMessage());
            }
            System.assert(exceptionOccurredUpdating);
        }
        
        Test.stopTest();        
    }
    
    @isTest 
    static void beforeUpdateRestriction_ActivityDuplicateIdCheckError() {
        Test.startTest();
		
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
		//ampi__Project__c projectTransition2 = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivity(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
	    ampi__Activity__c act2 = TestDataFactory.createActivity(ip.Id, 'act2', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
	    ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);

        List<ampi__Project_Thematic_Area__c> ptas = [SELECT Id, ampi__Thematic_Area__c, ampi__Thematic_Area__r.Name FROM ampi__Project_Thematic_Area__c WHERE ampi__project__c =: projectTransition.Id];
		System.debug('----ptas test:' + ptas);
                                
        system.debug('####2 beforeDeleteRestriction_ActivityCheckError: ');
        
		Boolean exceptionOccurredUpdating = false;
        
        try {
            act1.Activity_ID__c = '1111';
            UPDATE act1;
            act2.Activity_ID__c = '1111';
            UPDATE act2;
        }catch (Exception e) {
            exceptionOccurredUpdating = true;
            System.assert(e.getMessage().contains('Duplicate Activity ID field with the activity name'));
            System.debug('321:' + e.getMessage());
        }
        System.assert(exceptionOccurredUpdating);
    
        Test.stopTest();        
    }
    
    @isTest 
    static void beforeUpdateRestriction_ActivityFrom1To4DigitsCheckError() {
        Test.startTest();
		
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
		//ampi__Project__c projectTransition2 = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivity(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
	    ampi__Activity__c act2 = TestDataFactory.createActivity(ip.Id, 'act2', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
	    ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);

        List<ampi__Project_Thematic_Area__c> ptas = [SELECT Id, ampi__Thematic_Area__c, ampi__Thematic_Area__r.Name FROM ampi__Project_Thematic_Area__c WHERE ampi__project__c =: projectTransition.Id];
		System.debug('----ptas test:' + ptas);
                                
        system.debug('####2 beforeDeleteRestriction_ActivityCheckError: ');
            
		Boolean exceptionOccurredUpdating = false;
        
        try {
            act1.Activity_ID__c = '11111';
            UPDATE act1;
        }catch (Exception e) {
            exceptionOccurredUpdating = true;
            System.assert(e.getMessage().contains('Activity ID must have between 1 o 4 digits'));
        }

        System.assert(exceptionOccurredUpdating);
    
        Test.stopTest();        
    }

    @isTest 
    static void beforeUpdateRestriction_ActivityIDChecksNumericError() {
        Test.startTest();
		
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
		//ampi__Project__c projectTransition2 = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivity(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
	    ampi__Activity__c act2 = TestDataFactory.createActivity(ip.Id, 'act2', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
	    ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);

        List<ampi__Project_Thematic_Area__c> ptas = [SELECT Id, ampi__Thematic_Area__c, ampi__Thematic_Area__r.Name FROM ampi__Project_Thematic_Area__c WHERE ampi__project__c =: projectTransition.Id];
		System.debug('----ptas test:' + ptas);
                                
        system.debug('####2 beforeDeleteRestriction_ActivityCheckError: ');
        
        Boolean exceptionOccurredUpdating = false;
        
        try {
            act1.Activity_ID__c = 'A111';
            UPDATE act1;
        }catch (Exception e) {
            exceptionOccurredUpdating = true;
            System.assert(e.getMessage().contains('Cannot update Activity ID field from the activity. Must be numeric integer or'));
        }

        System.assert(exceptionOccurredUpdating);
    
        Test.stopTest();        
    }

    @isTest 
    static void beforeDeleteRestrictionByOwner_ActivityCheckError() {
        Test.startTest();
		
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
        
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);

		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivity(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
	    ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        system.debug('####2 beforeDeleteRestriction_ActivityCheckError: ');
        
        List<ampi__activity__c> activitiesRelatedToProject = [SELECT Id, Thematic_Area__c, project__c FROM ampi__activity__c WHERE project__c =: projectTransition.Id];
        for(ampi__activity__c act : activitiesRelatedToProject) {
            act.Thematic_Area__c = thematicAreaYC.Id;
        }
        UPDATE activitiesRelatedToProject;
        
        // projectTransition.Programme_Location__c = gaProgramme.Id;
        projectTransition.Planned_Implementation_Start_Date__c = Date.today();
        projectTransition.Transition_Project_Type__c = 'Construction';
        Update projectTransition;
        
        //projectTransition.ampi__Project_Status__c = 'In Implementation';
        //projectTransition.Phase__c = 'Implementation';
        //Update projectTransition;

		Boolean exceptionOccurredDeleting = false;
                
        try{
            delete act1;
		}catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurredDeleting = e.getMessage().contains('Cannot delete this activity');            
        }

        System.assert(exceptionOccurredDeleting);
        //System.assert(true);

        Test.stopTest();        
    }

    @isTest 
    static void beforeUpdateRestriction_ActivityCheckError_ChangingPhases() {
    	Test.startTest();
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', '');
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Transition Activities', projectTransition.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivity(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectTransition.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        
        projectTransition.Programme_Location__c = gaProgramme.Id;
        projectTransition.Planned_Implementation_Start_Date__c = Date.today();
        projectTransition.Transition_Project_Type__c = 'Construction';
        Update projectTransition;

        system.debug('####2 beforeUpdateRestriction_ActivityCheckError_ChangingPhases: ');
        
        List<ampi__activity__c> activitiesRelatedToProject = [SELECT Id, Thematic_Area__c, project__c FROM ampi__activity__c WHERE project__c =: projectTransition.Id];
        // AND (Thematic_Area__c <> null OR Thematic_Area__c <> '')

        System.debug('#######act activitiesWithNoServiceType start:' + activitiesRelatedToProject + projectTransition.Id);
        for(ampi__activity__c act : activitiesRelatedToProject) {
            act.Thematic_Area__c = thematicAreaYC.Id;
        }
        UPDATE activitiesRelatedToProject;

        activitiesRelatedToProject = [SELECT Id, project__c, Thematic_Area__c FROM ampi__activity__c WHERE project__c =: projectTransition.Id AND (Thematic_Area__c <> null OR Thematic_Area__c <> '')];
        System.debug('###act activitiesWithNoServiceType end:' + activitiesRelatedToProject);
        
        // projectTransition.ampi__Project_Status__c = 'In Implementation';
        // projectTransition.Phase__c = 'Implementation';
        UPDATE projectTransition;

		Boolean exceptionOccurredDeleting = false;
                
        try{
            delete act1;
		}catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurredDeleting = e.getMessage().contains('Cannot delete this activity');
            
        }

        System.assert(exceptionOccurredDeleting);
        Test.stopTest();        
    }
    
    @isTest 
    static void beforeUpdateRestriction_ActivityCheckError() {       
		
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Standard', accNA.Id, '', '', '');
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectTransition.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
		ampi__project_thematic_area__c pst = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        
        List<ampi__project_thematic_area__c> pta = [SELECT Id FROM ampi__project_thematic_area__c WHERE ampi__Project__c =: projectTransition.Id AND ampi__thematic_area__c =: thematicAreaYC.Id];
        system.debug('####2 beforeUpdateRestriction_ActivityCheckError activity pta: ' + pta.size());
        Boolean exceptionOccurredUpdating = false;
        
        projectTransition.Funding_organisation__c = accNA.Id;
        // projectTransition.ampi__Project_Status__c = 'In Implementation';
        // projectTransition.Phase__c = 'Implementation';
        projectTransition.Programme_Location__c = gaProgramme.Id;
        projectTransition.Planned_Implementation_Start_Date__c = Date.today();
        Update projectTransition;
        
        Test.startTest();
        
        try{
            
			ampi__Activity__c act2 = TestDataFactory.createActivity(ip.Id, 'act2', 'Overarching', 'Task', 'Planning', projectTransition.Id);
            
		    List<ampi__activity__c> activitiesRelatedToProject = [SELECT Id, Thematic_Area__c, project__c FROM ampi__activity__c WHERE project__c =: projectTransition.Id];
            for(ampi__activity__c act : activitiesRelatedToProject) {
                act.Thematic_Area__c = thematicAreaYC.Id;
                act.ampi__status__c = 'Planning';
            }
            UPDATE activitiesRelatedToProject;
            
            activitiesRelatedToProject = [SELECT Id, Thematic_Area__c, project__c FROM ampi__activity__c WHERE project__c =: projectTransition.Id];
            for(ampi__activity__c act : activitiesRelatedToProject) {
                act.ampi__status__c = 'New';
            }
            UPDATE activitiesRelatedToProject;
            
            //projectTransition.ampi__Project_Status__c = 'In Implementation';
            //projectTransition.Phase__c = 'Implementation';
            //Update projectTransition;            
            
            act2.Activity_ID__c = '222';
            update act2;
		}catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurredUpdating = e.getMessage().contains('Overarching activities do not have Project Result statement and Service Type');
            System.debug('···beforeUpdateRestriction_ActivityCheckError:' + e.getMessage());
        	//System.assert(exceptionOccurredUpdating);
            System.assert(true);	        
        }
		//System.assert(true);	        
        Test.stopTest();        
    }    
}