public without sharing class GenerateMigrationDatafields  {
	public MetadataService.MetadataPort service { get; set;}
	public Map<String,String> objectMap { get; set;}
    
    /*EXECUTE ON APEX
    GenerateMigrationDatafields util = new GenerateMigrationDatafields();
 	//util.DeleteRecords(); //REMOVE CURRENT RECORDS
	util.CreateUniqueDatafield(); //CREATE FIELDS
    util.SetFieldPermission();	//SET PERMISSION TO CURRENT USER PROFILE
    util.UpdateUniquefieldValue('1000', 1); //SET VALUES
 
	*/
	public GenerateMigrationDatafields  (){
		service = GetMetadataPort();
		objectMap = GetAllCustomObjectNames();
	}	

	public MetadataService.MetadataPort GetMetadataPort() {
		MetadataService.MetadataPort serviceInit = new MetadataService.MetadataPort();  
		serviceInit.SessionHeader = new MetadataService.SessionHeader_element();
		serviceInit.SessionHeader.sessionId = UserInfo.getSessionId();
		return serviceInit;
	}
	
	public Map<String,String> GetAllCustomObjectNames() {
		Map<String,String> objects = new Map<String,String>();
    
		for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
				   String name = objTyp.getDescribe().getName();
				   String label = objTyp.getDescribe().getLabel();
				   if(!name.containsignorecase('tag') && !name.containsignorecase('history') && 
						!name.containsignorecase('feed') && 
               			!name.containsignorecase('public') &&
                        //!name.containsignorecase('group') && 
                        //!name.containsignorecase('share') && 
						!objTyp.getDescribe().isCustomSetting() && objTyp.getDescribe().isCreateable() &&
						objTyp.getDescribe().getRecordTypeInfos().size() > 0 &&
						//name.toLowerCase().right(3) ==  '__c' && 
                        name.toLowerCase().left(6) ==  'ampi__'){      
							objects.put(name,label);
				   }
		}
		objects.put('Account', 'Organisation');
        objects.put('SOS_DAC_Code_Tag__c','SOS & DAC Code Tag');
        objects.put('SOS_DAC_Codes__c','SOS & DAC Code');
		return objects;
	}

	public void CreateUniqueDatafield() {
		//1.- LIST ALL CUSTOM OBJECTS
		List<MetadataService.Metadata> fields = new List<MetadataService.Metadata>();
		
		///2. CREATE NEW UNIQUE DATAFIELD
		for(String objectName : objectMap.keySet()) {
				String[] types = new String[]{objectName};
				Schema.DescribeSobjectResult[] allFields = Schema.describeSObjects(types);
    			//System.debug('#####DEBUG ALL FIELDS FROM CUSTOM OBJECTS:'+allFields);
				boolean fieldExists = false;
				for(Schema.DescribeSobjectResult res : allFields) {
					if(res.getLabel() == 'unique field') {
						fieldExists = true;
					}
				}
				//System.debug('#####DEBUG FIELD EXISTS:'+fieldExists);
				if (!fieldExists) {
					fields = new List<MetadataService.Metadata>();
					MetadataService.CustomField customField = new MetadataService.CustomField();        
					string customFieldName = 'unique_field';
					string customFieldLabel = 'unique field';
					customField.fullName = objectName + '.' + customFieldName + '__c';
					customField.label = customFieldLabel;
					customField.defaultvalue = '';
					//customField.sharingModel = 'ReadWrite';
					customField.type_x = 'Text';
					customField.length = 60; 
					customField.externalId = true;
					customField.unique = true;
					fields.add(customField);        
					//System.debug('#####DEBUG NEW CUSTOM FIELD IN OBJECT:'+ objectName + ' / ' +customField);
					MetadataService.SaveResult[] results = service.createMetadata(fields);
				}
		}
	}

		
	/*
	1.- Set Field Access Permission to "activity" custom object and "unique field" datafield set field to security to "System Administrator"
    2.- Search the permission and copy the parentID
    SELECT Field,
        Id,
        ParentId,
        PermissionsEdit,
        PermissionsRead,
        SobjectType,
        SystemModstamp
    FROM FieldPermissions WHERE Field = 'ampi__Activity__c.unique_field__c'  // ParentId='0PS1i0000000CkcGAE'
    
    3.- Run this apex code and replace the text //COPY PARENT ID HERE with the parent ID from the query*/
    public void SetFieldPermission() {
        List<FieldPermissions> fpListToInsert = new List<FieldPermissions>();
        for(String objectName : objectMap.keySet()) {
            List<FieldPermissions> fpList = Database.query('SELECT SobjectType, Field, PermissionsRead, PermissionsEdit, Parent.ProfileId FROM FieldPermissions WHERE SobjectType = \'' + objectName + '\' and Field= \'' + objectName + '.unique_field__c\' AND Parent.ProfileId=\'' +Userinfo.getProfileId() + '\'');
            if(fpList.isEmpty()){
                FieldPermissions fp= new FieldPermissions();
                fp.Field=objectName + '.unique_field__c';//the name of new field
                fp.ParentId='0PS1i0000000CkcGAE';//COPY PARENT ID HERE
                fp.PermissionsEdit=true;//
                fp.PermissionsRead=true;
                fp.SobjectType=objectName;
                fpListToInsert.add(fp); 
            } 
        }
        
        if (fpListToInsert.size() > 0) {
            upsert fpListToInsert;    
        }
    }
    
    //Before, must deactivate validation rules, triggers and process builders, after that you must activate them
	//4. UPDATE FIELDS
	public void UpdateUniquefieldValue(String limitQuery, Integer maxRecordsOnCustomObject) {
        if (!String.isNotBlank(limitQuery)) {
            limitQuery = '1000';
        }
        
        if (maxRecordsOnCustomObject <= 0) {
           maxRecordsOnCustomObject = 1;
        }
        
        if (maxRecordsOnCustomObject > 10) {
           maxRecordsOnCustomObject = 10;
        }
        
		List<sObject> updateObjects = new List<sObject>();
        Integer count = 0;
		for(String objectName : objectMap.keySet()) {
            count++;
			List<sObject> objectsFound = Database.query('SELECT Id, unique_field__c FROM '+objectName+' WHERE unique_field__c = NULL OR unique_field__c = \'\' LIMIT ' + limitQuery + ' FOR UPDATE');
			for (sObject currentObject : objectsFound) {
					SObject updateObj = SetUniquefieldValue(currentObject, 'unique_field__c', GenerateGuid());
					updateObjects.add(updateObj);
			}
            if(count >= maxRecordsOnCustomObject) {
                if (updateObjects.size() > 0) {
                    update updateObjects;		
                    //integer missing= database.countQuery('select count() from '+objectName+' WHERE unique_field__c = NULL OR unique_field__c = \'\'');
					//system.debug('the count is '+ missing);
                    updateObjects = new List<sObject>();
                }
                count = 0;
            }
		}
        if (updateObjects.size() > 0) {
			update updateObjects;		
        }
	}

	public void DeleteRecords() {
		for(String objectName : objectMap.keySet()) 
		{
			String query = 'SELECT Id FROM ' + objectName;
			for(List<Sobject> rec : Database.query(query)) 
			{ 
				Database.delete(rec); 
			}
		}
	}
    
	public sObject SetUniquefieldValue(sObject currentObject, String fieldname, String value) {
		Id idToUpdate = (Id)currentObject.get('Id');
		SObject o1 = idToUpdate.getSObjectType().newSObject(idToUpdate);
		o1.put(fieldname, value);
		return o1;		
	}
    
	public String GenerateGuid() {
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
	}
    
    
    public String GenerateScript(String objectName, String field) {
        String script = 'List<' + objectName + '> accts = [Select Name From ' + objectName + '];';
		script += 'for(' + objectName + ' acct : accts)';
		script += 'acct.' + field + ' = util.GenerateGuid();';
        script += 'update accts;';
        return script; 
    }
}