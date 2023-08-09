import { LightningElement, track, api } from 'lwc';
import saveFile from '@salesforce/apex/csvUploaderController.saveFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from "lightning/platformResourceLoader";
import excelFileReader from "@salesforce/resourceUrl/ExcelReaderPlugin";
let XLS = {};

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Site', fieldName: 'Site', type: 'url' },
    { label: 'Account Source', fieldName: 'AccountSource' }
];

//https://absyz.com/how-to-read-excel-data-using-lwc-salesforce/
//https://www.linkedin.com/pulse/lwc-csv-file-uploader-create-records-saiful-islam
export default class CsvUploader extends LightningElement {
    @api recordid;
    @track columns = columns;
    @track data;
    @track fileName = '';
    @track uploadFile = 'Upload CSV File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;
    /*Accepted formats for the excel file*/
    strAcceptedFormats = [".xls", ".xlsx"];
    strUploadFileName; //Store the name of the selected file.
    objExcelToJSON; //Javascript object to store the content of the file    

    /*START EXCEL IMPLEMENTATION*/
    connectedCallback() {
        Promise.all([loadScript(this, excelFileReader)])
            .then(() => {
                XLS = XLSX;
            })
            .catch((error) => {
                console.log("An error occurred while processing the file");
            });
    }

    handleUploadFinished(event) {
        const strUploadedFile = event.detail.files;
        if (strUploadedFile.length && strUploadedFile != "") {
            this.strUploadFileName = strUploadedFile[0].name;
            this.handleProcessExcelFile(strUploadedFile[0]);
        }
    }

    handleProcessExcelFile(file) {
        let objFileReader = new FileReader();
        objFileReader.onload = (event) => {
            let objFiledata = event.target.result;
            console.log('objFiledata:' + objFiledata);
            console.log('XLS:' + XLS);
            let objFileWorkbook = XLS.read(objFiledata, {
                type: "binary"
            });
            var sheetName = objFileWorkbook.Workbook.Sheets.length > 0 ? objFileWorkbook.Workbook.Sheets[0].name : '';
            console.log('sheetName:' + sheetName);
            if (sheetName === '') {
                return;
            }
            this.objExcelToJSON = XLS.utils.sheet_to_row_object_array(
                objFileWorkbook.Sheets[sheetName]
            );
            console.log('objFileWorkbook:' + JSON.stringify(objFileWorkbook));
            console.log('this.objExcelToJSON:' + JSON.stringify(this.objExcelToJSON));
            //Verify if the file content is not blank
            if (this.objExcelToJSON.length === 0) {
                this.strUploadFileName = "";
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Kindly upload the file with data",
                        variant: "error"
                    })
                );
            }
            if (this.objExcelToJSON.length > 0) {
                //Remove the whitespaces from the javascript object
                Object.keys(this.objExcelToJSON).forEach((key) => {
                    const replacedKey = key.trim().toUpperCase().replace(/\s\s+/g, "_");
                    if (key !== replacedKey) {
                        this.objExcelToJSON[replacedKey] = this.objExcelToJSON[key];
                        delete this.objExcelToJSON[key];
                    }
                });
                // console.log('this.objExcelToJSON:' + this.objExcelToJSON);
            }
        };

        objFileReader.onerror = function (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error while reading the file",
                    message: error.message,
                    variant: "error"
                })
            );
        };

        objFileReader.readAsBinaryString(file);
    }
    /*END EXCEL IMPLEMENTATION*/
    /*START CSV IMPLEMENTATION*/

    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }

    handleSave() {
        if (this.filesUploaded.length > 0) {
            this.uploadHelper();
        }
        else {
            this.fileName = 'Please select a CSV file to upload!!';
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log('File Size is to long');
            return;
        }

        this.showLoadingSpinner = true;
        this.fileReader = new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            this.saveToFile();
        });
        this.fileReader.readAsText(this.file);
    }

    saveToFile() {
        saveFile({ base64Data: JSON.stringify(this.fileContents), cdbId: this.recordid })
            .then(result => {
                window.console.log('result ====> ');
                window.console.log(result);
                this.data = result;
                this.fileName = this.fileName + ' - Uploaded Successfully';
                this.isTrue = false;
                this.showLoadingSpinner = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: this.file.name + ' - Uploaded Successfully!!!',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                window.console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while uploading File',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });
    }
    /*END CSV IMPLEMENTATION*/
}