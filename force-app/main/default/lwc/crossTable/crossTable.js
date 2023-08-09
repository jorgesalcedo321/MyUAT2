import {LightningElement, api, track, wire} from 'lwc';
import getMonitoringPeriodsByProjectId from '@salesforce/apex/crossTable.getMonitoringPeriodsByProjectId';
import getServiceTypesByProjectId from '@salesforce/apex/crossTable.getServiceTypesByProjectId';
import getIndicatorsByProjectId from '@salesforce/apex/crossTable.getIndicatorsByProjectId';
// import getSourceDocumentFromIndicator from '@salesforce/apex/crossTable.getSourceDocumentFromIndicator';
import getDataFromProject from '@salesforce/apex/crossTable.getDataFromProject';
import getDataFromProgrammeById from '@salesforce/apex/crossTable.getDataFromProgrammeById';
import getDataFromProjectByPU from '@salesforce/apex/crossTable.getDataFromProjectByPU';
import getResultsByProjectAndGeographicAreaId from '@salesforce/apex/crossTable.getResultsByProjectAndGeographicAreaId';
import getGeographicAreasByProjectId from '@salesforce/apex/crossTable.getGeographicAreasByProjectId';
// import getProjectGeographicAreaIdByProjectAndGeographicAreaId from '@salesforce/apex/crossTable.getProjectGeographicAreaIdByProjectAndGeographicAreaId';
import getPIRPByProjectId from '@salesforce/apex/crossTable.getPIRPByProjectId';
import getPIGAByProjectId from '@salesforce/apex/crossTable.getPIGAByProjectId';
import saveResultChangesInBulk from '@salesforce/apex/crossTable.saveResultChangesInBulk';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLanguageLocateFromCurrentUser from '@salesforce/apex/crossTable.getLanguageLocateFromCurrentUser';

//  upload data excel lwc
//  https://www.linkedin.com/pulse/lwc-csv-file-uploader-create-records-saiful-islam
//https://soscv--uat.sandbox.lightning.force.com/lightning/r/ampi__Project__c/a0i1i000006HXkJAAW/view

export default class CrossTable extends LightningElement {
    @api recordId;
    @api objectName;
    @api objectApiName;
    @api extraParams;    
    @track monitoringPeriodLabel;
    @track monitoringPeriodData = [];
    @track monitoringPeriodOptions = [];
    @track selectedMonitoringPeriodValue;
    @track serviceTypeLabel;
    @track serviceTypeOptions = [];
    @track selectedServiceTypeValue;
    @track geographicAreaLabel;
    @track geographicAreaOptions = [];
    @track selectedGeographicAreaValue;
    @track showComponent = false;
    @track mps = [];
    @track selectedMP;

    @track sourceDocumentLabel;
    @track sourceDocumentOptions = [];
    @track selectedSourceDocumentValue;
    
    @track indicatorValueSearch = '';

    @track indicatorLabel;
    @track filterLabel;
    @track indicatorOptions = [];
    @track selectedIndicatorValue;
    @track pageDetailsData = [];
    @track titleToDownload = [];
    @track pageHeadersData = [];
    @track results = [];
    @track allPIGAs = [];
    @track allPIRPs = [];
    @track loaded = false;
    @track showPUFilter = false;
    @track pgaId = '';
    @track saveManual = false;
    @track valuesToSave = [];
    
    @track dataIndicators = [];
    @track dataMonitoringPeriods = [];
    @track dataGeographicAreas = [];    
    @track dataServiceTypes = [];
    @track dataSourceDocuments = [];
    @track dataFromProject = null;
    @track changesSaved = false;
    @track noIndicatorsAvailable = false;
    @track personalizeClass = '';
    @track checkboxStyle = '';
    @track isNotTransitionProject = false;
    offSetCount = 0;
    maxRecords = 20;
    defaultSourceDocumentValue = '';
    defaultMonitoringPeriodValue = '';
    defaultServiceTypeValue = '';
    defaultIndicatorTextValue = '';
    shadowProject = false;
    notShowProgrammes = false;
    projectId = '';
    decimalSeparator = '';
    isDotDecimalSeparator = false;
    
    async connectedCallback() {
        // this.decimalSeparator = (1.1).toLocaleString().substring(1, 2);
        // this.isDotDecimalSeparator = (this.decimalSeparator === '.');
        // console.log('####this.decimalSeparator:' + this.decimalSeparator);
        // console.log('####this.isDotDecimalSeparator:' + this.isDotDecimalSeparator);
        var language = await getLanguageLocateFromCurrentUser({});
        this.isDotDecimalSeparator = this.isDotDecimalSeparatorByLanguageCode(language);
        this.decimalSeparator = this.getDecimalSeparatorByLanguageCode(language);
        
        // console.log('enter connectedCallback() language:' + language);
        this.loaded = false;
        this.readJSONDefaultValues(this.extraParams);
        await this.loadInitialData();
        this.loaded = true;
        
        // console.log('this.recordId:' + this.recordId);
        // console.log('this.objectName:' + this.objectName);
        // console.log('this.objectApiName:' + this.objectApiName);
    }

    readJSONDefaultValues(json) {
        // console.log('json:' + json);
        const obj = JSON.parse(json);
		if (obj !== undefined) {
                this.defaultSourceDocumentValue = obj['sourcedocument'] === undefined || obj['sourcedocument'] === '' ? undefined : obj['sourcedocument'];
                this.defaultMonitoringPeriodValue = obj['monitoringperiod'] === undefined  || obj['monitoringperiod'] === '' ? undefined : obj['monitoringperiod'];
                this.defaultServiceTypeValue = obj['servicetype'] === undefined  || obj['servicetype'] === '' ? undefined : obj['servicetype'];
                this.defaultIndicatorTextValue = obj['indicator'] === undefined || obj['indicator'] === ''? undefined : obj['indicator'];
                this.shadowProject = obj['shadowproject'] === undefined || obj['shadowproject'] === '' ? false : obj['shadowproject'];
        }
    }

    setCategoryToTable() {
        this.pageDetailsData.map((record) => {
                // console.log('###record:' + JSON.stringify(record));
                // console.log('this.pageDetailsData');
                if (record !== undefined && record !== null) {
                    for(var i=0; i < record.Value.length; i++) {
                        record.Value[i]['IsNumber'] = (record.Value[i].Type == 'Number');
                        record.Value[i]['IsPercentage'] = (record.Value[i].Type == 'Percentage');
                    }
                }
                // console.log('this.pageDetailsData 2');
                // console.log('###record after:' + JSON.stringify(record));
                return {...record}
                // return {...record, IsNumber: record.Type == 'Number', IsPercentage: record.Type == 'Percentage'}
        });     
        this.pageDetailsJSON = JSON.stringify(this.pageDetailsData);
        // console.log('###this.pageDetailsData:' + JSON.stringify(this.pageDetailsData))                                                                
    }

