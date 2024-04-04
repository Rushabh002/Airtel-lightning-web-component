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
        
    @wire(fetchRecordTypeNames)
    wiredRecordTypeNames({ error, data }) {
        if (data) {
          
            this.recordTypeNames = data;

            
            const sequence = ['Data', 'Truly Unlimited', 'Entertainment', 'Talktime (top up voucher)', 'International Roaming', 'Inflight Roaming packs', 'Plan Vouchers'];

           
            this.tabs = sequence.map(name => ({
                key: name, 
                label: name,
                class: this.selectedRecordType === name ? 'tabs-header-content active' : 'tabs-header-content'
            }));

            this.selectedRecordType = sequence[0];
        } else if (error) {
            console.error('Error:', error);
        }
    }

    @wire(getPlansByRecordTypes, { recordTypeName: '$selectedRecordType' })
    wiredRecordTypeDetails({ error, data }) {
        if (data) {
            this.plansByRecordType = data;
        } else if (error) {
            console.error('Error:', error);
        }
    }

   
    get recordTypePlans() {
        if (this.plansByRecordType) {
         
            const sequence = ['Data', 'Truly Unlimited', 'Entertainment', 'Talktime (top up voucher)', 'International Roaming', 'Inflight Roaming packs', 'Plan Vouchers'];

            return sequence.map(recordTypeName => ({
                recordType: recordTypeName,
                plans: this.plansByRecordType[recordTypeName] || []
            }));
        }
        return [];
    }

    scrollToDiv(event) {
        const tabName = event.target.textContent.trim();
        
        const divToScrollTo = this.template.querySelector(`[data-tab-name="${tabName}"]`);
        
        if (divToScrollTo) {
            divToScrollTo.scrollIntoView({ behavior: 'smooth', block: 'start' });
            setTimeout(() => {
                window.scrollBy(0, -200);
            }, 1000); 
        } else {
            console.error('Div not found');
        }

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
