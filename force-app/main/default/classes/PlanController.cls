public with sharing class PlanController {
    public PlanController() {

    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> fetchRecordTypeNames() {
        List<String> recordTypeNames = new List<String>();

        for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Plan__c' AND IsActive = true]) {
            recordTypeNames.add(rt.Name);
        }
        return recordTypeNames;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<PlanWrapper>> getPlansByRecordTypes() {
        // Query Plans along with Record Type information and related Additional Benefits
        List<Plan__c> plans = [SELECT Id, Name, Plan_Value__c, Data__c, Details__c, Validity__c, Calls__c, SMS__c, Talktime__c, DataTarrifID__r.Description__c, SMSTarrifID__r.Description__c, TncID__r.Description__c, RecordType.Name,
                               (SELECT Additional_Benefit__r.Id, Additional_Benefit__r.Name__c, Additional_Benefit__r.Company_Name__c, Additional_Benefit__r.Details__c, Additional_Benefit__r.Icon__c 
                                FROM PlanAdditionalDetails__r)
                               FROM Plan__c];
    
        Map<String, List<PlanWrapper>> plansByRecordTypes = new Map<String, List<PlanWrapper>>();
    
        // Process query results and populate map
        for (Plan__c plan : plans) {
            String recordTypeName = plan.RecordType.Name;
    
            if (!plansByRecordTypes.containsKey(recordTypeName)) {
                plansByRecordTypes.put(recordTypeName, new List<PlanWrapper>());
            }
    
            // Create a PlanWrapper object to hold both the plan and its associated additional benefits
            PlanWrapper planWrapper = new PlanWrapper();
            planWrapper.plan = plan;
    
            // Retrieve associated additional benefits from the related list
            for (PlanAdditionalDetail__c detail : plan.PlanAdditionalDetails__r) {
                Additional_Benefit__c additionalBenefit = detail.Additional_Benefit__r;
                planWrapper.additionalBenefits.add(additionalBenefit);
            }
    
            plansByRecordTypes.get(recordTypeName).add(planWrapper);
        }
    
        return plansByRecordTypes;
    }

    public class PlanWrapper {

        @AuraEnabled public Plan__c plan;
        @AuraEnabled public List<Additional_Benefit__c> additionalBenefits;

        public PlanWrapper() {
            additionalBenefits = new List<Additional_Benefit__c>();
        }
    }
}