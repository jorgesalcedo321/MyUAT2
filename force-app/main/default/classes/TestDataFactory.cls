@isTest 
public class TestDataFactory {
    public static Team_Member__c createTeammember(String projectId, String userId, String role) {
		Team_Member__c tm = new Team_Member__c();
		tm.Project__c = projectId; 
        tm.Role__c = role;
        tm.User__c = userId;
		insert tm;
		return tm;
	}
	
    public static Address__c createAddress(String MAName, String countryId, String sponsorshipId) {
        Address__c addr = new Address__c();
        //addr.Additional_address__c = '11111111';
        addr.Name = '11111111';
        addr.City__c = '11111111'; 
        addr.Country__c = countryId;
        addr.District__c = '11111111';
        addr.Fax__c = '11111111';
        addr.Phone__c = '11111111';
        addr.Post_Box__c = '11111111';
        addr.Post_Box_City__c = '11111111';
        addr.Post_Box_Country__c = countryId;
        addr.Post_Box_Postal_Code__c = '11111111';
        addr.Postal_Code__c = '11111111';
        addr.Sponsorship_name_org_legal_entity__c = sponsorshipId;
        addr.Street_House_Number__c = '11111111';
        insert addr;
        return addr;
    }
    
    public static Account createMA(String MAName) {
        //Account accNA = TestDataFactory.createMA('NA Peru');
        Account accNA = new Account();
        accNA.Name = MAName; //'NA Peru';
        accNA.Type = 'NA';
        accNA.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('SOS Organisation - MA').getRecordTypeId();
        insert accNA;
        return accNA;
    }

    public static ampi__Objective__c createProjectResultStatement(String level, Integer randomNumber, String parentId, String projectId) {
        ampi__Objective__c newObjective = new ampi__Objective__c();
        newObjective.RecordTypeId = ampi__Objective__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('YouthCan! Project Result Statement').getRecordTypeId();
        newObjective.ampi__Description__c = 'Test Description '  + level + ' rnd ' + randomNumber;
        newObjective.ampi__Label__c = 'Test Label ' + level + ' rnd ' + randomNumber;
        // newObjective.ampi__Level__c = 'Output';
        newObjective.ampi__Level__c = level;

        if (parentId != '') {
            newObjective.ampi__Parent_Project_Objective__c = parentId;
        }

        newObjective.ampi__Project__c = projectId;
        // newObjective.Order_Number__c = randomNumber;
        insert newObjective;
        RETURN newObjective;
    }

    public static ampi__Reporting_Period__c manageMonitoringPeriodByProjectAndFrequency(Id projectId, String frequency) {
                        ampi__Reporting_Period__c reportingPeriod = new ampi__Reporting_Period__c();
                        reportingPeriod.ampi__Label__c = frequency;
                        reportingPeriod.ampi__Report_Type__c = frequency;
                        reportingPeriod.ampi__Reporting_Period_Start_Date__c = Date.newinstance(Date.today().year(), 1, 1);
                        reportingPeriod.ampi__Reporting_Period_End_Date__c = Date.newinstance(Date.today().year(), 12, 31);//reportingPeriod.ampi__Reporting_Period_Start_Date__c.addYears(durationInYears);
                        reportingPeriod.ampi__Project__c = projectId;

                        INSERT reportingPeriod;
                        RETURN reportingPeriod;
    }

    public static Account createMAWithCountry(String MAName, String country) {
        //Account accNA = TestDataFactory.createMA('NA Peru');
        Account accNA = new Account();
        accNA.Name = MAName; //'NA Peru';
        accNA.Country__c = country;
        accNA.Type = 'NA';
        accNA.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('SOS Organisation - MA').getRecordTypeId();
        insert accNA;
        return accNA;
    }

    public static ampi__Geographical_Area__c createRegion(String RegionName) {
        //ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
        ampi__Geographical_Area__c gaRegion = new ampi__Geographical_Area__c();
        gaRegion.Name = RegionName;//'LAAM';
        gaRegion.Long_Name__c = RegionName + ' Long';
        gaRegion.Code__c = '110';
        gaRegion.Date_Founded__c = date.today();
        gaRegion.RecordTypeId = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Region').getRecordTypeId();
        insert gaRegion;
        return gaRegion;
    }