    async loadInitialData() {
        this.geographicAreaLabel = 'Geographic Area';
        this.monitoringPeriodLabel = 'Monitoring Periods:'; 
        this.serviceTypeLabel = 'Service Types:';
        this.indicatorLabel = 'Indicator name:';
        this.filterLabel = 'Filter';
        this.sourceDocumentLabel = 'Source Documents:';
        // console.log('####this.shadowProject:' + this.shadowProject);

        if (this.shadowProject) {
            console.log('###this.recordId:' + this.recordId);
            var dataFromProjectByPU = await getDataFromProjectByPU({puId: this.recordId});    
            var dataProgramme = await getDataFromProgrammeById({puId: this.recordId});     

            if (dataProgramme == null || dataFromProjectByPU == null) {
                this.showToaster('Error', 'There is no project or programme information related to this record', 'error');
                return;
            }
            // console.log('###dataProgramme:' + dataProgramme );
            // console.log('###dataProgramme JSON:' + JSON.stringify(dataProgramme));
            // console.log('###dataFromProjectByPU:' + dataFromProjectByPU);
            // console.log('###dataFromProjectByPU JSON:' + JSON.stringify(dataFromProjectByPU));
            //this.showPUFilter = (dataProgramme['Program_Type__c'] == 'National Office Programme' || dataProgramme['Program_Type__c'] == 'Programme');
            this.showPUFilter = (dataProgramme['Program_Type__c'] == 'Programme');
            
            // console.log('####dataFromProjectByPU[Id]:' + dataFromProjectByPU['Id']);
            this.projectId = dataFromProjectByPU['Id'];
        } else {
            this.projectId = this.recordId;
        }
        console.log('###this.projectId:' + this.projectId);
        this.dataFromProject = await getDataFromProject({projectId: this.projectId}); // dataFromProject.Programme_Location__c;
        this.isNotTransitionProject  = this.dataFromProject['RecordType'].Name !== 'Transition';

        if (this.dataFromProject['RecordType'].Name == 'Transition' && this.shadowProject == false) {
            this.showPUFilter = true;
            this.notShowProgrammes = true;
        }        

        this.personalizeClass = this.showPUFilter ? 'slds-size_1-of-5 slds-float_left' : 'slds-size_2-of-5 slds-float_left';
        this.checkboxStyle = this.showPUFilter ? 'margin-top: 10px; display: inline-flex; width: 110px; margin-left: 20px;' : 'float: left; width: 110px; margin-left: 20px; margin-top: 5px;';
        
        if (this.dataFromProject['RecordType'].Name == 'Grant' || 
            this.dataFromProject['RecordType'].Name == 'Humanitarian' ||
            this.dataFromProject['RecordType'].Name == 'Standard' ||
            this.dataFromProject['RecordType'].Name == 'Transition' ||
            this.shadowProject) {
                this.showComponent = true;
        }

        if (this.showComponent == false) {
            return;
        }

        console.log('###this.shadowProject:' + this.shadowProject);
        console.log('###this.showPUFilter:' + this.showPUFilter);

        // console.log('this.dataFromProject:' + JSON.stringify(this.dataFromProject));
        // console.log('this.dataFromProject[Programme_location__r]:' + this.dataFromProject['Programme_Location__r']);
        // console.log('this.dataFromProject[Programme_location__r.Name] 2:' + this.dataFromProject['Programme_Location__r'].Name);
        this.dataGeographicAreas = await getGeographicAreasByProjectId({projectId: this.projectId});
        this.dataMonitoringPeriods = await getMonitoringPeriodsByProjectId({projectId: this.projectId});
        this.dataServiceTypes = await getServiceTypesByProjectId({projectId: this.projectId });
        
        this.fillGeographicAreas(this.dataGeographicAreas);        
        var pga = this.searchGeographicAreaByCurrentId();
        var gaId = (pga != null ? pga.ga : '');
        var gaName = (pga != null ? pga.label : '');

        this.dataIndicators = await this.processIndicators(gaName); // this.dataFromProject['Programme_Location__r'].Name
        // this.dataSourceDocuments = await getSourceDocumentFromIndicator({projectId: this.projectId, geographicAreaId: gaId }); //this.dataFromProject['Programme_Location__c']
        this.dataSourceDocuments = this.getSourceDocumentFromIndicators();
        
        // console.log('####this.dataIndicators.length:' + this.dataIndicators.length);
        // console.log('####this.dataIndicators:' + JSON.stringify(this.dataIndicators));

        this.fillIndicators(this.dataIndicators);        
        this.pgaId = this.selectedGeographicAreaValue; //await getProjectGeographicAreaIdByProjectAndGeographicAreaId({projectId: this.recordId, geographicAreaId: this.dataFromProject['Programme_Location__c']});
        this.allPIGAs = await getPIGAByProjectId({projectId: this.projectId });        
        this.allPIRPs = await getPIRPByProjectId({projectId: this.projectId });

        console.log('####this.allPIGAs.length:' + this.allPIGAs.length);
        console.log('####this.allPIRPs.length:' + this.allPIRPs.length);

        if (this.allPIGAs.length == 0 || this.dataGeographicAreas.length == 0) {
            this.showToaster('Error', 'Project Indicators are not linked to Geographic Areas.', 'error');
            return;
        }

        if (this.allPIRPs.length == 0 || this.dataMonitoringPeriods.length == 0 ) {
            this.showToaster('Error', 'Project Indicators are not linked to Monitoring Periods.', 'error');
            return;
        }

        // console.log('### dataFromProject await:' + JSON.stringify(this.dataFromProject));
        // console.log('### dataMonitoringPeriods await:' + dataMonitoringPeriods);
        // console.log('### dataServiceTypes await:' + dataServiceTypes);
        // console.log('### dataIndicators await:' + dataIndicators);
        // console.log('### dataSourceDocuments await:' + dataSourceDocuments);
        this.fillMonitoringPeriods(this.dataMonitoringPeriods);        
        this.fillServiceTypes(this.dataServiceTypes);        
        this.fillSourceDocumentIndicators(this.dataSourceDocuments);       
        
        await this.applyFiltersToResults();                                                            
    }

    getSourceDocumentFromIndicators() {
        var sources = [];
        for (var i=0; i<this.dataIndicators.length; i++) {
            if (this.dataIndicators[i]['ampi__Catalog_Indicator__r'] !== undefined && sources.find(item => item === this.dataIndicators[i]['ampi__Catalog_Indicator__r'].Source_Document__c) === undefined) {
                sources.push(this.dataIndicators[i]['ampi__Catalog_Indicator__r'].Source_Document__c);
            }
        }
        console.log('###sources:' + sources);
        return sources;
    }

    async processIndicators(geographicArea) {
        // console.log('####processIndicators geographicArea:' + geographicArea);
        var dataIndicators = await getIndicatorsByProjectId({projectId: this.projectId});
        
        // console.log('processIndicators sta:' + JSON.stringify(dataIndicators));
        var cloneIndicators = dataIndicators.map((record) => record);
        
        if (this.selectedGeographicAreaValue != 'All') {
            for(var i=0; i<cloneIndicators.length ;i++){
                if (!this.cleanText(cloneIndicators[i].ampi__Geographic_Area_Text__c).includes(this.cleanText(geographicArea))) {
                    cloneIndicators.splice(i, 1); 
                }
            } 
        }
        
        // console.log('processIndicators end:' + JSON.stringify(cloneIndicators));
        return cloneIndicators; 
    }

