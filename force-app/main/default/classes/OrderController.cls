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
            

            Plan__c plan = [SELECT Plan_Value__c, Validity__c, Data__c, SMS__c, Talktime__c, Calls__c,Details__c FROM Plan__c WHERE Plan_Value__c = :planAmount LIMIT 1];

            System.debug(plan);   
            String userEmail = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()].Email;
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{userEmail});
            email.setSubject('Order Line Created Successfully');
            

            String emailBody = 'Your Order Line has been created successfully.\n\n';
            emailBody += 'Plan Details \n';
            emailBody += 'Plan Value: ' + plan.Plan_Value__c;
            
            if(plan.Validity__c != null) {
                emailBody += '\nValidity: ' + plan.Validity__c;
            }
            if(plan.Data__c != null) {
                emailBody += '\nData: ' + plan.Data__c;
            }
            if(plan.SMS__c != null) {
                emailBody += '\nSms: ' + plan.SMS__c;
            }
            if(plan.Talktime__c != null) {
                emailBody += '\nTalktime: ' + plan.Talktime__c;
            }
            if(plan.Calls__c != null) {
                emailBody += '\nCalls: ' + plan.Calls__c;
            }
            if(plan.Details__c != null) {
                emailBody += '\nCalls: ' + plan.Details__c;
            }
            
            email.setPlainTextBody(emailBody);
            
            Messaging.sendEmail(new List<Messaging.Email>{email});
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating Order Line record: ' + e.getMessage());
        }
    }
}