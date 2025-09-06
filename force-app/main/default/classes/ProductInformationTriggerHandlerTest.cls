@IsTest
private class ProductInformationTriggerHandlerTest {

    @TestSetup
    static void setupData() {
        //we create the product
        Product2 p = new Product2(
            Name = 'Standard',
            ProductCode = 'Standard'
        );
        insert p;

        // Create Home Country
        Country__c hc = new Country__c(
            Name = 'ES',
            Currency__c='EUR'
        );
        insert hc;

        //Create charge type
        Charge_Type__c ct = new Charge_Type__c(
            Name = 'Cost per Calendar Month',
            RecordTypeId= Schema.SObjectType.Charge_Type__c.getRecordTypeInfosByName().get('Cost').getRecordTypeId()
        );
        insert ct;

        // Create Product Information linked to Contact
        Product_Information__c pi = new Product_Information__c(
            Product__c = p.Id,
            Home_Country__c = hc.Id,
            Type__c=ct.Id,
            Value_Number__c = 0,
            RecordTypeId= Schema.SObjectType.Product_Information__c.getRecordTypeInfosByName().get('Cost').getRecordTypeId()
        );
        insert pi;
    }

    @IsTest
    static void test_DuplicateInPI() {
        //test for duplicates in DB

        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Standard' LIMIT 1];
        Country__c hc = [SELECT Id FROM Country__c WHERE Name = 'ES' LIMIT 1];
        Charge_Type__c ct = [SELECT Id FROM Charge_Type__c WHERE Name = 'Cost per Calendar Month' LIMIT 1];

        Product_Information__c pi = new Product_Information__c(
            Product__c = p.Id,
            Home_Country__c = hc.Id,
            Type__c=ct.Id,
            Value_Number__c = 6,
            RecordTypeId= Schema.SObjectType.Product_Information__c.getRecordTypeInfosByName().get('Cost').getRecordTypeId()
        );
        insert pi;

        Test.startTest();
            Database.SaveResult sr = Database.insert(pi, false);
        Test.stopTest();

        System.assert(!sr.isSuccess(), 'Fail due to duplicate');
    }

    @IsTest
    static void test_DuplicateInSameTransaction() {
        //test for duplicates in the same insertion

        Product2 p = new Product2(
            Name = 'Metal',
            ProductCode = 'Metal'
        );
        insert p;

        Country__c hc = [SELECT Id FROM Country__c WHERE Name = 'ES' LIMIT 1];
        Charge_Type__c ct = [SELECT Id FROM Charge_Type__c WHERE Name = 'Cost per Calendar Month' LIMIT 1];


        // Create Product Information linked to Contact
        Product_Information__c pi1 = new Product_Information__c(
            Product__c = p.Id,
            Home_Country__c = hc.Id,
            Type__c=ct.Id,
            Value_Number__c = 0,
            RecordTypeId= Schema.SObjectType.Product_Information__c.getRecordTypeInfosByName().get('Cost').getRecordTypeId()
        );
        insert pi1;

        Product_Information__c pi2 = new Product_Information__c(
            Product__c = p.Id,
            Home_Country__c = hc.Id,
            Type__c=ct.Id,
            Value_Number__c = 0,
            RecordTypeId= Schema.SObjectType.Product_Information__c.getRecordTypeInfosByName().get('Cost').getRecordTypeId()
        );
        insert pi2;

        Test.startTest();
            Database.SaveResult[] results = Database.insert(new List<Product_Information__c>{pi1, pi2}, false);
        Test.stopTest();

        System.assert(!results[1].isSuccess(), 'Fail due to duplicate in transaction');
    }

    @IsTest
    static void test_InsertRecord() {
        //test for addition of a new product
        
        Product2 p = new Product2(
            Name = 'Go',
            ProductCode = 'Go'
        );
        insert p;

        Country__c hc = [SELECT Id FROM Country__c WHERE Name = 'ES' LIMIT 1];
        Charge_Type__c ct = [SELECT Id FROM Charge_Type__c WHERE Name = 'Cost per Calendar Month' LIMIT 1];

        // Create Product Information linked to Contact
        Product_Information__c pi = new Product_Information__c(
            Product__c = p.Id,
            Home_Country__c = hc.Id,
            Type__c=ct.Id,
            Value_Number__c = 0,
            RecordTypeId= Schema.SObjectType.Product_Information__c.getRecordTypeInfosByName().get('Cost').getRecordTypeId()
        );
        insert pi;

        Test.startTest();
            insert pi;
        Test.stopTest();

        System.assertNotEquals(null, pi.Id, 'Record inserted');
    }
}