import { LightningElement, api, wire} from 'lwc';
import getPhotoshoots from '@salesforce/apex/PhotographerReportController.getPhotoshoots';
import fetchDistances from '@salesforce/apex/PhotographerReportController.fetchDistances';


const columns = [
    { label: 'Photoshoot Name', fieldName: 'Name' },
    { label: 'Address', fieldName: 'Address__c', type: 'String' },
    { label: 'Shooting Date/Time', fieldName: 'ShootingDateTime__c', type: 'DateTime' },
    { label: 'Shooting Duration', fieldName: 'ShootingDuration__c', type: 'Number' },
    { label: 'Photographer\'s earnings', fieldName: 'Price__c', type: 'currency' },
];

const columnsCosts = [
    { label: 'Date of shooting', fieldName: 'shootingDate', type: 'Date'},
    { label: 'Number of Km', fieldName: 'numberKm', type: 'Number' },
    { label: 'Cost', fieldName: 'cost', type: 'currency' },
   ];


export default class PhotographerReport extends LightningElement {
    @api recordId;
    data = [];
    columns = columns;
    columnsCosts = columnsCosts;
    costsByDay;
    connectedCallback() {

        getPhotoshoots({recordId: this.recordId})
        .then(result => {
            this.data = JSON.parse(JSON.stringify(result));
            console.log(this.data)

            fetchDistances({photoshoots : this.data, photographerId: this.recordId})
            .then(result => {
                this.costsByDay = JSON.parse(JSON.stringify(result));
                console.log(this.costsByDay)
            })
            .catch(error => {
                console.log(error);
            })
        })
        .catch(error => {
            this.error = error;
        });

    }

    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}