    async applyFiltersToResults() {
        var pga = this.searchGeographicAreaByCurrentId();
        if (this.showPUFilter) {
            var gaName = (pga != null ? pga.label : '');
            this.dataIndicators = await this.processIndicators(gaName); 
        }

        var gaId = (pga != null ? pga.ga : '');
        this.results = [];
        // console.log('···gaId:' + gaId);
        this.results = await getResultsByProjectAndGeographicAreaId({projectId: this.projectId, geographicAreaId: gaId});        
        // console.log('###this.projectId:' + this.projectId);
        // console.log('###gaId:' + gaId);
        // console.log('###this.results:' + JSON.stringify(this.results));
        this.changesSaved = false;
       
        var frequencyMP = '';
        for(var i=0; i < this.mps.length; i++) {
            if (this.selectedMP == this.mps[i].value) {
                frequencyMP = this.mps[i].frequency;
            }
        }
        // var filterIndicators = this.indicatorOptions.map((x) => x);
        this.fillIndicators(this.dataIndicators);        
        var filterIndicators = this.indicatorOptions.reduce(function(filtered, option) {
            if (option.frequency == frequencyMP) {
                var filteredValue = { value: option.value, 
                    label: option.label,
                    frequency: option.frequency,
                    level: option.level,
                    checked: option.checked }
                filtered.push(filteredValue);
            }
            return filtered;
        }, []);

        // console.log('####filterIndicators 1:' + JSON.stringify(filterIndicators));
        // console.log('####filterIndicators 1:' + filterIndicators.length);
        // console.log('###this.selectedSourceDocumentValue:' + this.selectedSourceDocumentValue);
        // console.log('filterIndicators bf:' + filterIndicators.length + ' / this.selectedSourceDocumentValue:' + this.selectedSourceDocumentValue + '/ this.selectedServiceTypeValue: ' + this.selectedServiceTypeValue + '/this.indicatorValueSearch: ' + this.indicatorValueSearch);
        // console.log('this.dataIndicators:' + JSON.stringify(this.dataIndicators));
        if (this.selectedSourceDocumentValue !== 'All' && this.selectedSourceDocumentValue !== '') {
            for (var i=0; i<this.dataIndicators.length; i++) {
                if (this.dataIndicators[i]['ampi__Catalog_Indicator__r'] !== undefined && this.cleanText(this.dataIndicators[i]['ampi__Catalog_Indicator__r'].Source_Document__c) != this.cleanText(this.selectedSourceDocumentValue)) {
                    for (var j=0; j<filterIndicators.length;j++) {
                        if (this.dataIndicators[i].Id === filterIndicators[j].value) {
                            filterIndicators.splice(j, 1); 
                        }
                    }
                }
            }
        }
        // console.log('####filterIndicators 2:' + JSON.stringify(filterIndicators));
        // console.log('####filterIndicators 2:' + filterIndicators.length);
        if (this.selectedServiceTypeValue !== 'All' && this.selectedServiceTypeValue !== '') {
            for (var i=0; i<this.dataIndicators.length; i++) {
                if (this.dataIndicators[i]['ampi__Catalog_Indicator__r'] !== undefined && !(this.cleanText(this.dataIndicators[i]['ampi__Catalog_Indicator__r'].ampi__Thematic_Area_Ids__c).includes(this.cleanText(this.selectedServiceTypeValue)))) {
                    for (var j=0; j<filterIndicators.length;j++) {
                        if (this.dataIndicators[i].Id == filterIndicators[j].value) {
                            filterIndicators.splice(j, 1); 
                        }
                    }
                }
            }
        } 
        // console.log('####filterIndicators 3:' + JSON.stringify(filterIndicators));
        // console.log('####filterIndicators 3:' + filterIndicators.length);
        if (this.indicatorValueSearch !== '') {
            for (var i=0; i<this.dataIndicators.length; i++) {
                //if (!(this.cleanText(this.dataIndicators[i]['ampi__Catalog_Indicator__r'].ampi__Description__c).includes(this.cleanText(this.indicatorValueSearch)))) {
                console.log('####this.dataIndicators[i]:' + this.dataIndicators[i]);
                if (this.dataIndicators[i]['ampi__Catalog_Indicator__r'] !== undefined && !(this.cleanText(this.dataIndicators[i]['ampi__Description_Translated__c']).includes(this.cleanText(this.indicatorValueSearch)))) {
                    for (var j=0; j<filterIndicators.length;j++) {
                        if (this.dataIndicators[i].Id == filterIndicators[j].value) {
                            filterIndicators.splice(j, 1); 
                        }
                    }
                }
            }
        }

        // console.log('####filterIndicators 4:' + JSON.stringify(filterfIndicators));
        // console.log('####filterIndicators 4:' + filterIndicators.length);
        // console.log('···this.selectedGeographicAreaValue:' + this.selectedGeographicAreaValue);
        if (this.showPUFilter && this.selectedGeographicAreaValue !== 'All' && this.selectedGeographicAreaValue !== '') {
            var selectedGeographicAreaText = '';
            // console.log('···enter this.selectedGeographicAreaValue');
            for(var i=0; i<this.geographicAreaOptions.length; i++) {
                if (this.cleanText(this.geographicAreaOptions[i].value) == this.cleanText(this.selectedGeographicAreaValue)) {
                    selectedGeographicAreaText = this.geographicAreaOptions[i].label;
                }
            }
            for (var i=0; i<this.dataIndicators.length; i++) {
                // console.log('#####this.dataIndicators[i][ampi__Geographic_Area_Text__c]:' + this.dataIndicators[i]['ampi__Geographic_Area_Text__c']);
                if (!(this.cleanText(this.dataIndicators[i]['ampi__Geographic_Area_Text__c']).includes(this.cleanText(selectedGeographicAreaText)))) {
                    for (var j=0; j<filterIndicators.length;j++) {
                        if (this.dataIndicators[i].Id == filterIndicators[j].value) {
                            filterIndicators.splice(j, 1); 
                        }
                    }
                }
            }
        }
        // console.log('####filterIndicators 5:' + JSON.stringify(filterIndicators));

        this.noIndicatorsAvailable = filterIndicators == undefined || filterIndicators.length === 0;
        // console.log('####filterIndicators 4:' + JSON.stringify(filterIndicators));
        // console.log('filterIndicators af:' + filterIndicators.length);
        this.fillTableWithResults(filterIndicators);
    }

    cleanText(textToCheck) {
        if (textToCheck == null || textToCheck == undefined)
            return '';
        return (textToCheck + '').toLowerCase().trim();
    }

    fillTableWithResults(indicators) {        
        this.pageHeadersData = [];
        this.pageDetailsData = [];

        this.pageHeadersData.push('Project Indicator');
        // console.log('this.monitoringPeriodOptions:' + JSON.stringify(this.monitoringPeriodOptions));
        for(var i = 0; i < this.monitoringPeriodOptions.length; i++) {
            this.pageHeadersData.push(this.monitoringPeriodOptions[i].label);
        }
        this.pageHeadersJSON = JSON.stringify(this.pageHeadersData);
        for(var i = 0; i < indicators.length; i++) {
            //DISAGGREGATION GROUP
            // this.pageDetailsData.push({Name:this.indicatorOptions[i].label, Value: [{Category:'Total',Type:'Percentage', Id: '1111', Value:'1'},
            //                                                                          {Category:'Male',Type:'Percentage', Id: '1122', Value:'2'},
            //                                                                          {Category:'Female',Type:'Number', Id: '1133', Value:'3'}]});  
            var mpValues = [];
            var dataValuesDetails = [];
            var randomValue = 0;
            var currentPIGA = this.findPIGAByProjectIndicator(indicators[i].value);
            // console.log('currentPIGA:' + JSON.stringify(currentPIGA));
            for(var j = 0; j < this.monitoringPeriodOptions.length; j++) {
                               
                var currentPIRP = this.findPIRPByProjectIndicatorAndMonitoringPeriod(indicators[i].value, this.monitoringPeriodOptions[j].value);
                var resultValue = this.findResultByPIRPAndPIGA(currentPIGA, currentPIRP);
                var mpTargetStatus = this.monitoringPeriodOptions[j].status;
                var mpTargetLocked = this.monitoringPeriodOptions[j].isLocked;
                // console.log('####mpTargetStatus:' + mpTargetStatus);

                randomValue = (Math.floor(Math.random() * 1000000) + 1000000) + 'B';
                var targetValue = resultValue != undefined && resultValue != null && resultValue.ampi__Target_Value__c != undefined ? (indicators[i].level == 'Staff' ? Number.parseFloat(resultValue.ampi__Target_Value__c).toFixed(2) : Number.parseFloat(resultValue.ampi__Target_Value__c).toFixed(0)) : '';

                dataValuesDetails.push({Random: randomValue,
                                        Id: resultValue != undefined && resultValue != null ? resultValue.Id : '', 
                                        Category:this.monitoringPeriodOptions[j].label, 
                                        PIGA: currentPIGA != undefined && currentPIGA != null? currentPIGA.Id : '',
                                        PIRP: currentPIRP != undefined && currentPIRP != null? currentPIRP.Id : '',
                                        PI: currentPIRP != undefined && currentPIRP != null? currentPIRP.ampi__Project_Indicator__c : '',
                                        EndPeriodDate: currentPIRP != undefined && currentPIRP != null? currentPIRP.ampi__Reporting_Period__r.ampi__Reporting_Period_End_Date__c : new Date('1990-01-01'),
                                        DataTracked: currentPIRP != undefined && currentPIRP != null ? currentPIRP.ampi__Data_Tracked__c : 'Both',
                                        DecimalNumber: indicators[i].level == 'Staff' ? 2 : 0,
                                        Type: (mpTargetStatus == 'Submitted' || mpTargetLocked == true) ? 'Label' : 'Number', 
                                        // Type: 'Number', 
                                        Value: targetValue.replace('.', ',')});
            }
            // console.log('Details:' + JSON.stringify(dataValuesDetails));
            randomValue = (Math.floor(Math.random() * 1000000) + 1000000) + 'A';
            mpValues.push({Category:indicators[i].label, Type:'Number', Random: randomValue, Id: randomValue, Value:'0', Details: dataValuesDetails});
            this.pageDetailsData.push({Name:indicators[i].label, Value: mpValues});
        }     

        // console.log('####this.pageDetailsData:' + JSON.stringify(this.pageDetailsData));
        // console.log('####this.dataValuesDetails:' + JSON.stringify(this.dataValuesDetails));
        this.setCategoryToTable();
        // console.log('###this.searchMonitoringPeriodByCurrentId():' + this.searchMonitoringPeriodByCurrentId());
        // console.log('###this.selectedMP:' + this.selectedMP);
        this.titleToDownload = (this.searchGeographicAreaByCurrentId() == null ? '' : this.searchGeographicAreaByCurrentId().label + ' - ' + this.selectedMP);
    }

