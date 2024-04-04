public with sharing class OrderEmailHandler {
    public OrderEmailHandler() {
    }
    public static void sendOrderEmail(Decimal planAmount, String planId ,Id orderLineId) {
    
            Plan__c plan = [SELECT Plan_Value__c, Validity__c, Data__c, SMS__c, Talktime__c, Calls__c, DataTarrifID__c, SMSTarrifID__c, TncID__c 
            FROM Plan__c WHERE Plan_Value__c = :planAmount LIMIT 1];
            
            Other_Detail__c dataTarrifDetail;
            Other_Detail__c smsTarrifDetail;
            Other_Detail__c tncDetail;

            List<Other_Detail__c> dataTarrifDetails = [SELECT Type__c, Description__c FROM Other_Detail__c WHERE Id = :plan.DataTarrifID__c LIMIT 1];

            if(!dataTarrifDetails.isEmpty()) {
                dataTarrifDetail = dataTarrifDetails[0];
            }

            List<Other_Detail__c> smsTarrifDetails = [SELECT Type__c, Description__c FROM Other_Detail__c WHERE Id = :plan.SMSTarrifID__c LIMIT 1];
            if (!smsTarrifDetails.isEmpty()) {
                smsTarrifDetail = smsTarrifDetails[0];
            }

            List<Other_Detail__c> tncDetails = [SELECT Type__c, Description__c FROM Other_Detail__c WHERE Id = :plan.TncID__c LIMIT 1];
            if (!tncDetails.isEmpty()) {
                tncDetail = tncDetails[0];
            }


            String userEmail = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()].Email;
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{userEmail});
            email.setSubject('Order Line Created Successfully');
            
            
            String emailBody = 'It is to inform you that the order ' + orderLineId + ' has been created with the following plan details:.\n\n';
            emailBody += 'Plan Details \n';
            emailBody += 'Plan Value: ' + 'Rs ' +plan.Plan_Value__c;
            
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
                emailBody += '\nCalls: ' + plan.Calls__c ;
            }

            if(dataTarrifDetails !=null || smsTarrifDetails !=null ||   tncDetails !=null){
                emailBody += '\n\nOther Details \n';
            }
            if (dataTarrifDetail != null) {
                emailBody += 'Data Tariff Description: ' + dataTarrifDetail.Description__c + '\n';
            }
            if (smsTarrifDetail != null) {
                emailBody += 'SMS Tariff Description: ' + smsTarrifDetail.Description__c + '\n';
            }
            if (tncDetail != null) {
                emailBody += 'Terms and Conditions URL: ' + tncDetail.Description__c + '\n\n';
            }
            emailBody += 'This is a system generated email.\n';

            email.setPlainTextBody(emailBody);
            Messaging.sendEmail(new List<Messaging.Email>{email});
        }
            
}