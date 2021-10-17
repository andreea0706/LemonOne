import { LightningElement, api} from 'lwc';

export default class GenerateReportButton extends LightningElement {

    @api recordId;
    showReport = false;
    
    handleClickShowReport() {
        this.showReport = true;
    }

    handleCloseModal() {
        this.showReport = false;
    }
}