    findPIRPByProjectIndicatorAndMonitoringPeriod(projectIndicator, monitoringPeriod) {
        for (var i = 0; i<this.allPIRPs.length; i++) {
            if (this.allPIRPs[i].ampi__Project_Indicator__c == projectIndicator && this.allPIRPs[i].ampi__Reporting_Period__c == monitoringPeriod) {
                return this.allPIRPs[i];
            }
        }
        return undefined;
    }

    findPIGAByProjectIndicator(projectIndicator) {
        // console.log('###this.selectedGeographicAreaValue:' + this.selectedGeographicAreaValue);
        // console.log('###this.allPIGAs:' + JSON.stringify(this.allPIGAs));
        var pa = this.getPAByGPA(this.selectedGeographicAreaValue);
        // console.log('###pa:' + pa);
        var currentPiga = undefined;
        for (var i = 0; i<this.allPIGAs.length; i++) {
            // console.log('####this.allPIGAs[i]:' + JSON.stringify(this.allPIGAs[i]));
            // console.log('###this.allPIGAs[i].ampi__Geographic_Area__c:' + this.allPIGAs[i].ampi__Geographic_Area__c);
            if (this.allPIGAs[i].ampi__Project_Indicator__c == projectIndicator) {
                //ampi__Geographic_Area__r.Name
                if (this.cleanText(pa) === 'all' || this.cleanText(this.allPIGAs[i].ampi__Geographic_Area__c) == this.cleanText(pa)) {
                    currentPiga = this.allPIGAs[i];
                    // console.log('###coincidences! currentPiga:' + currentPiga.ampi__Geographic_Area__c);
                    return this.allPIGAs[i];
                }
            }
        }
        return currentPiga;
    }

    getPAByGPA(pga) {
        for(var i=0; i<this.geographicAreaOptions.length; i++) {
            if (this.geographicAreaOptions[i].value === pga) {
                return this.geographicAreaOptions[i].ga;
            }
        }
    }

    findResultByPIRPAndPIGA(currentPIGA, currentPIRP) {
        if (currentPIGA != undefined && currentPIRP != undefined && currentPIGA != null && currentPIRP != null) {
            for (var i=0; i<this.results.length; i++) {
                if (this.results[i].ampi__Project_Indicator_Reporting_Period__c == currentPIRP.Id &&
                    this.results[i].ampi__Project_Indicator_Geographic_Area__c  == currentPIGA.Id) {
                        // console.log('####this.results[i] value:' + JSON.stringify(this.results[i]));
                        return this.results[i];
                }
            }
        }
        return undefined;
    }

    findDefaultPeriod(data) {
        var periodsToSearch = ['-M','-Q','-H',''];        
        for (let p=0; p<periodsToSearch.length; p++) {                
            for(let i=0; i<data.length; i++) {
                var startYear = data[i].ampi__Reporting_Period_Start_Date__c.substring(0, 4);            
                var sufixPeriod = data[i].ampi__Report_Type__c == 'Semi-Annual' ? '-H' : data[i].ampi__Report_Type__c == 'Quarterly' ? '-Q' : data[i].ampi__Report_Type__c == 'Monthly' ? '-M' : '';
                var currentValue = data[i].ampi__Report_Type__c != 'Yearly' ? startYear + sufixPeriod : startYear;
                currentValue = data[i].ampi__Report_Type__c === 'Life of Project' ? 'Life of Project' : currentValue;
                if (parseInt(startYear) === (new Date()).getFullYear() && sufixPeriod == periodsToSearch[p]) {
                    return currentValue;
                }                
            }
        }
        return '';
    }

    fillMonitoringPeriods(data) {
		this.monitoringPeriodOptions = [];
        this.monitoringPeriodData = data;
        this.mps = [];

        if (data == undefined || data == null)
            return;
        
        // console.log('###fillMonitoringPeriods data:' + JSON.stringify(data));
        var defaultPeriod = '';
        if (this.selectedMP == undefined || this.selectedMP == null) {
            defaultPeriod = this.findDefaultPeriod(data,'-M');
        }

		for(let i=0; i<data.length; i++) {
            // var currentYear = data[i].ampi__Label__c.substring(0, 4);
            var startYear = data[i].ampi__Reporting_Period_Start_Date__c.substring(0, 4);            
            var frequency = data[i].ampi__Report_Type__c;
            var sufixPeriod = frequency == 'Semi-Annual' ? '-H' : frequency == 'Quarterly' ? '-Q' : frequency == 'Monthly' ? '-M' : '';
            var currentValue = data[i].ampi__Report_Type__c != 'Yearly' ? startYear + sufixPeriod : startYear;
            currentValue = data[i].ampi__Report_Type__c === 'Life of Project' ? 'Life of Project' : currentValue;

            // console.log('###startYear:' + startYear);
            var exists = false;
            
            for (let j=0; j<this.mps.length; j++) {
                if (currentValue == this.mps[j]['value']) {
                    exists = true;
                }
            }      

            if (exists === false) {
                // console.log('####fillMonitoringPeriods this.selectedMP:' + this.selectedMP);
                 if (this.selectedMP == undefined || this.selectedMP == null) {
                    this.selectedMP = defaultPeriod;
                }

                this.mps.push({	
                    value: currentValue, 
                    label: currentValue, //frequency == 'Yearly' ? startYear : currentValue + sufixPeriod,
                    frequency: frequency,
                    checked: (this.selectedMP == currentValue)				
                });
                // console.log('###fillMonitoringPeriods this.selectedMP: ' + this.selectedMP);
            }
		}
        // console.log('###fillMonitoringPeriods this.mps:' + JSON.stringify(this.mps));        
		this.changeMonitoringPeriodHandler({target: {value: this.selectedMP}});
	}

