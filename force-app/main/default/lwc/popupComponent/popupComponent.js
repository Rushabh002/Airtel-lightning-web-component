import { LightningElement, api } from 'lwc';

export default class PopupComponent extends LightningElement {
    @api selectedPlan;
    @api showOtherDetails = false;

    handleCloseClick() {
        this.showOtherDetails = false;
    }

    @api showPlan(){
        console.log("In other detail..", this.selectedPlan);
        this.showOtherDetails = true;
    }
}