    public static ampi__Geographical_Area__c createCountry(String CountryName, String regionID) {
        //ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
        ampi__Geographical_Area__c gaCountry = new ampi__Geographical_Area__c();
        gaCountry.Name = CountryName; //'Peru';
        gaCountry.ampi__Parent_Geographical_Area__c = regionID; //gaRegion.Id;
        gaCountry.Continent__c = 'South America';
        gaCountry.Code__c = 'PER';
        gaCountry.Date_Founded__c = date.today();
        gaCountry.RecordTypeId = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Country').getRecordTypeId();
        insert gaCountry;
        return gaCountry;
    }

    public static ampi__Geographical_Area__c createProgramme(String programmeName, String countryID, String MAId) {
        //ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        Integer IntrandomNumber = Integer.valueof((Math.random() * 100000));
        ampi__Geographical_Area__c gaProgramme = new ampi__Geographical_Area__c();
        gaProgramme.Name = programmeName;//'Callao';
        gaProgramme.ampi__Parent_Geographical_Area__c = countryID; //gaCountry.Id;
        gaProgramme.ampi__Type__c = 'Programme';
        gaProgramme.Program_Type__c = 'Programme';
        gaProgramme.Active__c = 'Yes';
        gaProgramme.Code__c = 'SUM-LOC-' + IntrandomNumber;
        gaProgramme.RecordTypeId = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Programme').getRecordTypeId();
        gaProgramme.Parent_MA__c = MAId; //accNA.Id;
        gaProgramme.Date_Founded__c = date.today();
        insert gaProgramme;
        return gaProgramme;
    }

    public static ampi__Geographical_Area__c createProgrammeUnit(String programmeUnitName, String programmeID, String MAId) {
        //ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgramme = new ampi__Geographical_Area__c();
        gaProgramme.Name = programmeUnitName;//'Callao';
        gaProgramme.ampi__Parent_Geographical_Area__c = programmeID; 
        gaProgramme.ampi__Type__c = 'Programme Unit';
        gaProgramme.Active__c = 'Yes';
        gaProgramme.Code__c = 'SUM-LOC-00000001';
        gaProgramme.Program_Unit_Type__c = 'FLC-Family-like Care-160';
        gaProgramme.RecordTypeId = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Organisational Unit').getRecordTypeId();
        gaProgramme.Parent_MA__c = MAId; //accNA.Id;
        gaProgramme.Extent_Information__c = 'SUM-LOC-00000001';
        gaProgramme.Date_Founded__c = date.today();
        insert gaProgramme;
        return gaProgramme;
    }

    public static ampi__Geographical_Area__c createNMU(String programmeUnitName, String programmeID, String MAId) {
        //ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgramme = new ampi__Geographical_Area__c();
        gaProgramme.Name = programmeUnitName;//'Callao';
        gaProgramme.ampi__Parent_Geographical_Area__c = programmeID; 
        gaProgramme.ampi__Type__c = 'National Management Unit';
        gaProgramme.Active__c = 'Yes';
        gaProgramme.Code__c = 'SUM-LOC-00000001';
        gaProgramme.RecordTypeId = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Organisational Unit').getRecordTypeId();
        gaProgramme.Parent_MA__c = MAId; //accNA.Id;
        gaProgramme.Extent_Information__c = 'SUM-LOC-00000001';
        //gaProgramme.Program_Unit_Type__c = 'NBAD-Advocacy-963';
        gaProgramme.Date_Founded__c = date.today();
        insert gaProgramme;
        return gaProgramme;
    }


