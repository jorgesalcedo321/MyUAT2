import {LightningElement, api} from 'lwc';
import getDataFromProject from '@salesforce/apex/crossTable.getDataFromProject';

export default class RedirectToPage extends LightningElement {
    @api recordId;
    @api env;
    @api url;
    @api buttonName;
    currentProject = null;

    async connectedCallback() {
        // this.env = 'https://soscv--developer5.sandbox.my.site.com/s/report/00O26000001TX8SEAW/activity-schedule-report-test=';
        this.currentProject = await getDataFromProject({projectId: this.recordId});
        console.log('###this.currentProject: ' + JSON.stringify(this.currentProject));
        if (this.currentProject !== null) {
            // this.url = '[{%22column%22:%22ampi__Project__c.Project_ID_Text__c%22,%22operator%22:%22equals%22,%22value%22:%22__PROJECTIDTEXT__%22}]';       
            this.url = (this.url + '').replace('__PROJECTIDTEXT__', this.currentProject.Project_ID_Text__c);
            console.log('###dynamic url: ' + this.url);
            console.log('###full url: ' + this.env + this.url);
            // this.url = '[{%22column%22:%22ampi__Project__c.Project_ID_Text__c%22,%22operator%22:%22equals%22,%22value%22:%22' + this.currentProject.Project_ID_Text__c + '%22}]';        
        }
    }

    async handleRedirectClick(event)  {
        if (this.currentProject === null) {
            console.log('####handleRedirectClick: there is no currentProject assigned');
            return;
        }
        
        window.location.href = this.env + this.url;
        //[{%22column%22:%22ampi__Project__c.Project_ID_Text__c%22,%22operator%22:%22equals%22,%22value%22:%22{!ampi__Project__c.Project_ID_Text__c}%22}]
    }
}