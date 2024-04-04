import { LightningElement, api } from 'lwc';

export default class PopupComponent extends LightningElement {
    @api plan; 


    hidePopup() {
        this.popupStyle = 'display: none;';
    }
}