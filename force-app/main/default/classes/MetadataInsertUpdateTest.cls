@IsTest
public class MetadataInsertUpdateTest {
    @IsTest
    public static void configSetupTest () {
        Integer year = 2003;
        Integer month = 1;

        String frequency = 'Monthly';
        String label      = year + '_' + (month < 10 ? '0' : '') + month;
        String fullName   = 'Catalogue_Reporting_Period.' + label;
        Datetime startDate = Datetime.newInstance(year, month, 1);
        Datetime endDate = startDate.addMonths(1).addDays(-1);
        String values = '{'+
        '  " Report_Type__c ":"' + frequency + '",' +
        '  " Reporting_Period_Start_Date__c ":"' + startDate.format('dd/MM/yyyy') + '",' +
        '  " Reporting_Period_End_Date__c ":"' + endDate.format('dd/MM/yyyy') + '"'+
        '}';

        Map<String, Object> deployedValue = (Map<String, Object>)JSON.deserializeUntyped(values);
        Test.startTest();
        MetadataInsertUpdate.handleInsertAndUpdate(fullName, label, deployedValue);
        Test.stopTest();
    }

    @IsTest
    public static void CreateUpdateMetadataUtilsTest(){
        MetadataInsertUpdate metadata = new MetadataInsertUpdate();
        Test.startTest();
        metadata.handleResult(new Metadata.DeployResult(), new Metadata.DeployCallbackContext());
        Test.stopTest();
    }
    
    @IsTest
    public static void ManageCatalogueReportingPeriodCustomMetadataTypeTest(){
        Test.startTest();
        MetadataInsertUpdate.ManageCatalogueReportingPeriodCustomMetadataType('Monthly', 2030);
        Test.stopTest();
    }
}