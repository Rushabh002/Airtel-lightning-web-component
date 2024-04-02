public with sharing class PlanController {
    public PlanController() {

    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> fetchRecordTypeNames() {
        List<String> recordTypeNames = new List<String>();
        // Query record type names associated with the Plan object
        for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Plan__c' AND IsActive = true]) {
            recordTypeNames.add(rt.Name);
        }
        return recordTypeNames;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Plan__c>> getPlansByRecordTypes() {
        Map<String, List<Plan__c>> plansByRecordTypes = new Map<String, List<Plan__c>>();
        
        // Query Plans along with Record Type information
        for (Plan__c plan : [SELECT Id, Name, Plan_Value__c, Data__c, Validity__c, RecordType.Name FROM Plan__c]) {
            String recordTypeName = plan.RecordType.Name;
            
            if (!plansByRecordTypes.containsKey(recordTypeName)) {
                plansByRecordTypes.put(recordTypeName, new List<Plan__c>());
            }
            
            plansByRecordTypes.get(recordTypeName).add(plan);
        }

        return plansByRecordTypes;
    }
}