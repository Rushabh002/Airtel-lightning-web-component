import { LightningElement, wire,track } from 'lwc';
import fetchRecordTypeNames from '@salesforce/apex/PlanController.fetchRecordTypeNames';
import getPlansByRecordTypes from '@salesforce/apex/PlanController.getPlansByRecordTypes';
import createOrderLineRecord from '@salesforce/apex/OrderController.createOrderLineRecord';

export default class PlanDetails extends LightningElement {
    recordTypeNames = [];
    tabs = [];
    selectedRecordType;
    plansByRecordType;
    @track popupPlanValue;
    @track popupPlanData;
    @track popupPlanValidity;
    

    createOrderLine(event) {
      
        const planValue = parseFloat(event.target.dataset.planValue);
        const planId = event.target.dataset.planId;
        
        console.log('Plan Value:', planValue);
        console.log('Plan Id:', planId);

        
        createOrderLineRecord({ planAmount: planValue, planId: planId })
            .then(result => {
               
                console.log('Order Line record created successfully.');
            })
            .catch(error => {
              
                console.error('Error creating Order Line record:', error);
            });
    }

    showPopup(event) {
          
            this.popupPlanValue = event.target.dataset.planValue;
            this.popupPlanData = event.target.dataset.planData;
            this.popupPlanValidity = event.target.dataset.planValidity;

        
            const popup = this.template.querySelector('.popup');
            popup.style.display = 'block';
        }

       
        hidePopup() {
         
            const popup = this.template.querySelector('.popup');
            popup.style.display = 'none';
        }
        
    // Call the fetchRecordTypeNames Apex method wire adapter to fetch data
    @wire(fetchRecordTypeNames)
    wiredRecordTypeNames({ error, data }) {
        if (data) {
            // Set the fetched data to the recordTypeNames property
            this.recordTypeNames = data;

            // Define the sequence of record types you want
            const sequence = ['Data', 'Truly Unlimited', 'Entertainment', 'Talktime (top up voucher)', 'International Roaming', 'Inflight Roaming packs', 'Plan Vouchers'];

            // Compute the tabs array with unique keys based on record type names
            this.tabs = sequence.map(name => ({
                key: name, // Use record type name as the key
                label: name,
                class: this.selectedRecordType === name ? 'tabs-header-content active' : 'tabs-header-content'
            }));

            // Set the default selected record type
            this.selectedRecordType = sequence[0];
        } else if (error) {
            console.error('Error:', error);
        }
    }

    // Call the getPlansByRecordTypes Apex method wire adapter to fetch data for the selected record type
    @wire(getPlansByRecordTypes, { recordTypeName: '$selectedRecordType' })
    wiredRecordTypeDetails({ error, data }) {
        if (data) {
            // Populate plansByRecordType with the fetched data
            this.plansByRecordType = data;
        } else if (error) {
            console.error('Error:', error);
        }
    }

    // Getter to compute recordTypePlans based on plansByRecordType
    get recordTypePlans() {
        if (this.plansByRecordType) {
            // Define the sequence of record types you want
            const sequence = ['Data', 'Truly Unlimited', 'Entertainment', 'Talktime (top up voucher)', 'International Roaming', 'Inflight Roaming packs', 'Plan Vouchers'];

            // Iterate over the sequence and return plans in the same order
            return sequence.map(recordTypeName => ({
                recordType: recordTypeName,
                plans: this.plansByRecordType[recordTypeName] || []
            }));
        }
        return [];
    }

    scrollToDiv(event) {
        // Get the text content of the clicked element
        const tabName = event.target.textContent.trim();
        
        // Get a reference to the div you want to scroll to based on the clicked tabName
        const divToScrollTo = this.template.querySelector(`[data-tab-name="${tabName}"]`);
        
        // Scroll to the div
        if (divToScrollTo) {
            divToScrollTo.scrollIntoView({ behavior: 'smooth', block: 'start' });
            setTimeout(() => {
                // Scroll an additional 100px up
                window.scrollBy(0, -200);
            }, 1000); 
        } else {
            console.error('Div not found');
        }

        // Update styles of tabs
        const tabs = this.template.querySelectorAll('.tabs-header-content');
        tabs.forEach(tab => {
            if (tab.textContent.trim() === tabName) {
                tab.classList.add('active');
            } else {
                tab.classList.remove('active');
            }
        });
    }
    
}