    fillServiceTypes(data) {
		this.serviceTypeOptions = [];
        this.serviceTypeOptions.push({	
				value: 'All', 
				label: 'All',
				checked: true				
        });
        // console.log('####fillServiceTypes() this.selectedServiceTypeValue:' + this.selectedServiceTypeValue);
        if (this.selectedServiceTypeValue == undefined || this.selectedServiceTypeValue == null) {
            this.selectedServiceTypeValue = 'All';
        }

        if (data == undefined || data == null)
            return;

		for(let i=0; i<data.length; i++) {
            var fullname = data[i].ampi__Thematic_Area__r.Name === data[i].ampi__Thematic_Area__r.Abbreviation__c ? data[i].ampi__Thematic_Area__r.Name : (data[i].ampi__Thematic_Area__r.Abbreviation__c === undefined ? '' : data[i].ampi__Thematic_Area__r.Abbreviation__c + ' - ') + data[i].ampi__Thematic_Area__r.Name;
            const found = this.serviceTypeOptions.find(element => element.label == fullname); 
            
            if (found === undefined) {
                // console.log('####data[i].ampi__Thematic_Area__r.Id:' + data[i].ampi__Thematic_Area__r.Id);
                this.serviceTypeOptions.push({	
                    value: data[i].ampi__Thematic_Area__r.Id, 
                    label: fullname,
                    checked: (this.selectedServiceTypeValue == data[i].ampi__Thematic_Area__r.Id)				
                });
            }
		}

        this.serviceTypeOptions = this.serviceTypeOptions.sort((a, b) => {
            const nameA = a.label.toUpperCase();
            const nameB = b.label.toUpperCase();
            if (nameA < nameB) { 
                return -1;
            }
            if (nameA > nameB) { 
                return 1;
            }
            return 0;
        });        
	
		this.changeServiceTypeHandler({target: {value: this.selectedServiceTypeValue}});
	}

    fillGeographicAreas(data) {
		this.geographicAreaOptions = [];

        if (data == undefined || data == null)
            return;

        if (this.isNotTransitionProject) {
            this.geographicAreaOptions.push({	
                    value: 'All', 
                    label: 'All',
                    ga: 'All',
                    type: 'All',
                    checked: false				
            });
        }
        
        for(let i=0; i<data.length; i++) {
			if (!(this.notShowProgrammes && data[i].ampi__Geographic_Area__r.ampi__Type__c === 'Programme')) {
                if (this.selectedGeographicAreaValue == undefined) {
                // console.log('###this.geographicAreaOptions[i].ga:' + this.geographicAreaOptions[i].ga);
                // console.log('####this.dataFromProject[Programme_Location__c]:' + this.dataFromProject['Programme_Location__c']);
                // console.log('####this.cleanText(data[i].ampi__Geographic_Area__r.Id):' + this.cleanText(data[i].ampi__Geographic_Area__r.Id));
                // console.log('####this.cleanText(data[i].Id):' + this.cleanText(data[i].Id));
                // console.log('###this.recordId:' + this.recordId);
                if ((this.cleanText(data[i].ampi__Geographic_Area__r.Id) === this.cleanText(this.dataFromProject['Programme_Location__c'])) || 
                    (this.shadowProject && this.cleanText(data[i].ampi__Geographic_Area__r.Id) === this.cleanText(this.recordId))) {
                        // console.log('###enter here:' + this.geographicAreaOptions[i].value);
                    if (this.selectedGeographicAreaValue == undefined || this.selectedGeographicAreaValue == null) {    
                        this.selectedGeographicAreaValue = data[i].Id;
                    }
                }
                //console.log('###this.selectedGeographicAreaValue:' + this.selectedGeographicAreaValue);
            }
            
            this.geographicAreaOptions.push({	
                    value: data[i].Id, 
                    ga: data[i].ampi__Geographic_Area__r.Id,
                    label: data[i].ampi__Geographic_Area__r.Name,
                    type: data[i].ampi__Geographic_Area__r.ampi__Type__c,
                    checked: (this.selectedGeographicAreaValue == data[i].Id)				
                });
            }
		}

        if (this.selectedGeographicAreaValue == undefined && this.geographicAreaOptions.length > 0) {
            this.selectedGeographicAreaValue = this.geographicAreaOptions[0].value;
        }
        // console.log('####fillGeographicAreas this.recordId:' + this.recordId);
        // console.log('####fillGeographicAreas this.selectedGeographicAreaValue:' + this.selectedGeographicAreaValue);

        //console.log('###this.geographicAreaOptions:' + JSON.stringify(this.geographicAreaOptions));
		this.changeGeographicAreaHandler({target: {value: this.selectedGeographicAreaValue}});
	}

    searchGeographicAreaByCurrentId() {
        // console.log('####this.geographicAreaOptions:' + this.geographicAreaOptions.length);
        for(var i=0; i<this.geographicAreaOptions.length; i++) {
            // console.log('this.geographicAreaOptions[i].value:' + this.geographicAreaOptions[i].value);
            // console.log('this.selectedGeographicAreaValue:' + this.selectedGeographicAreaValue);
            if (this.selectedGeographicAreaValue == this.geographicAreaOptions[i].value) {
                return this.geographicAreaOptions[i];
            }
        }
        return null;
    }

    fillIndicators(data) {
		this.indicatorOptions = [];
        var ga = this.searchGeographicAreaByCurrentId();
        // console.log('####fillIndicators ga:' + JSON.stringify(ga));

        if (data === undefined || data === null) {
            this.noIndicatorsAvailable = true;
            // this.showComponent = false
            return;
        }
        
        if (ga === undefined || ga === null) {
            return;
        }
        // console.log('···data.length:' + data.length);
		for(let i=0; i<data.length; i++) {
            // console.log('###data[i].ampi__Geographical_Disaggregation__c: ' + data[i].ampi__Geographical_Disaggregation__c);
            if (ga.value !== 'All' && ga.type !== data[i].ampi__Geographical_Disaggregation__c) {
                continue;
            }
            
            // if (mp != data[i].ampi__Geographical_Disaggregation__c) {
            //     continue;
            // }
            var noIndicatorValue = 'No indicator value';
            var newOrder = (data[i].ampi__Catalog_Indicator__r === undefined ? 99 : data[i].ampi__Catalog_Indicator__r.ampi__Description__c.includes('Number of participants') ? 0 : data[i].ampi__Catalog_Indicator__r.ampi__Description__c.includes('Number of households') ? 1 : data[i].ampi__Catalog_Indicator__r.ampi__Description__c.includes('Number of staff') ? 2 : 3);

			this.indicatorOptions.push({	
				value: data[i].Id, 
                label: (data[i].ampi__Catalog_Indicator__r !== undefined ? data[i].ampi__Catalog_Indicator__r.ampi__Description_Translated__c : noIndicatorValue),
                frequency: data[i].ampi__Target_Frequency__c,
                level: (data[i].ampi__Catalog_Indicator__r !== undefined ? data[i].ampi__Catalog_Indicator__r.Level__c : noIndicatorValue),
                ga: data[i].ampi__Geographic_Area_Text__c,
                order: newOrder, 
                dissagregation: data[i].ampi__Geographical_Disaggregation__c,
				checked: (this.selectedIndicatorValue == data[i].Id)				
			});
		}
        // console.log('···this.indicatorOptions:' + this.indicatorOptions.length);
        // Sort order
        this.indicatorOptions = this.indicatorOptions.sort((a, b) => {
            const orderA = a.order;
            const orderB = b.order;            
            const nameA = a.label.toUpperCase();
            const nameB = b.label.toUpperCase();
            if (orderA < orderB) { //nameA < nameB && 
                return -1;
            }
            if (orderA > orderB) { //nameA > nameB && 
                return 1;
            }
            if (nameA < nameB) { 
                return -1;
            }
            if (nameA > nameB) { 
                return 1;
            }
            return 0;
        });        
	}

