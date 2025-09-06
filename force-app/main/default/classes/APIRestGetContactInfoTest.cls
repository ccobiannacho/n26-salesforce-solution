@IsTest
private class APIRestGetContactInfoTest {

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
    }

    @IsTest
    static void test_Success() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/api/n26/12345';//existing UUID to success
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;


        //we get the info of an existing contact
        Test.startTest();
            APIRestGetContactInfo.getContactInfo();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('success'));
    }

    @IsTest
    static void test_NoContact() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/api/n26/99999'; // non-existing UUID
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;


        //we try to get an error with a non existing UUID
        Test.startTest();
            APIRestGetContactInfo.getContactInfo();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('error'));
    }
}