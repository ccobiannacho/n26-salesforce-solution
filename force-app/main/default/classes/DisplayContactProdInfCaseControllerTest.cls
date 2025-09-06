@IsTest
private class DisplayContactProdInfCaseControllerTest {

    @TestSetup
    static void setupData() {
        //create product
        Product2 pro = new Product2(
            Name = 'Standard',
            ProductCode = 'Standard'
        );
        insert pro;

        // Create Home Country
        Country__c hc = new Country__c(
            Name = 'ES',
            Currency__c='EUR'
        );
        insert hc;


        // Create Contact with UUID, Product, and Country
        Contact c = new Contact(
            LastName = 'N26 Contact',
            UUID__c = '12345',
            Product__c = pro.Id,
            Home_Country__c = hc.Id
        );
        insert c;


        //Create charge type
        Charge_Type__c ct = new Charge_Type__c(
            Name = 'Cost per Calendar Month',
            RecordTypeId= Schema.SObjectType.Charge_Type__c.getRecordTypeInfosByName().get('Cost').getRecordTypeId()
        );
        insert ct;

        // Create Product Information linked to Contact
        Product_Information__c pi = new Product_Information__c(
            Product__c = c.Product__c,
            Home_Country__c = c.Home_Country__c,
            Type__c=ct.Id,
            Value_Number__c = 0,
            RecordTypeId= Schema.SObjectType.Product_Information__c.getRecordTypeInfosByName().get('Cost').getRecordTypeId()
        );
        insert pi;

        Case caseRec = new Case(
            Subject = 'Test Case',
            ContactId = c.Id
        );
        insert caseRec;

    }

    @IsTest
    static void test_Success() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        //return the product information linked to the contact succesfully
        Test.startTest();
        DisplayContactProdInfCaseController.CaseProductInfoResponse resp =
            DisplayContactProdInfCaseController.getContactProdInfDetails(c.Id);
        Test.stopTest();

        System.assertEquals('', resp.errorMessage);
        System.assert(!resp.productInfoList.isEmpty());
    }

    @IsTest
    static void test_NoCase() {
        Id caseId = '500000000000000AAA'; // Non-existing Case Id

        Test.startTest();
        DisplayContactProdInfCaseController.CaseProductInfoResponse resp =
            DisplayContactProdInfCaseController.getContactProdInfDetails(caseId);
        Test.stopTest();

        System.assert(resp.errorMessage != null);
    }
}