    fillSourceDocumentIndicators(data) {
		this.sourceDocumentOptions = [];
        // console.log('this.sourceDocumentOptions:' + this.sourceDocumentOptions);
        // console.log('###data sourceDocumentOptions:' + JSON.stringify(data));
        if (data == undefined || data == null)
            return;

        for(let i=0; i<data.length; i++) {
			if (data[i] == this.defaultSourceDocumentValue) {
                this.selectedSourceDocumentValue = this.defaultSourceDocumentValue;
            }
		}

        if (this.cleanText(this.selectedSourceDocumentValue) == '') {
            this.selectedSourceDocumentValue = 'All';
        }

        this.sourceDocumentOptions.push({	
				value: 'All', 
				label: 'All',
				checked: (this.selectedSourceDocumentValue == 'All')				
        });

		for(let i=0; i<data.length; i++) {
            // console.log('###(this.selectedSourceDocumentValue == data[i]):' + (this.selectedSourceDocumentValue == data[i]));
            // console.log('###data[i]):' + data[i]);
            if (data[i] == null || data[i] == '') 
                continue;

			this.sourceDocumentOptions.push({	
				value: data[i], 
				label: data[i],
				checked: (this.selectedSourceDocumentValue == data[i])				
			});
		}
        // console.log('####this.selectedSourceDocumentValue 2: ' + JSON.stringify(this.sourceDocumentOptions));
		this.changeSourceDocumentHandler({target: {value: this.selectedSourceDocumentValue}});
	}

    async changeMonitoringPeriodHandler(event) {
        this.selectedMP = event.target.value;
        console.log('###changeMonitoringPeriodHandler this.selectedMP: ' + this.selectedMP);
        var selectedFrequency = '';
        var selectedYear = ''; 
        var lifeOfProject = 'Life of Project';
        
        if (event.target.value !== undefined) {
            if (this.selectedMP == lifeOfProject) {
                selectedFrequency = lifeOfProject;
            } else if (this.selectedMP.length === 4) {
                selectedFrequency = 'Yearly';
                selectedYear = this.selectedMP.substring(0,4);
            } else if (this.selectedMP.length === 6) {
                selectedYear = this.selectedMP.substring(0,4);
                if (this.selectedMP.substring(5,6) == 'M') {
                    selectedFrequency = 'Monthly';
                } else if (this.selectedMP.substring(5,6) == 'H') {
                    selectedFrequency = 'Semi-Annual';
                } else if (this.selectedMP.substring(5,6) == 'Q') {
                    selectedFrequency = 'Quarterly';
                }
            } 

            this.monitoringPeriodOptions = [];
            console.log('event.target.value: ' + event.target.value);

            // console.log('this.monitoringPeriodData: ' + JSON.stringify(this.monitoringPeriodData));
            for(let i=0; i<this.monitoringPeriodData.length; i++) {
                // console.log('this.monitoringPeriodData[i].ampi__Label__c: ' + this.monitoringPeriodData[i].ampi__Label__c);
                var startYear = this.monitoringPeriodData[i].ampi__Reporting_Period_Start_Date__c.substring(0, 4);
                var frequency = this.monitoringPeriodData[i].ampi__Report_Type__c;
                var status = this.monitoringPeriodData[i].ampi__Target_Status__c;
                var isLocked = this.monitoringPeriodData[i].ampi__Targets_Locked__c;
                var ischecked = (this.selectedMP == this.monitoringPeriodData[i].Id);
                var id = this.monitoringPeriodData[i].Id;
                var sufixPeriod = frequency == 'Semi-Annual' ? '-H' : frequency == 'Quarterly' ? '-Q' : frequency == 'Monthly' ? '-M' : '';
                var currentValue = this.monitoringPeriodData[i].ampi__Report_Type__c != 'Yearly' ? startYear + sufixPeriod : startYear;

                if (frequency !== selectedFrequency)
                    continue;
                
                if (frequency !== lifeOfProject && startYear !== selectedYear)
                    continue;

                if (frequency == lifeOfProject) {
                    this.addMonitoringPeriodOption(id, lifeOfProject, frequency, status, isLocked, ischecked);                    
                } else if (frequency == 'Yearly' && startYear == event.target.value) {
                    this.addMonitoringPeriodOption(id, currentValue, frequency, status, isLocked, ischecked);
                }  else if (frequency != 'Yearly' && frequency != 'Monthly' && this.monitoringPeriodData[i].ampi__Label__c.substring(0, 6) == event.target.value) {
                    this.addMonitoringPeriodOption(id, this.monitoringPeriodData[i].ampi__Label__c, frequency, status, isLocked, ischecked);                    
                }  else if (frequency == 'Monthly' && this.monitoringPeriodData[i].ampi__Label__c.substring(0, 4) == event.target.value.substring(0, 4) && this.isNumberValid(this.monitoringPeriodData[i].ampi__Label__c.substring(5))) {
                    this.addMonitoringPeriodOption(id, this.monitoringPeriodData[i].ampi__Label__c, frequency, status, isLocked, ischecked);
                }
            }
        }

        // console.log('###this.monitoringPeriodOptions:' + this.monitoringPeriodOptions.length);
        await this.applyFiltersToResults();
    }

    addMonitoringPeriodOption(value, label, frequency, status, isLocked, checked) {
        this.monitoringPeriodOptions.push({	
                        value: value, 
                        label: label,
                        frequency: frequency,
                        status: status,
                        isLocked: isLocked,
                        checked: checked				
        });
    }

    async changeServiceTypeHandler(event) {
        console.log('enter changeServiceTypeHandler:' + event.target.value);
        this.selectedServiceTypeValue = event.target.value;
        await this.applyFiltersToResults();
    }

    async changeGeographicAreaHandler(event) {
        console.log('enter changeGeographicAreaHandler:' + event.target.value);
        this.selectedGeographicAreaValue = event.target.value;
        await this.applyFiltersToResults();
    }

    isNumberValid(text) {
        var result = parseInt(text);

        if (!isNaN(result)) {
            return result >= 0; 
        }

        return false;
    }

    // changeIndicatorHandler(value) {

    // }

    async changeSourceDocumentHandler(event) {
        console.log('enter changeSourceDocumentHandler');
        this.selectedSourceDocumentValue = event.target.value;
        console.log('####this.selectedSourceDocumentValue 3: ' + this.selectedSourceDocumentValue);
        await this.applyFiltersToResults();
    }

    async handleIndicatorValueSearchChanged(event) {
        console.log('enter handleIndicatorValueSearchChanged');
        if (this.indicatorValueSearch === event.target.value) {
            return;
        }
		this.indicatorValueSearch = event.target.value;
        await this.applyFiltersToResults();
    }

