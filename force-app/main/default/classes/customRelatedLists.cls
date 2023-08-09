public without sharing class customRelatedLists  {

    @AuraEnabled(cacheable=true)
    public static String getRiskApproverAndReviewerByOrganisationId(String organisationId, Boolean includeProfile) {
        List<Account> soqlData = [SELECT NA_Risk_Reviewer__r.email, NA_Director__r.email
                FROM Account 
                WHERE Id =: organisationId];
        
        String result = '';
        for(Account currentRecord : soqlData) {
            if (currentRecord.NA_Risk_Reviewer__r.email == UserInfo.getUserEmail()) {
                result = 'Reviewer';
            }
            if (currentRecord.NA_Director__r.email == UserInfo.getUserEmail()) {
                result += '/Approver';
            }
        } 

        if (includeProfile) {
            String profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
            result += '/' + profileName;
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static String getOrganisationIdByProgrammeId(String programmeId) {
        List<ampi__Geographical_Area__c> soqlData = [SELECT Parent_MA__c
                FROM ampi__Geographical_Area__c 
                WHERE Id =: programmeId];
        
        for(ampi__Geographical_Area__c currentRecord : soqlData) {
            return currentRecord.Parent_MA__c;
        } 

        return '';
    }

    @AuraEnabled(cacheable=true)
    public static List<RelatedPGAListWrapper> getProjectGeographicAreaByProjectId(String projectId, Integer maxRecords, Integer offSetCount) {
        List<ampi__Project_Geographic_Area__c> soqlData = [SELECT Id, ampi__Geographic_Area__r.ampi__Type__c,
                    ampi__Geographic_Area__r.Name, ampi__Geographic_Area__r.Active__c,
                    ampi__Geographic_Area__r.Long_Name__c, ampi__Geographic_Area__r.Pillar__c
                FROM ampi__Project_Geographic_Area__c 
                WHERE ampi__Project__r.Id =: projectId  AND ampi__Geographic_Area__r.Active__c = 'Yes'
                ORDER BY ampi__Geographic_Area__r.Name ASC LIMIT :maxRecords OFFSET :offSetCount];
        
        List<RelatedPGAListWrapper> data = new List<RelatedPGAListWrapper>();

        for(ampi__Project_Geographic_Area__c currentRecord : soqlData) {
            RelatedPGAListWrapper item = new RelatedPGAListWrapper(currentRecord);
            data.add(item);
        } 
        return data;
    }

    @AuraEnabled(cacheable=true)
    public static List<ampi__Risk_Register__c> getRiskRegisterByProgrammeId(String programmeId, Integer maxRecords, Integer offSetCount) {
        List<ampi__Risk_Register__c> soqlData = [SELECT Name, Status__c, Programme__r.Parent_MA__c FROM ampi__Risk_Register__c 
                WHERE Programme__c =: programmeId
                ORDER BY Name ASC 
                LIMIT :maxRecords OFFSET :offSetCount];
        
        return soqlData;
    }

    @AuraEnabled(cacheable=true)
    public static List<ampi__Risk_Assessment__c> getRiskAssessmentByMAId(String maId, Integer maxRecords, Integer offSetCount) {
        List<ampi__Risk_Assessment__c> soqlData = [SELECT Name, Status__c, National_Association__c FROM ampi__Risk_Assessment__c 
                WHERE National_Association__c =: maId
                ORDER BY Name ASC 
                LIMIT :maxRecords OFFSET :offSetCount];
        
        return soqlData;
    }


    @AuraEnabled(cacheable=true)
    public static List<RelatedProjectListWrapper> getProjectsByOrganisationId(String organisationId, Integer maxRecords, Integer offSetCount) {

        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        List<ampi__Project__c> soqlData= null;

        if(profileName == 'System Administrator') {
            soqlData = [SELECT Id, Name ,ampi__Description__c, RecordType.Name, ampi__Start_Date__c
                    FROM ampi__Project__c 
                    WHERE SOS_Implementing_Organisation__c =: organisationId LIMIT :maxRecords OFFSET :offSetCount];
        } else {
           soqlData = [SELECT Id, Name ,ampi__Description__c, RecordType.Name, ampi__Start_Date__c
                    FROM ampi__Project__c 
                    WHERE SOS_Implementing_Organisation__c =: organisationId
                    and RecordType.Name <> 'Shadow Project' LIMIT :maxRecords OFFSET :offSetCount];
        }
        
        boolean isInternalLink = isInternal();

        List<RelatedProjectListWrapper> data = new List<RelatedProjectListWrapper>();

        for(ampi__Project__c currentRecord : soqlData) {
            RelatedProjectListWrapper item = new RelatedProjectListWrapper(currentRecord, isInternalLink);
            data.add(item);
        } 
            
        return data;
    }

    @AuraEnabled(cacheable=true)
    public static List<RelatedGAListWrapper> getGeographicAreaByAccountId(String accountId, Boolean programmesVisible, Boolean programmeUnitsVisible, Boolean nationalManagementUnitsVisible, Integer maxRecords, Integer offSetCount) {
        List<ampi__Geographical_Area__c> soqlData = [SELECT Id, ampi__Type__c,
                        Code__c, Name, Program_Unit_type__c, Active__c
                    FROM ampi__Geographical_Area__c 
                    WHERE Parent_MA__c =: accountId AND Active__c = 'Yes'
                    ORDER BY ampi__Type__c ASC, Name ASC
                    LIMIT :maxRecords OFFSET :offSetCount];
        
        List<RelatedGAListWrapper> data = new List<RelatedGAListWrapper>();
        String MAName = getMAName(accountId);
        boolean isInternalLink = isInternal();

        while (soqlData.size() > 0) {
            List<Id> ids = new List<Id>();
            for(ampi__Geographical_Area__c currentRecord : soqlData) {
                    if ((programmesVisible == true && currentRecord.ampi__Type__c == 'Programme') || 
                        (programmeUnitsVisible == true && currentRecord.ampi__Type__c == 'Programme Unit') ||
                        (nationalManagementUnitsVisible == true && currentRecord.ampi__Type__c == 'National Management Unit')) {
                        RelatedGAListWrapper item = new RelatedGAListWrapper(currentRecord, isInternalLink);
                        item.ParentId = accountId;
                        if (!isInternalLink) {
                            item.ParentNameUrl = '/geographical-area/' + accountId;
                        } else {
                            item.ParentNameUrl = '/lightning/r/ampi__Geographical_Area__c/' + accountId + '/view/';
                        }
                        item.ParentName = MAName;
                        data.add(item);
                        ids.add(currentRecord.ID);
                    }
            }

            soqlData = [SELECT Id, ampi__Type__c,
                        Code__c, Name, Program_Unit_type__c, Active__c
                    FROM ampi__Geographical_Area__c 
                    WHERE Parent_MA__c IN: ids AND Active__c = 'Yes'
                    ORDER BY ampi__Type__c ASC, Name ASC];
        }
        return data;
    }

    @AuraEnabled(cacheable=true)
    public static String getDescriptionRiskDatafieldName() {
        User u = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id = :UserInfo.getUserId()];        
        //User u = [SELECT FirstName FROM User WHERE Id = :UserInfo.getUserId()];        
        
        //String shortLanguageCode = u.FirstName; 
        String shortLanguageCode = u.LanguageLocaleKey.trim();    
        if (shortLanguageCode == 'Español') {
              return 'Risk_Description_Language_1__c';
        } else if (shortLanguageCode == 'Français') {
              return 'Risk_Description_Language_2__c';
        } else if (shortLanguageCode == 'Русский') {
              return 'Risk_Description_Language_3__c';
        } else {
            return 'ampi__Description__c';
        }
        //return 'ampi__Description__c';
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRisksByProgrammeId(String programmeId, String category, Boolean includeCatalogueRisk, Integer maxRecords, Integer offSetCount) {
        //List<RelatedRiskListWrapper> data = new List<RelatedRiskListWrapper>();
        List<SObject> data = new List<SObject>();
        string description_field = getDescriptionRiskDatafieldName();

        string fields = 'Id, ' + description_field + ', toLabel(ampi__Category__c), Risk_Value__c, Risk_Name_Translated__c, Probability_Value__c, Impact_Value__c ';
        string filters = ' Programme_Location__c = \'' + programmeId + '\'';
        string catalogueSafety = 'Safety and Security Risks';

        if (includeCatalogueRisk == true) {
            filters += ' AND Catalogue_Type__c = \''  + catalogueSafety + '\'';
        } else {
            filters += ' AND Catalogue_Type__c <> \''  + catalogueSafety + '\'';
        }   

        if (!String.isBlank(category)) {
            filters += ' AND ampi__Category__c = \'' + category + '\'';
        }
        
        try {
            data = getResultsQueryDynamicWithSorting('ampi__Risk__c',fields,filters,maxRecords,offSetCount, 'Risk_Name_Translated__c ASC');
        }
        catch(DmlException e) 
        {
            System.debug('#### ERROR: ' + e.getMessage());
        }
        return data;
    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> getRisksByRiskRegisterId(String riskRegisterId, String category, Integer maxRecords, Integer offSetCount) {
        List<SObject> data = new List<SObject>();
        string description_field = getDescriptionRiskDatafieldName();
        
        string fields = 'Id, ' + description_field + ', toLabel(ampi__Category__c), Risk_Value__c, Risk_Name_Translated__c, Probability_Value__c, Impact_Value__c ';
        string filters = ' ampi__Risk_Register__c = \'' + riskRegisterId + '\'';

        if (!String.isBlank(category)) {
            filters += ' AND ampi__Category__c = \'' + category + '\'';
        }
        
        try {
            data = getResultsQueryDynamicWithSorting('ampi__Risk__c', fields, filters, maxRecords, offSetCount, 'Risk_Name_Translated__c ASC');
        }
        catch(DmlException e) 
        {
            System.debug('#### ERROR: ' + e.getMessage());
        }
        return data;
    }
    
    @AuraEnabled(cacheable=true)
    public static integer getNumberOfRiskRegisterByProgrammeId(String programmeId) {
        integer totalCount = 0;
        string filters = ' Programme__c = \'' + programmeId + '\'';
        
        try {
            totalCount = getNumberResultsQueryDynamic('ampi__Risk_Register__c', filters);
        }
        catch(DmlException e) 
        {
            System.debug('#### ERROR: ' + e.getMessage());
        }
        return totalCount;
    }

    @AuraEnabled(cacheable=true)
    public static integer getNumberOfRiskAssessmentByMAId(String maId) {
        integer totalCount = 0;
        string filters = ' National_Association__c = \'' + maId + '\'';
        
        try {
            totalCount = getNumberResultsQueryDynamic('ampi__Risk_Assessment__c', filters);
        }
        catch(DmlException e) 
        {
            System.debug('#### ERROR: ' + e.getMessage());
        }
        return totalCount;
    }

    @AuraEnabled(cacheable=true)
    public static integer getNumberOfRisksByRiskRegisterId(String riskRegisterId, String category) {
        integer totalCount = 0;

        string filters = ' ampi__Risk_Register__c = \'' + riskRegisterId + '\'';
        
        if (!String.isBlank(category)) {
            filters += ' AND ampi__Category__c = \'' + category + '\'';
        }
        try {
            totalCount = getNumberResultsQueryDynamic('ampi__Risk__c', filters);
        }
        catch(DmlException e) 
        {
            System.debug('#### ERROR: ' + e.getMessage());
        }
        return totalCount;
    }

    @AuraEnabled(cacheable=true)
    public static integer getNumberRisksByProgrammeId(String programmeId, String category, Boolean includeCatalogueRisk) {
        integer totalCount = 0;

        string filters = ' Programme_Location__c = \'' + programmeId + '\'';
        string catalogueSafety = 'Safety and Security Risks';

        if (includeCatalogueRisk == true) {
            filters += ' AND Catalogue_Type__c = \''  + catalogueSafety + '\'';
        } else {
            filters += ' AND Catalogue_Type__c <> \''  + catalogueSafety + '\'';
        }   

        if (!String.isBlank(category)) {
            filters += ' AND ampi__Category__c = \'' + category + '\'';
        }
        
        try {
            totalCount = getNumberResultsQueryDynamic('ampi__Risk__c',filters);
        }
        catch(DmlException e) 
        {
            System.debug('#### ERROR: ' + e.getMessage());
        }
        return totalCount;
    }

    @AuraEnabled(cacheable=true)
    public static String getMAName(String accountId) {
        List<Account> soqlData = [SELECT Name
                FROM Account 
                WHERE Id =: accountId];
        
        for(Account currentRecord : soqlData) {
            return currentRecord.Name;
        } 
        return '';
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordTypeIdByName(String name) {
        List<RecordType> soqlData = [SELECT id from RecordType where Name =: name];
        
        for(RecordType currentRecord : soqlData) {
            return currentRecord.id;
        } 
        return '';
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isInternal() {
        System.debug('####URL.getSalesforceBaseUrl().toExternalForm():' + URL.getSalesforceBaseUrl().toExternalForm());
        return URL.getSalesforceBaseUrl().toExternalForm().contains('.salesforce.com');
    }

    public static List<sObject> getResultsQueryDynamic(String objectName, String datafields, String filters, integer limitNumber, integer offsetCount) {
        String query = 'SELECT ' + datafields + ' FROM ' + objectName + ' '; 
        String whereClause = '';
        if (String.isNotEmpty(filters)) {
            if (String.isNotEmpty(filters)){
                whereClause += filters;
            }

            if (String.isNotEmpty(whereClause)) {
                query += ' WHERE ' + whereClause;
            }

            if (limitNumber > 0) {
                query += ' LIMIT ' + limitNumber;
            }

            if (offsetCount > 0) {
                query += ' OFFSET ' + offsetCount;
            }
        }
        System.debug('##### QUERY: ' + query);
        return Database.query(query);
    }

    public static List<sObject> getResultsQueryDynamicWithSorting(String objectName, String datafields, String filters, integer limitNumber, integer offsetCount, string sortedBy) {
        String query = 'SELECT ' + datafields + ' FROM ' + objectName + ' '; 
        String whereClause = '';
        if (String.isNotEmpty(filters)) {
            if (String.isNotEmpty(filters)){
                whereClause += filters;
            }

            if (String.isNotEmpty(whereClause)) {
                query += ' WHERE ' + whereClause;
            }

            if (String.isNotEmpty(sortedBy)) {
                query += ' ORDER BY ' + sortedBy;
            }

            if (limitNumber > 0) {
                query += ' LIMIT ' + limitNumber;
            }

            if (offsetCount > 0) {
                query += ' OFFSET ' + offsetCount;
            }
        }
        System.debug('##### QUERY: ' + query);
        return Database.query(query);
    }

    public static integer getNumberResultsQueryDynamic(String objectName, String filters) {
        String query = 'SELECT Count() FROM ' + objectName + ' '; 
        String whereClause = '';
        if (String.isNotEmpty(filters)) {
            if (String.isNotEmpty(filters)){
                whereClause += filters;
            }

            if (String.isNotEmpty(whereClause)) {
                query += ' WHERE ' + whereClause;
            }
        }
        System.debug('##### QUERY: ' + query);
        return Database.countQuery(query);
    }
    
    public class RelatedPGAListWrapper{
        @AuraEnabled
        public String Name { get; set;}
        @AuraEnabled
        public String LongName  { get; set;}
        @AuraEnabled 
        public Boolean IsActive { get; set;}
        @AuraEnabled
        public String Type { get; set;}
        @AuraEnabled
        public String Pillar { get; set;}
        @AuraEnabled
        public String ID { get; set;}
        public RelatedPGAListWrapper(ampi__Project_Geographic_Area__c record){
            this.Name = record.ampi__Geographic_Area__r.Name;
            this.LongName = record.ampi__Geographic_Area__r.Long_Name__c;
            this.IsActive = (record.ampi__Geographic_Area__r.Active__c == 'Yes');
            this.Type = record.ampi__Geographic_Area__r.ampi__Type__c;
            this.Pillar = record.ampi__Geographic_Area__r.Pillar__c;
            this.ID = record.ID;
        }
    }

    public class RelatedGAListWrapper{
        @AuraEnabled
        public String Name { get; set;}
        @AuraEnabled
        public String NameUrl { get; set;}
        @AuraEnabled
        public String LongName  { get; set;}
        @AuraEnabled 
        public String ParentId  { get; set;}
        @AuraEnabled
        public String ParentName  { get; set;}
        @AuraEnabled
        public String ParentNameUrl  { get; set;}
        @AuraEnabled
        public Boolean IsActive { get; set;}
        @AuraEnabled
        public String Type { get; set;}
        @AuraEnabled
        public String ProgramUnitType { get; set;}
        @AuraEnabled
        public String ID { get; set;}

        public RelatedGAListWrapper(ampi__Geographical_Area__c record, boolean isInternalLink){
            this.Name = record.Name;
            if (!isInternalLink) {
                this.NameUrl = '/geographical-area/' + record.ID;
            } else {
                this.NameUrl = '/lightning/r/ampi__Geographical_Area__c/' + record.ID + '/view/';
            }
            this.LongName = record.Code__c + ' ' + record.Name;
            this.IsActive = (record.Active__c == 'Yes');
            this.Type = record.ampi__Type__c;
            this.ProgramUnitType = record.Program_Unit_type__c;
            this.ID = record.ID;
        }
    }

    public class RelatedProjectListWrapper{
        @AuraEnabled
        public String Name { get; set;}
        @AuraEnabled
        public String NameUrl { get; set;}
        @AuraEnabled
        public String ID { get; set;}
        @AuraEnabled
        public String Description  { get; set;}
        @AuraEnabled
        public Date ProjectStartDate  { get; set;}

        public RelatedProjectListWrapper(ampi__Project__c record, boolean isInternalLink){
            this.Name = record.Name;
            if (!isInternalLink) {
                this.NameUrl = '/project/' + record.ID;
            } else {
                this.NameUrl = '/lightning/r/ampi__Project__c/' + record.ID + '/view/';
            }
            this.Description = record.ampi__Description__c;
            this.ProjectStartDate   =record.ampi__Start_Date__c;
        }
    }
}