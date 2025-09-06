trigger ProductInformationTrigger on Product_Information__c (before insert) {
    //is before insert
    if (Trigger.isBefore && Trigger.isInsert) {
        ProductInformationTriggerHandler.handleBeforeInsert(Trigger.new);
    }
}