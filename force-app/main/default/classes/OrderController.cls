public with sharing class OrderController {
    public OrderController() {

    }

    @AuraEnabled
    public static void createOrderLineRecord(Decimal planAmount, String planId) {   
        try {
            System.debug('Received Plan Amount: ' + planAmount);
            System.debug('Received Plan Id: ' + planId);
            
            Order_Line__c orderLine = new Order_Line__c();
            orderLine.Plan_Amount__c = planAmount;
            orderLine.Plan__c = planId;
            System.debug(orderLine);
            insert orderLine;
            

            Order order = new Order();
            order.AccountId = '001GB00003ARvGaYAL';
            order.EffectiveDate = Date.today();
            order.Status = 'Draft';
            order.Order_Line__c = orderLine.Id;
            insert order;

            
            // OrderEmailHandler.sendOrderEmail(planAmount, planId,orderLine.Id);
        } catch (Exception e) {
            throw new AuraHandledException('Error creating Order Line record: ' + e.getMessage());
        }
    }
}