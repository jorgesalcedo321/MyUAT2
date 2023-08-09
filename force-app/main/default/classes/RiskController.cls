public with sharing class RiskController  {
     @AuraEnabled(cacheable=true)
     public static Boolean checkIfUserCanEditDatafield(string objectName, String datafield) {
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        DescribeFieldResult datafieldDesc = mapFields.get(datafield).getDescribe();
        return datafieldDesc.isUpdateable();
     }
    
     @AuraEnabled(cacheable=true)
     public static Boolean checkIfUserCanEditObject(string objectName) {
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);     
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        return objDescribeSobject.isUpdateable();
     }
    
    @AuraEnabled(cacheable=true)
     public static Boolean checkIfUserCanDeleteObject(string objectName) {
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);     
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        return objDescribeSobject.isDeletable();
     }
    
     @AuraEnabled(cacheable=true)
     public static Boolean checkIfUserCanCreateObject(string objectName) {
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);     
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        return objDescribeSobject.isCreateable();
     }
        
     @AuraEnabled(cacheable=true)
     public static Boolean checkIfUserCanAccessObject(string objectName) {
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);     
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        return objDescribeSobject.isAccessible();
     }

     @AuraEnabled(cacheable=true)
     public static List<sObject> getSystemInfoFromObject(String objectName, String recordId) {
        String query = 'SELECT Id, CreatedDate, LastModifiedDate FROM ' + objectName + ' WHERE Id = \'' + recordId + '\''; 
        System.debug('##### QUERY: ' + query);
        return Database.query(query);
    }

     @AuraEnabled(cacheable=true)
     public static List<String> getPickListValuesFromDatafield(String objectName, String picklistDatafield){
        System.debug('### getPickListValuesFromDatafield : ' + objectName);
        System.debug('### getPickListValuesFromDatafield 2: ' + picklistDatafield);
        List<String> pickListValuesList= new List<String>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(picklistDatafield).getDescribe().getPickListValues();

        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            pickListValuesList.add(objPickList.getLabel());
        }
        System.debug('### getPickListValuesFromDatafield 3: ' + pickListValuesList);
        //create a picklist color for each field 
        return pickListValuesList;
    }


    @AuraEnabled(cacheable=true)
     public static String getLabelFromDatafield(String objectName, String datafield){
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        DescribeFieldResult datafieldDesc = mapFields.get(datafield).getDescribe();
        return datafieldDesc.getLabel();
    }

    @AuraEnabled(cacheable=true)
     public static String getHelpTextFromDatafield(String objectName, String datafield){
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        DescribeFieldResult datafieldDesc = mapFields.get(datafield).getDescribe();
        return datafieldDesc.getInlineHelpText();
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean isSOSOrganisationMA(String objectName, String accountId) {
    List<Account> accountList = [SELECT RecordTypeId 
                                 FROM Account 
                                 WHERE Id =: accountId
                                 WITH SECURITY_ENFORCED];

        if (accountList.size() > 0) {
            String recordTypeId = accountList[0].RecordTypeId;
            String recordTypeName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();

            if (recordTypeName == 'SOS Organisation - MA') {
                return true;
            }
        }
        return false;
    }

    @AuraEnabled()
    public static String updateAddressFromPUs(String puId, String addressId, boolean isAdditional) {
        List<ampi__geographical_area__c> pus = [SELECT Id, Address__c, Additional_address__c FROM ampi__geographical_area__c WHERE Id =: puId];

        if (pus.size() > 0) {
            try{
                if (!isAdditional) {
                    pus[0].address__c = addressId;
                } else {
                    pus[0].Additional_address__c = addressId;
                }
                UPDATE pus;     
                return '';
            } catch(Exception ex) {
                return ex.getMessage();
            }
        }
        return 'P&PU not found to update';
    }

    @AuraEnabled()
    public static String updateCorrespondanceAddressFromPU(String puId, String correspondanceAddress) {
        List<ampi__geographical_area__c> pus = [SELECT Id, Corresponding_address_different__c FROM ampi__geographical_area__c WHERE Id =: puId];

        if(pus.size() > 0){
            pus[0].Corresponding_address_different__c = correspondanceAddress;
            try{
                UPDATE pus;     
                return '';
            } catch(Exception ex) {
                return ex.getMessage();
            }
        }

        return 'P&PU not found';
    }

    @AuraEnabled()
    public static List<Address__c> getAddressFromPUs(String puId, boolean isAdditional) {
        List<ampi__geographical_area__c> pus = [SELECT Id, Address__c, Additional_address__c, Parent_MA__r.Address__c FROM ampi__geographical_area__c WHERE Id =: puId];

        if (pus.size() == 0) {
            return null;
        }

        ampi__geographical_area__c currentPU = pus[0];

        if (!isAdditional) {
            if (currentPU.Address__c <> null && currentPU.Address__c == currentPU.Parent_MA__r.Address__c) {
                return [SELECT Id, City__c, Country__c, District__c, Phone__c, Fax__c, Name, Post_Box__c, Post_Box_City__c, Post_Box_Country__c, Post_Box_Postal_Code__c, Postal_Code__c, Region_Coiuntry__c, Sponsorship_name_org_legal_entity__c, Street_House_Number__c, Additional_Address__c FROM address__c WHERE Id =: currentPU.address__c];
            } else if (currentPU.Parent_MA__r.Address__c <> null){
                pus[0].Address__c = currentPU.Parent_MA__r.Address__c;
                UPDATE pus;
                return [SELECT Id, City__c, Country__c, District__c, Phone__c, Fax__c, Name, Post_Box__c, Post_Box_City__c, Post_Box_Country__c, Post_Box_Postal_Code__c, Postal_Code__c, Region_Coiuntry__c, Sponsorship_name_org_legal_entity__c, Street_House_Number__c, Additional_Address__c FROM address__c WHERE Id =: currentPU.address__c];
            }
        } else {
            if (currentPU.Additional_address__c <> null) {
                return [SELECT Id, City__c, Country__c, District__c, Phone__c, Fax__c, Name, Post_Box__c, Post_Box_City__c, Post_Box_Country__c, Post_Box_Postal_Code__c, Postal_Code__c, Region_Coiuntry__c, Sponsorship_name_org_legal_entity__c, Street_House_Number__c, Additional_Address__c FROM address__c WHERE Id =: currentPU.Additional_address__c];
            }
        }
        return null;
    }

    @AuraEnabled()
    public static String getCountryNameFromAddress(String Id) {
        List<Address__c> countryInfo =  [SELECT Country__r.Name FROM address__c WHERE Id =: Id AND Country__c <> '' AND  Country__c <> NULL];            

        if (countryInfo.size() > 0) {
            return countryInfo[0].Country__r.Name;
        }

        return '';
    }


    @AuraEnabled()
    public static ampi__geographical_area__c getCorrespondanceAddressFromPU(String puId) {
        List<ampi__geographical_area__c> pus = [SELECT Id, Corresponding_address_different__c FROM ampi__geographical_area__c WHERE Id =: puId];
        
        if (pus.size() > 0) {
            return pus[0];
        }
        return null;    
    }


    @AuraEnabled()
    public static String updateAddressFromOrganisation(String accountId, String addressId) {
        List<Account> organisations = [SELECT Id, Address__c FROM Account WHERE Id =: accountId];

        if (organisations.size() >0) {
            try {
                organisations[0].address__c = addressId;
                UPDATE organisations;     
                return '';  
            } catch(Exception e) {
                return e.getMessage();
            }
        }
        return 'Organisation not found to update';    
    }

    @AuraEnabled()
    public static String updateAddress(String Id, String City, String Country, String District, String Phone, String Fax, String Name, String Post_Box, String Post_Box_City, String Post_Box_Country, String Post_Box_Postal_Code, String Postal_Code, String Sponsorship_name, String Street_House_Number, String additional_address) {
        List<Address__c> addresses = [SELECT Id, City__c, Country__c, District__c, Phone__c, Fax__c, Name, Post_Box__c, Post_Box_City__c, Post_Box_Country__c, Post_Box_Postal_Code__c, Postal_Code__c, Region_Coiuntry__c, Sponsorship_name_org_legal_entity__c, Street_House_Number__c, Additional_Address__c FROM address__c WHERE Id =: Id];

        if (addresses.size() > 0) {
            Address__c newAddress = addresses[0];
            newAddress.City__c = City;
            newAddress.Country__c = Country;
            newAddress.District__c = District;
            newAddress.Phone__c = Phone;
            newAddress.Fax__c = Fax;
            newAddress.Name = Name;
            newAddress.Post_Box__c = Post_Box;
            newAddress.Post_Box_City__c = Post_Box_City;
            newAddress.Post_Box_Country__c = Post_Box_Country;
            newAddress.Post_Box_Postal_Code__c = Post_Box_Postal_Code;
            newAddress.Postal_Code__c = Postal_Code;
            newAddress.Sponsorship_name_org_legal_entity__c = Sponsorship_name;
            newAddress.Street_House_Number__c = Street_House_Number;
            newAddress.additional_address__c = additional_address;

            try {
                UPDATE newAddress;       
                return '';
            } catch(Exception e) {
                return e.getMessage();
            }
        }    

        return 'Address not found to update';    
    }


    @AuraEnabled()
    public static String insertAddress(String City, String Country, String District, String Phone, String Fax, String Name, String Post_Box, String Post_Box_City, String Post_Box_Country, String Post_Box_Postal_Code, String Postal_Code, String Sponsorship_name, String Street_House_Number, String additional_address) {
        Address__c newAddress = new Address__c();
        newAddress.City__c = City;
        newAddress.Country__c = Country;
        newAddress.District__c = District;
        newAddress.Phone__c = Phone;
        newAddress.Fax__c = Fax;
        newAddress.Name = Name;
        newAddress.Post_Box__c = Post_Box;
        newAddress.Post_Box_City__c = Post_Box_City;
        newAddress.Post_Box_Country__c = Post_Box_Country;
        newAddress.Post_Box_Postal_Code__c = Post_Box_Postal_Code;
        newAddress.Postal_Code__c = Postal_Code;
        newAddress.Sponsorship_name_org_legal_entity__c = Sponsorship_name;
        newAddress.Street_House_Number__c = Street_House_Number;
        newAddress.additional_address__c = additional_address;
        try {
            INSERT newAddress;       
            return newAddress.Id;
        } catch(Exception e) {
            return e.getMessage();
        }
    }    

    @AuraEnabled()
    public static List<Address__c> getAddressFromOrganisation(String accountId) {
        List<Account> organisations = [SELECT Id, Address__c FROM Account WHERE Id =: accountId AND Address__c <> '' AND  Address__c <> NULL];
        if (organisations.size() > 0) {
            return [SELECT Id, City__c, Country__c, District__c, Phone__c, Fax__c, Name, Post_Box__c, Post_Box_City__c, Post_Box_Country__c, Post_Box_Postal_Code__c, Postal_Code__c, Region_Coiuntry__c, Sponsorship_name_org_legal_entity__c, Street_House_Number__c, Additional_Address__c FROM address__c WHERE Id =: organisations[0].address__c];
        }
        return null;
    }

    /*public static void getListOfDatafields(String recordTypeId) {
        //recordTypeId'0121i000000cF3kAAE'
        Id currentUserProfileId = UserInfo.getProfileId();
        List<ProfileLayout> currentLayout = [SELECT Layout.Name, Layout.TableEnumOrId FROM ProfileLayout WHERE RecordTypeId=:recordTypeId And Profile.Id =: currentUserProfileId];

    }*/
}