    async handleInputValueChange(event) {
		// console.log('######parent ID: ' + event.detail['id']);
		// console.log('######parent Value: ' + event.detail['value']);
		// console.log('######parent PIGA: ' + event.detail['piga']);
		// console.log('######parent PIRP: ' + event.detail['pirp']);
		// console.log('######parent PI: ' + event.detail['pi']);
		// console.log('######parent EndPeriodDate: ' + event.detail['endperioddate']);
		// console.log('######parent Tracked: ' + event.detail['tracked']);
        // this.valuesToSave.push({sObjectType: 'ResultChanges', ID: event.detail['id'], PIGA: event.detail['piga'], PIRP: event.detail['pirp'], Value: event.detail['value'], EndPeriodDate: event.detail['endperioddate'], DataTracked: event.detail['tracked']});
        if (event.detail['piga'] == '') {
            this.showToaster('Error', 'This record is not linked to Geographic Areas.', 'error');
            return;
        }

        if (event.detail['pirp'] == '') {
            this.showToaster('Error', 'This record is not linked to Monitoring Periods.', 'error');
            return;
        }

        if (event.detail['pi'] == '') {   
            this.showToaster('Error', 'This record is not linked to Project Indicator.', 'error');
            return;
        }
        var finalValue = this.isDotDecimalSeparator ? event.detail['value'].replace(',', '.') : event.detail['value'];
        // var finalValue = event.detail['value'];
        // console.log('####this.isDotDecimalSeparator: ' + this.isDotDecimalSeparator);
        // console.log('####finalValue: ' + finalValue);
        this.valuesToSave.push({sObjectType: 'ampi__result__c', 
                                Id: event.detail['id'], 
                                ampi__Project_Indicator_Geographic_Area__c: event.detail['piga'], 
                                ampi__Project_Indicator_Reporting_Period__c: event.detail['pirp'], 
                                ampi__Project_Indicator__c: event.detail['pi'], 
                                ampi__Target_Value__c: finalValue, 
                                // ampi__Target_Value__c: event.detail['value'], 
                                ampi__Results_Current_As_Of__c: event.detail['endperioddate'], 
                                ampi__Data_Tracked__c: event.detail['tracked']});
        
        // console.log('this.valuesToSave:' + this.isDotDecimalSeparator + '/' + JSON.stringify(this.valuesToSave));
        if (this.saveManual == false) {
            await this.handleSaveClick({});
        }                                
	}

    async handleSaveClick(event) {
        // if (!this.saveManual) {
        //     const fieldToFocus = this.template.querySelector('[data-id="wildcard"]');
        //     if(fieldToFocus){
        //         fieldToFocus.focus();
        //     }
        // }

        // console.log('this.valuesToSave:' + JSON.stringify(this.valuesToSave));
        if (this.valuesToSave.length == 0) {
            this.showToaster('Warning', 'There is no records to update!', 'warning');
            return;
        }

        this.loaded = false;
        var newValues = [...this.valuesToSave];
        this.valuesToSave = [];

        console.log('newValues:' + JSON.stringify(newValues));
        var error = await saveResultChangesInBulk({results: newValues, projectId: this.projectId});

        if (error == '') {
            this.showToaster('Success', 'Records were saved successfully!', 'success');
            await this.handleClearChangesClick(false);
            this.changesSaved = true;
        } else {
            console.log('####error:' + error);
            this.showToaster('Error', 'There is an error processing the save action!!! '  + error, 'error');
        }        
        console.log('####this.saveManual:' + this.saveManual);
        if (this.saveManual == true) {
            await this.loadInitialData();
        }

        this.loaded = true;
        console.log('##### handleSaveClick');
    }

    async handleClearChangesClick(resetSelectedValues = true) {
        this.valuesToSave = [];
        console.log('####handleClearChangesClick:');
        if (resetSelectedValues) {
            this.selectedMP = undefined;
            this.selectedMonitoringPeriodValue = undefined;
            this.selectedSourceDocumentValue = undefined;
            this.selectedServiceTypeValue = undefined;
            this.selectedIndicatorValue = '';
        }
        this.fillMonitoringPeriods([]);        
        this.fillServiceTypes([]);        
        this.fillSourceDocumentIndicators([]);       

        this.indicatorValueSearch = '';        
        setTimeout(() => { this.fillLists(); }, 1000);
        await this.applyFiltersToResults(); 
    }

    fillLists() {
        this.fillMonitoringPeriods(this.dataMonitoringPeriods);        
        this.fillServiceTypes(this.dataServiceTypes);        
        this.fillSourceDocumentIndicators(this.dataSourceDocuments);       
        this.fillGeographicAreas(this.dataGeographicAreas);
        // this.selectedMonitoringPeriodValue = this.monitoringPeriodOptions[0].value;
        // this.selectedSourceDocumentValue = this.sourceDocumentOptions[0].value;
        // this.selectedServiceTypeValue = this.serviceTypeOptions[0].value;
        
        
    }

    handleSaveDataChange(event) {
        console.log('### handleSaveDataChange' + event.target.checked);    
        this.saveManual = !event.target.checked;
    }

    async handleSearchClick(event) {
        console.log('##### handleSearchClick');
        await this.loadInitialData();
    }

    showToaster(title, message, variant){
        const evt = new ShowToastEvent({
                    title: title,
                    message: message,
                    variant: variant,
                });
                this.dispatchEvent(evt);
    }

    handleCheckboxChange(event) {
        this.saveManual = event.target.checked;
    }

    
    isDotDecimalSeparatorByLanguageCode(code) {
        // console.log('####code:' + code);
        var separator = this.getDecimalSeparatorByLanguageCode(code);
        // console.log('####separator:' + separator);
        if (separator === undefined || separator !== '.') 
            return false;

        return true;
    
    }