    public static ampi__Implementation_Plan__c createActivitySchedule(String name, String projectID) {
        ampi__Implementation_Plan__c ip = new ampi__Implementation_Plan__c();
        ip.Name = name;
        ip.ampi__Project__c = projectID;
        insert ip; 
        return ip;
    }

    
    public static ampi__Activity__c createActivity(String scheduleId, String name, String typeA, String activityType, String status, String projectId) {
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));

        ampi__Activity__c act1 = new ampi__Activity__c();
        act1.ampi__Implementation_Plan__c = scheduleId;
        act1.Name = name;
        act1.ampi__Type__c = typeA;
        act1.ampi__xx_Activity_Type__c = activityType;
        act1.ampi__status__c = status;
        act1.Activity_ID__c = IntrandomNumber + '';
        act1.Project__c = projectId;

        if (typeA == 'Results-Based') {
            ampi__Objective__c newObjectiveImp = TestDataFactory.createProjectResultStatement('Impact', 1, '', projectId);
            ampi__Objective__c newObjectiveOut = TestDataFactory.createProjectResultStatement('Output', 1, newObjectiveImp.Id, projectId);        
            act1.ampi__Project_Objective__c = newObjectiveOut.Id;
        }

        insert act1;
        return act1;
    }
    
    public static ampi__Activity__c createActivityWithServiceType(String scheduleId, String name, String typeA, String activityType, String status, String projectId, String serviceType) {
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));

        ampi__Activity__c act1 = new ampi__Activity__c();
        act1.ampi__Implementation_Plan__c = scheduleId;
        act1.Name = name;
        act1.ampi__Type__c = typeA;
        act1.ampi__xx_Activity_Type__c = activityType;
        act1.ampi__status__c = status;
        act1.Activity_ID__c = IntrandomNumber + '';
        act1.Project__c = projectId;
		act1.Thematic_Area__c = serviceType;
        
        if (typeA == 'Results-Based') {
            ampi__Objective__c newObjectiveImp = TestDataFactory.createProjectResultStatement('Impact', 1, '', projectId);
            ampi__Objective__c newObjectiveOut = TestDataFactory.createProjectResultStatement('Output', 1, newObjectiveImp.Id, projectId);        
            act1.ampi__Project_Objective__c = newObjectiveOut.Id;
        }

        insert act1;
        return act1;
    }

    public static ampi__Activity__c createActivityWithDates(String scheduleId, String name, String typeA, String activityType, String status, String projectId, Date actualStartDate, Date actualEndDate, String obj, String activity_Id) {
        ampi__Activity__c act1 = new ampi__Activity__c();
        act1.ampi__Implementation_Plan__c = scheduleId;
        act1.Activity_ID__c = activity_Id;
        act1.Name = name;
        act1.ampi__Type__c = typeA;
        act1.ampi__xx_Activity_Type__c = activityType;
        act1.ampi__status__c = status;
        act1.Project__c = projectId;
        act1.ampi__Actual_Start_Date__c = actualStartDate;
        act1.ampi__Actual_End_Date__c = actualEndDate;
        act1.ampi__Project_Objective__c = obj;
        insert act1;
        return act1;
    }

    public static ampi__Thematic_Area__c createThematicArea(String taName, String description) {
        //ampi__Thematic_Area__c thematicArea = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
        ampi__Thematic_Area__c thematicArea = new ampi__Thematic_Area__c();
        thematicArea.Name = taName; //'YC';
        thematicArea.ampi__Description__c = description; //'Youth Care (similar to YF)';
        thematicArea.ampi__Active__c = true;
        insert thematicArea;
        return thematicArea;
    }

    public static ampi__project_thematic_area__c  createProjectThematicArea(String projectId, String taId, String programmeUnitId) {
        ampi__project_thematic_area__c  pta = new ampi__project_thematic_area__c();
        pta.ampi__project__c = projectId;
        pta.ampi__thematic_area__c = taId;
        if (programmeUnitId != '') {
            pta.Programme_Unit__c = programmeUnitId;
        }
        INSERT pta;
        RETURN pta;
    }

    public static ampi__project_thematic_area__c  createProjectThematicAreaWithISP(String projectId, String taId, String programmeUnitId, String isp) {
        ampi__project_thematic_area__c  pta = new ampi__project_thematic_area__c();
        pta.ampi__project__c = projectId;
        pta.ampi__thematic_area__c = taId;
        pta.ISP_Available__c = isp;
        if (programmeUnitId != '') {
            pta.Programme_Unit__c = programmeUnitId;
        }
        INSERT pta;
        RETURN pta;
    }

    public static List<ampi__project_indicator_reporting_period__c> generatePIRPsByProjectId(String projectId) {
        List<ampi__project_indicator__c> pis = [SELECT Id FROM ampi__project_indicator__c WHERE ampi__project__c =: projectId];
        List<ampi__reporting_period__c> rps = [SELECT Id FROM ampi__reporting_period__c WHERE ampi__project__c =: projectId];
        List<ampi__project_indicator_reporting_period__c> pirp = new List<ampi__project_indicator_reporting_period__c>();

        for(ampi__project_indicator__c pi : pis) {
            for(ampi__reporting_period__c rp : rps) {
                ampi__project_indicator_reporting_period__c newPIRP = new ampi__project_indicator_reporting_period__c();
                newPIRP.ampi__Reporting_Period__c = rp.id;
                newPIRP.ampi__Project_Indicator__c = pi.id;
                pirp.add(newPIRP);
            }
        }
        INSERT pirp;
        RETURN pirp;
    }

    public static List<ampi__project_indicator_geographic_area__c> generatePIGAsByProjectId(String projectId) {
        List<ampi__project_indicator__c> pis = [SELECT Id FROM ampi__project_indicator__c WHERE ampi__project__c =: projectId];
        List<ampi__project_geographic_area__c> pgas = [SELECT Id, ampi__Geographic_Area__r.Id FROM ampi__project_geographic_area__c WHERE ampi__project__c =: projectId];
        List<ampi__project_indicator_geographic_area__c> piga = new List<ampi__project_indicator_geographic_area__c>();

        for(ampi__project_indicator__c pi : pis) {
            for(ampi__project_geographic_area__c pga : pgas) {
                ampi__project_indicator_geographic_area__c newPIGA = new ampi__project_indicator_geographic_area__c();
                newPIGA.ampi__geographic_area__c = pga.ampi__Geographic_Area__r.Id;
                newPIGA.ampi__Project_Indicator__c = pi.id;
                piga.add(newPIGA);
            }
        }
        INSERT piga;
        RETURN piga;
    }

    public static ampi__Project__c createProject(String projectType, String NAId, String ProgrammeId, String thematicAreas) {
        //ampi__Project__c projectStandard = TestDataFactory.createProject('Standard', accNA.Id, gaProgramme.Id, 'FS, YC');
        Account nonDonor = TestDataFactory.createOrganisationWithRecordType('Non SOS Donor Organisation');
        ampi__Project__c pProject = new ampi__Project__c();
        DateTime dt = DateTime.now();
        String dateTimeStr = dt.format('yyyyMMdd');
        //'Standard'
        pProject.Name = 'Test ' + projectType + ' Project ' + dateTimeStr;
        pProject.SOS_Implementing_Organisation__c = NAId; //accNA.Id;
        pProject.Multistage_application__c = 'No';
        pProject.ampi__Project_Status__c = 'In Identification';
        pProject.External_Donor__c = nonDonor.Id;
        pProject.P_PU__c = ProgrammeId; //gaProgramme.Id;
        pProject.Programme_location__c = ProgrammeId; //gaProgramme.Id;
        pProject.Planned_Implementation_Start_Date__c = Date.newinstance(Date.today().year(), 1, 1);
        pProject.ampi__Description__c =  'Test ' + projectType + ' Project ' + dateTimeStr + ' Desc';
        pProject.ampi__Thematic_Area_Text__c = thematicAreas; //'FS, YC';
        pProject.RecordTypeId = ampi__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(projectType).getRecordTypeId();
        insert pProject;
        return pProject;
    }

    public static ampi__Project__c createProjectByStatus(String projectType, String NAId, String ProgrammeId, String status, String transitionProjectType) {
        //String projectType = 'Transition';
        ampi__Project__c pProject = new ampi__Project__c();
        DateTime dt = DateTime.now();
        String dateTimeStr = dt.format('yyyyMMdd');

        pProject.Name = 'Test ' + transitionProjectType + ' Project ' + dateTimeStr;        
        pProject.SOS_Implementing_Organisation__c = NAId;
        pProject.Multistage_application__c = 'No';

        if (status != '')
            pProject.ampi__Project_Status__c = status;

        if (ProgrammeId != '') {
            pProject.Programme_Location__c = ProgrammeId; 
            pProject.P_PU__c = ProgrammeId; 
        }           
        
        if (transitionProjectType != '')
            pProject.Transition_Project_Type__c = transitionProjectType; 

        pProject.ampi__Description__c = 'Test Desc ' + transitionProjectType + ' Project ' + dateTimeStr;       
        pProject.RecordTypeId = ampi__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(projectType).getRecordTypeId();
        insert pProject;
        return pProject;
    }

    public static ampi__Project__c createProjectByName(String name, String projectType, String NAId) {
        ampi__Project__c pProject = new ampi__Project__c();
        Account nonDonor = TestDataFactory.createOrganisationWithRecordType('Non SOS Donor Organisation');
        pProject.External_Donor__c = nonDonor.Id;
        pProject.Name = name;       
        pProject.SOS_Implementing_Organisation__c = NAId;
        pProject.Multistage_application__c = 'No';
        pProject.RecordTypeId = ampi__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(projectType).getRecordTypeId();
        
        insert pProject;
        return pProject;
    }
    
    public static ampi__Project__c createProjectByNameAndProgrammeLocationAndNA(String name, String projectType, String NAId, String programmeLocationId) {
        ampi__Project__c pProject = new ampi__Project__c();
        Account nonDonor = TestDataFactory.createOrganisationWithRecordType('Non SOS Donor Organisation');
        pProject.External_Donor__c = nonDonor.Id;
        pProject.Name = name;       
        pProject.SOS_Implementing_Organisation__c = NAId;
        pProject.Programme_Location__c = programmeLocationId;
        pProject.Multistage_application__c = 'No';
        pProject.RecordTypeId = ampi__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(projectType).getRecordTypeId();
        
        insert pProject;
        return pProject;
    }    

    public static ampi__Project_Geographic_Area__c createPGA(String projectId, String programmeId) { 
        ampi__Project_Geographic_Area__c pgat = new ampi__Project_Geographic_Area__c();
        pgat.ampi__Project__c = projectId;
        pgat.ampi__Geographic_Area__c = programmeId;
        insert pgat;
        return pgat;
    }

    public static void updateProgrammeStatus(ampi__Geographical_Area__c programme, boolean isActive) {
        programme.Active__c = isActive ? 'Yes' : 'No';
        update programme;
    }

    public static List<ampi__Risk_Assessment__c> newRiskAssessment(Account acc, String languageInfo) {
        List<ampi__Risk_Assessment__c> newRiskAssList = new List<ampi__Risk_Assessment__c>();
        Id recordTypeId = Schema.getGlobalDescribe().get('ampi__Risk_Assessment__c').getDescribe().getRecordTypeInfosByName().get('New National Security Context').getRecordTypeId();

            ampi__Risk_Assessment__c newRiskAss = new ampi__Risk_Assessment__c();
            newRiskAss.RecordTypeId = recordTypeId;
            newRiskAss.National_Association__c = acc.Id;
            newRiskAss.National_Association__r = acc;
            newRiskAss.Conflict_Response__c = ' 3.- There may be border disputes or intermittent insurgency operating in the country; there is significant risk of conflict escalation. There may be an indirect threat to INGO staff from localised conflicts.'; 
            newRiskAss.Conflict_Response_Language_1__c = 'Conflict_Response_Language_1__c'; 
            newRiskAss.Conflict_Response_Language_2__c = 'Conflict_Response_Language_2__c'; 
            newRiskAss.Conflict_Response_Language_3__c = 'Conflict_Response_Language_3__c'; 
            newRiskAss.Language_Info__c = languageInfo; 
            newRiskAss.Kidnap_Response__c = '1.- There is low, or no risk of kidnapping or hostage taking. Outlook is stable'; 
            newRiskAss.Kidnap_Response_Language_1__c = 'Kidnap_Response_Language_1__c'; 
            newRiskAss.Kidnap_Response_Language_2__c = 'Kidnap_Response_Language_2__c'; 
            newRiskAss.Kidnap_Response_Language_3__c = 'Kidnap_Response_Language_3__c'; 
            newRiskAss.Infrastructure_Response__c = '   4.- Transport, communications, healthcare and essential services are poorly resourced, and disrupted and failure is common. Safety and reliability standards are absent or not managed.'; 
            newRiskAss.Infrastructure_Response_Language_1__c = 'Infrastructure_Response_Language_1__c'; 
            newRiskAss.Infrastructure_Response_Language_2__c = 'Infrastructure_Response_Language_2__c'; 
            newRiskAss.Infrastructure_Response_Language_3__c = 'Infrastructure_Response_Language_3__c'; 
            newRiskAss.Humanitarian_Space_Response__c = '2.- Humanitarian organsiations can generally operate freely and deliver a wide range of programs with some restrictions from the host Governement and other actors.'; 
            newRiskAss.Humanitarian_Space_Response_Language_1__c = 'Humanitarian_Space_Response_Language_1__c'; 
            newRiskAss.Humanitarian_Space_Response_Language_2__c = 'Humanitarian_Space_Response_Language_2__c'; 
            newRiskAss.Humanitarian_Space_Response_Language_3__c = 'Humanitarian_Space_Response_Language_3__c'; 
            newRiskAss.Crime_Security_Response__c = '   1.- There are low levels of violent crime but there may be varying levels of petty crime in urban or isolated areas. Local secuirty forces are professional, effectively prevent and detect crime and are generally free from corruption'; 
            newRiskAss.Crime_Security_Response_Language_1__c = 'Crime_Security_Response_Language_1__c'; 
            newRiskAss.Crime_Security_Response_Language_2__c = 'Crime_Security_Response_Language_2__c'; 
            newRiskAss.Crime_Security_Response_Language_3__c = 'Crime_Security_Response_Language_3__c';         
            newRiskAss.Conflict_Response__c = 'Conflict_Response__c';  
            newRiskAss.Conflict_Response_Language_1__c = 'Conflict_Response_Language_1__c';  
            newRiskAss.Conflict_Response_Language_2__c = 'Conflict_Response_Language_2__c';  
            newRiskAss.Conflict_Response_Language_3__c = 'Conflict_Response_Language_3__c'; 
            newRiskAss.Social_Political_Response__c = '1.- Location is stable and free of political, economic and civil unrest. There is negligible religious, community, sectarian, racial/tribal and political violence';  
            newRiskAss.Social_Political_Response_Language_1__c = 'Social_Political_Response_Language_1__c';  
            newRiskAss.Social_Political_Response_Language_2__c = 'Social_Political_Response_Language_2__c';  
            newRiskAss.Social_Political_Response_Language_3__c = 'Social_Political_Response_Language_3__c'; 
            newRiskAss.Terrorism_Response__c = '2.- There may be terrorist groups present but they have limited operational capabilities and acts of terrorism are extremely rare';  
            newRiskAss.Terrorism_Response_Language_1__c = 'Terrorism_Response_Language_1__c';  
            newRiskAss.Terrorism_Response_Language_2__c = 'Terrorism_Response_Language_2__c';  
            newRiskAss.Terrorism_Response_Language_3__c = 'Terrorism_Response_Language_3__c';  
            newRiskAssList.add(newRiskAss);
        
        if (newRiskAssList.size() > 0) {
            insert newRiskAssList;
        }

        return newRiskAssList;
    }

    public static Profile GetSystemAdminProfile() {
        return [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
    }

    public static Profile GetSystemCCPProfile() {
        // List<Profile> Profiles = [SELECT Id,Name FROM Profile];
        // for(Profile pf : Profiles) {
        //  System.debug('#####Profile:' + pf.Name);
        // }
        return [SELECT Id FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
    }

    public static Profile GetReadOnlyProfile() {
        return [SELECT Id FROM Profile WHERE Name='Read Only' LIMIT 1];
    }

    public static User CreateUserFromSystemAdminByAlias(string alias) {
        Profile p = GetSystemAdminProfile();
        String uniqueUserName = 'sysadmuser' + DateTime.now().getTime() + '@testorg.com';
        
        User newUser = new User(Alias = alias, Email='systemAdministrator@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        
        insert newUser;
        return newUser;
    }

    public static User CreateUserFromSystemAdmin() {
        Profile p = GetSystemAdminProfile();
        String uniqueUserName = 'sysadmuser' + DateTime.now().getTime() + '@testorg.com';
        
        User newUser = new User(Alias = 'sysadmdt', Email='systemAdministrator@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        
        insert newUser;
        return newUser;
    }

    public static User CreateUserFromCCP(string accountId) {
        Profile p = GetSystemCCPProfile();
        Contact con = new Contact(LastName ='testCon',AccountId = accountId);
        insert con;    

        // String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        // Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        // String hexDigest = EncodingUtil.convertToHex(hash);

        // Create community user
        // User communityUser = new User(FirstName = 'Test', LastName = 'User',
        //                           Email = 'test.user@invalid.com',
        //                           ContactId = con.Id,
        //                           ProfileId = p.Id, UserName = hexDigest + 'test-user@fakeemail.com',
        //                           Alias = 'tuser1', CommunityNickName = hexDigest, TimeZoneSidKey = 'America/New_York',
        //                           LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
                                  
        String uniqueUserName = 'ccp' + DateTime.now().getTime() + '@testorg.com';
        
        User newUser = new User(Alias = 'ccp', Email='ccp@testorg.com', ContactId = con.Id,
             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
             CommunityNickName = 'Testing 123',
             LocaleSidKey='en_US', ProfileId = p.Id,
             TimeZoneSidKey='America/Los_Angeles',
             UserName=uniqueUserName);
        
        insert newUser;
        return newUser;
    }

    
    public static User CreateUserFromSystemAdminSpanish() {
        Profile p = GetSystemAdminProfile();
        String uniqueUserName = 'sysadmuser' + DateTime.now().getTime() + '@testorg.com';
        
        User newUser = new User(Alias = 'sysadmsp', Email='systemAdministrator@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='es',
        LocaleSidKey='es', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        
        insert newUser;
        return newUser;
    }

    public static User CreateUserFromSystemAdminFrench() {
        Profile p = GetSystemAdminProfile();
        String uniqueUserName = 'sysadmuser' + DateTime.now().getTime() + '@testorg.com';
        
        User newUser = new User(Alias = 'sysadmfr', Email='systemAdministrator@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='fr',
        LocaleSidKey='fr', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        
        insert newUser;
        return newUser;
    }

    public static User CreateUserFromSystemAdminRussian() {
        Profile p = GetSystemAdminProfile();
        String uniqueUserName = 'sysadmuser' + DateTime.now().getTime() + '@testorg.com';
        
        User newUser = new User(Alias = 'sysadmru', Email='systemAdministrator@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='ru',
        LocaleSidKey='ru', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        
        insert newUser;
        return newUser;
    }

    
    public static User CreateUserFromReadOnly() {
        Profile p = GetReadOnlyProfile();
        String uniqueUserName = 'readonlyUser' + DateTime.now().getTime() + '@testorg.com';
        
        User newUser = new User(Alias = 'sysread', Email='readonly@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        
        insert newUser;
        return newUser;
    }

    public static Contact createContact(string email) {
        Contact newContact = new Contact();
        newContact.FirstName =  'Test firstname contact ' + getCurrentDateString();
        newContact.LastName =  'Test lastname contact ' + getCurrentDateString();
        newContact.Description = 'Test description contact ' + getCurrentDateString();
        newContact.Email = email;
        insert newContact;  
        return newContact;
    }

    public static Team_member__c createTeammember(string projectId, string userId, string role, string naId) {
    //role = 'Project Contributor'
        Team_member__c tm = new Team_member__c();
        tm.Project__c = projectId;
        tm.User__c = userId;
        tm.Role__c = role;
        tm.Active__c = true;
        tm.Organisation__c = naId;
        INSERT tm;
        return tm;
    }


    public static Account createOrganisation(string contactId) {
        Account newAccount = new Account();
        newAccount.Name= 'Test name organisation ' + getCurrentDateString();
        if (String.isNotBlank(contactId)) {
            newAccount.NA_Director__c = contactId;
            newAccount.NA_Risk_Reviewer__c = contactId;
        }
        insert newAccount;
        return newAccount;
    }

    public static Account createOrganisationWithRecordType(string recordTypeName) {
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Account newAccount = new Account();
        newAccount.Name= 'Test name organisation ' + getCurrentDateString();
        newAccount.RecordTypeId = recordTypeId;
        insert newAccount;
        return newAccount;
    }

    public static String getCurrentDateString() {
        date currentToday = date.today();
        Datetime currentDate = Datetime.newInstance(currentToday.year(), currentToday.month(), currentToday.day());
        return currentDate.format('yyyy-MM-dd');

    }

    public static ampi__Project_Indicator__c createProjectIndicator(String indicatorName, String projectId) {
        return createProjectIndicator(indicatorName, projectId, 'Statistics Handbook Version 3 2022');
    }

    public static ampi__Project_Indicator__c createProjectIndicator(String indicatorName, String projectId, String sourceDocument) {
        ampi__Indicator__c ind = new ampi__Indicator__c();
        ind.ampi__Cross_Disaggregation_by_Sex__c = false;
        ind.ampi__Cumulative__c = false;
        ind.ampi__Data_Type__c = 'Number';
        ind.ampi__Description__c = indicatorName;
        ind.ampi__Geographical_Disaggregation__c = 'Programme';
        ind.ampi__Reporting_Frequency__c = 'Monthly';
        ind.ampi__Target_Frequency__c = 'Monthly';
        ind.ampi__Targets_Are_Disaggregated__c = false;
        ind.ampi__Type_of_Results__c = 'Input';
        ind.Source_Document__c = sourceDocument;
        insert ind;

        ampi__Project_Indicator__c  pi = new ampi__Project_Indicator__c();
        pi.ampi__Reporting_Frequency__c = 'Monthly';
        pi.ampi__Geographical_Disaggregation__c = 'Programme';
        pi.ampi__Target_Frequency__c = 'Monthly';
        pi.ampi__Type_of_Results__c = 'Input';
        pi.ampi__Catalog_Indicator__c = ind.id;
        pi.ampi__project__c = projectId;
        insert pi;
        return pi;
    }

    public static ampi__Risk__c createRisk(String riskName, String programmeId, String MAId, Boolean includeSafety, String riskRegisterId) {
        Id recordTypeId = Schema.getGlobalDescribe().get('ampi__Risk__c').getDescribe().getRecordTypeInfosByName().get('Programme Location Risk').getRecordTypeId();
        ampi__Risk__c gaRisk = new ampi__Risk__c();
        gaRisk.Name = riskName;
        if(includeSafety) {
            gaRisk.Catalogue_Type__c = 'Safety and Security Risks';
        }
        gaRisk.RecordTypeId = recordTypeId;
        gaRisk.Programme_Location__c = programmeId; //gaCountry.Id;
        if (String.isNotBlank(riskRegisterId)) {
            gaRisk.ampi__Risk_Register__c = riskRegisterId;
        }
        insert gaRisk;
        return gaRisk;
    }

    
    public static ampi__Risk_Register__c createRiskRegister(String riskName, String programmeId) {
        ampi__Risk_Register__c gaRisk = new ampi__Risk_Register__c();
        gaRisk.Programme__c = programmeId;
        gaRisk.Name = riskName;
        insert gaRisk;
        return gaRisk;
    }

    public static ampi__result__c createReults(decimal value, String pirp, String piga, String indicator) {
        return new ampi__result__c(ampi__Target_Value__c = value, 
                                                   ampi__Results_Current_As_Of__c = Date.today(),
                                                   ampi__Target_Created_Date__c = Datetime.now(),
                                                   ampi__Target_Last_Modified_Date__c = Datetime.now(),
                                                   ampi__Project_Indicator_Reporting_Period__c = pirp,
                                                   ampi__Project_Indicator_Geographic_Area__c = piga,
                                                   ampi__Project_Indicator__c =  indicator,
                                                   ampi__Data_Tracked__c = 'Both');
    }
}