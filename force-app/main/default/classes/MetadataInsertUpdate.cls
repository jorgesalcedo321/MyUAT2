public class MetadataInsertUpdate implements Metadata.DeployCallback {
    public void handleResult (Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('success: '+ result);
        } else {
            System.debug('fail: '+ result);
        }
    }

    public static void handleInsertAndUpdate(String fullName, String label, Map<String, Object> fieldWithValuesMap){
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        customMetadata.fullName = fullName;
        customMetadata.label = label;
        System.debug('###handleInsertAndUpdate: enter!');
        for (String key: fieldWithValuesMap.keySet()) {
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key;
            if (key.contains('Date')) {
                System.debug('###fieldWithValuesMap.get(key):' + fieldWithValuesMap.get(key));
				System.debug('###Date.parse(fieldWithValuesMap.get(key)):' + Date.parse(fieldWithValuesMap.get(key).toString()));
            	customField.value = Date.parse(fieldWithValuesMap.get(key).toString());    
            } else {
                customField.value = fieldWithValuesMap.get(key);
            }
            customMetadata.values.add(customField);
        }
        System.debug('#### customMetadata:' + customMetadata);
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        metadataInsertUpdate callback = new metadataInsertUpdate();
        if (!Test.isRunningTest()) {
            System.debug('#### enqueueDeployment:' + label);
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            System.debug('#### jobId enqueueDeployment:' + label);
        }
    }
    
    public static void ManageCatalogueReportingPeriodCustomMetadataType(string typeDescription, Integer periodYear) {
        Integer[] years = new Integer[]{periodYear};
		Integer[] periods = new Integer[]{};
        Integer[] months = new Integer[]{1,2,3,4,5,6,7,8,9,10,11,12};
		Integer[] quarters = new Integer[]{1,2,3,4};
		Integer[] semiAnual = new Integer[]{1,2};
		Integer[] anual = new Integer[]{1};
		String labelPrefix = 'X';
        String prefixPeriod = '';
		Integer interval=0;
        
        String frequency = 'Monthly';
        
        if (typeDescription == 'Monthly') {
        	periods = months;
        } else if (typeDescription == 'Quarterly') {
            prefixPeriod = 'Q';
            periods = quarters;
            interval = 3;
        } else if (typeDescription == 'Semi-Annual') {
            prefixPeriod = 'H';
            periods = semiAnual;
            interval = 6;
        } else if (typeDescription == 'Yearly') {
        	periods = anual;
            interval = 12;
        } 
        
        String label = '';            
        String fullName = '';
        String values = '';
        Datetime startDate;
        Datetime endDate;
        Map<String, Object> deployedValue = new Map<String, Object>();
            for(Integer year : years) {
                for(Integer period : periods) {
                    if (typeDescription == 'Monthly') {
                        label = year + '-' + (period < 10 ? '0' : '') + period;
                        fullName = 'Catalogue_Reporting_Period.X' + year + '_' + (period < 10 ? '0' : '') + period;
                        startDate = Datetime.newInstance(year, period, 1);
                        endDate = startDate.addMonths(1).addDays(-1);                        
                    } else {
                        label = year + (typeDescription == 'Yearly' ? '' : '-' + prefixPeriod + period);
                        fullName = 'Catalogue_Reporting_Period.X' + (typeDescription == 'Yearly' ? year + '' : year + '_' + prefixPeriod + period);
                        startDate = Datetime.newInstance(year, ((period - 1) * interval) + 1, 1);
                        endDate = startDate.addMonths(interval).addDays(-1);                        
                    }                    
                    values = '{'+
                        '  "Report_Type__c":"' + typeDescription + '",' +
                        '  "Reporting_Period_Start_Date__c":"' + startDate.format('dd/MM/yyyy') + '",' +
                        '  "Reporting_Period_End_Date__c":"' + endDate.format('dd/MM/yyyy') + '"'+
					'}';
                    deployedValue = (Map<String, Object>)JSON.deserializeUntyped(values);
                    MetadataInsertUpdate.handleInsertAndUpdate(fullName, label, deployedValue);
                }        
            }  
    }
}