    getDecimalSeparatorByLanguageCode(code) {
        //https://www.localeplanet.com/icu/es-PE/index.html
        var codeList = {
            "sq":           ",", // Albanian
            "sq_AL":        ",", // Albanian (Albania)
            "ar":           ".", // Arabic
            "ar_BH":        ".", // Arabic (Bahrain)
            "ar_EG":        ".", // Arabic (Egypt)
            "ar_JO":        ".", // Arabic (Jordan)
            "ar_KW":        ".", // Arabic (Kuwait)
            "ar_LB":        ".", // Arabic (Lebanon)
            "ar_QA":        ".", // Arabic (Qatar)
            "ar_SA":        ".", // Arabic (Saudi Arabia)
            "ar_AE":        ".", // Arabic (United Arab Emirates)
            "hy":           ",", // Armenian
            "hy_AM":        ",", // Armenian (Armenia)
            "az_AZ":        ",", // Azerbaijani (Azerbaijan)
            "eu":           ",", // Basque
            "eu_ES":        ",", // Basque (Spain)
            "be_BY":        ",", // Belarusian (Belarus)
            "bn_BD":        ".", // Bengali (Bangladesh)
            "bs":           ",", // Bosnian
            "bs_BA":        ",", // Bosnian (Bosnia and Herzegovina)
            "bg":           ",", // Bulgarian
            "bg_BG":        ",", // Bulgarian (Bulgaria)
            "ca":           ",", // Catalan
            "ca_ES_EURO":   ",", // Catalan (Spain,Euro)
            "ca_ES":        ",", // Catalan (Spain)
            "zh":           ".", // Chinese
            "zh_CN_PINYIN": ".", // Chinese (China, Pinyin Ordering)
            "zh_CN_STROKE": ".", // Chinese (China, Stroke Ordering)
            "zh_CN":        ".", // Chinese (China)
            "zh_HK_STROKE": ".", // Chinese (Hong Kong SAR China, Stroke Ordering)
            "zh_HK":        ".", // Chinese (Hong Kong SAR China)
            "zh_MO":        ".", // Chinese (Macau SAR China)
            "zh_SG":        ".", // Chinese (Singapore)
            "zh_TW_STROKE": ".", // Chinese (Taiwan, Stroke Ordering)
            "zh_TW":        ".", // Chinese (Taiwan)
            "hr":           ",", // Croatian
            "hr_HR":        ",", // Croatian (Croatia)
            "cs":           ",", // Czech
            "cs_CZ":        ",", // Czech (Czech Republic)
            "da":           ",", // Danish
            "da_DK":        ",", // Danish (Denmark)
            "nl":           ",", // Dutch
            "nl_BE":        ",", // Dutch (Belgium)
            "nl_NL":        ",", // Dutch (Netherlands)
            "nl_SR":        ",", // Dutch (Suriname)
            "en_AU":        ".", // English (Australia)
            "en_BB":        ".", // English (Barbados)
            "en_BM":        ".", // English (Bermuda)
            "en_CA":        ".", // English (Canada)
            "en_GH":        ".", // English (Ghana)
            "en_IN":        ".", // English (India)
            "en_ID":        ".", // English (Indonesia)
            "en_IE_EURO":   ".", // English (Ireland,Euro)
            "en_IE":        ".", // English (Ireland)
            "en_MY":        ".", // English (Malaysia)
            "en_NZ":        ".", // English (New Zealand)
            "en_NG":        ".", // English (Nigeria)
            "en_PK":        ".", // English (Pakistan)
            "en_PH":        ".", // English (Philippines)
            "en_SG":        ".", // English (Singapore)
            "en_ZA":        ".", // English (South Africa)
            "en_GB":        ".", // English (United Kingdom)
            "en_US":        ".", // English (United States)
            "et":           ",", // Estonian
            "et_EE":        ",", // Estonian (Estonia)
            "fi":           ",", // Finnish
            "fi_FI_EURO":   ",", // Finnish (Finland,Euro)
            "fi_FI":        ",", // Finnish (Finland)
            "fr":           ",", // French
            "fr_BE":        ",", // French (Belgium)
            "fr_CA":        ",", // French (Canada)
            "fr_FR_EURO":   ",", // French (France,Euro)
            "fr_FR":        ",", // French (France)
            "fr_LU":        ",", // French (Luxembourg)
            "fr_MC":        ",", // French (Monaco)
            "fr_CH":        ".", // French (Switzerland)
            "ka":           ",", // Georgian
            "ka_GE":        ",", // Georgian (Georgia)
            "de":           ",", // German
            "de_AT_EURO":   ",", // German (Austria,Euro)
            "de_AT":        ",", // German (Austria)
            "de_DE_EURO":   ",", // German (Germany,Euro)
            "de_DE":        ",", // German (Germany)
            "de_LU_EURO":   ",", // German (Luxembourg,Euro)
            "de_LU":        ",", // German (Luxembourg)
            "de_CH":        ".", // German (Switzerland)
            "el":           ",", // Greek
            "el_GR":        ",", // Greek (Greece)
            "iw":           ".", // Hebrew
            "iw_IL":        ".", // Hebrew (Israel)
            "hi":           ".", // Hindi
            "hi_IN":        ".", // Hindi (India)
            "hu":           ",", // Hungarian
            "hu_HU":        ",", // Hungarian (Hungary)
            "is":           ",", // Icelandic
            "is_IS":        ",", // Icelandic (Iceland)
            "in":           ",", // Indonesian
            "in_ID":        ",", // Indonesian (Indonesia)
            "ga":           ".", // Irish
            "ga_IE":        ".", // Irish (Ireland)
            "it":           ",", // Italian
            "it_IT":        ",", // Italian (Italy)
            "it_CH":        ".", // Italian (Switzerland)
            "ja":           ".", // Japanese
            "ja_JP":        ".", // Japanese (Japan)
            "kk_KZ":        ",", // Kazakh (Kazakhstan)
            "km_KH":        ",", // Khmer (Cambodia)
            "ky_KG":        ".", // Kirghiz (Kyrgyzstan)
            "ko":           ".", // Korean
            "ko_KR":        ".", // Korean (South Korea)
            "lv":           ",", // Latvian
            "lv_LV":        ",", // Latvian (Latvia)
            "lt":           ",", // Lithuanian
            "lt_LT":        ",", // Lithuanian (Lithuania)
            "lb":           ".", // Luxembourgish
            "lb_LU":        ".", // Luxembourgish (Luxembourg)
            "mk":           ",", // Macedonian
            "mk_MK":        ",", // Macedonian (Macedonia)
            "ms":           ".", // Malay
            "ms_BN":        ",", // Malay (Brunei)
            "ms_MY":        ".", // Malay (Malaysia)
            "mt":           ".", // Maltese
            "mt_MT":        ".", // Maltese (Malta)
            "sh_ME":        ",", // Montenegrin (Montenegro)
            "no":           ",", // Norwegian
            "no_NO":        ",", // Norwegian (Norway)
            "pl":           ",", // Polish
            "pl_PL":        ",", // Polish (Poland)
            "pt":           ",", // Portuguese
            "pt_AO":        ",", // Portuguese (Angola)
            "pt_BR":        ",", // Portuguese (Brazil)
            "pt_PT":        ",", // Portuguese (Portugal)
            "ro":           ",", // Romanian
            "ro_MD":        ",", // Romanian (Moldova)
            "ro_RO":        ",", // Romanian (Romania)
            "rm":           ".", // Romansh
            "rm_CH":        ".", // Romansh (Switzerland)
            "ru":           ",", // Russian
            "ru_RU":        ",", // Russian (Russia)
            "sr":           ",", // Serbian
            "sr_BA":        ",", // Serbian (Bosnia and Herzegovina)
            "sh":           ",", // Serbian (Latin)
            "sh_BA":        ",", // Serbian (Latin) (Bosnia and Herzegovina)
            "sh_CS":        ",", // Serbian (Latin) (Serbia and Montenegro)
            "sr_CS":        ",", // Serbian (Serbia and Montenegro)
            "sk":           ",", // Slovak
            "sk_SK":        ",", // Slovak (Slovakia)
            "sl":           ",", // Slovenian
            "sl_SI":        ",", // Slovenian (Slovenia)
            "es":           ",", // Spanish
            "es_AR":        ",", // Spanish (Argentina)
            "es_BO":        ",", // Spanish (Bolivia)
            "es_CL":        ",", // Spanish (Chile)
            "es_CO":        ",", // Spanish (Colombia)
            "es_CR":        ".", // Spanish (Costa Rica)
            "es_DO":        ".", // Spanish (Dominican Republic)
            "es_EC":        ",", // Spanish (Ecuador)
            "es_SV":        ".", // Spanish (El Salvador)
            "es_GT":        ".", // Spanish (Guatemala)
            "es_HN":        ".", // Spanish (Honduras)
            "es_MX":        ".", // Spanish (Mexico)
            "es_PA":        ".", // Spanish (Panama)
            "es_PY":        ",", // Spanish (Paraguay)
            "es_PE":        ".", // Spanish (Peru)
            "es_PR":        ".", // Spanish (Puerto Rico)
            "es_ES_EURO":   ",", // Spanish (Spain,Euro)
            "es_ES":        ",", // Spanish (Spain)
            "es_UY":        ",", // Spanish (Uruguay)
            "es_VE":        ",", // Spanish (Venezuela)
            "sv":           ",", // Swedish
            "sv_SE":        ",", // Swedish (Sweden)
            "tl":           ".", // Tagalog
            "tl_PH":        ".", // Tagalog (Philippines)
            "tg_TJ":        ".", // Tajik (Tajikistan)
            "th":           ".", // Thai
            "th_TH":        ".", // Thai (Thailand)
            "tr":           ",", // Turkish
            "tr_TR":        ",", // Turkish (Turkey)
            "uk":           ",", // Ukrainian
            "uk_UA":        ",", // Ukrainian (Ukraine)
            "ur":           ".", // Urdu
            "ur_PK":        ".", // Urdu (Pakistan)
            "vi":           ",", // Vietnamese
            "vi_VN":        ",", // Vietnamese (Vietnam)
            "cy":           ".", // Welsh
            "cy_GB":        "."  // Welsh (United Kingdom)
        };

        return codeList[code];        
    }

}