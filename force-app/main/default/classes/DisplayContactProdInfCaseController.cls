public with sharing class DisplayContactProdInfCaseController {
    
    @AuraEnabled
    public static CaseProductInfoResponse getContactProdInfDetails(Id caseId) {
        CaseProductInfoResponse response = new CaseProductInfoResponse();

        Case caseRecord;

        //based on the caseId we get the contact and its product fields
        try {
            caseRecord = [
                SELECT Id, ContactId, Contact.Product__c, Contact.Home_Country__c
                FROM Case
                WHERE Id = :caseId
            ];
        } catch (QueryException qe) {
            //no case id
            response.setError(System.Label.DisplayContactProdInfCaseController_NoIdError);
            return response;
        }

        //no contact Id
        if (caseRecord.ContactId == null) {
            response.setError(System.Label.DisplayContactProdInfCaseController_NoContactError);
            return response;
        }

        //no product or home country in contact
        if (caseRecord.Contact.Product__c == null || caseRecord.Contact.Home_Country__c == null) {
            response.setError(System.Label.DisplayContactProdInfCaseController_NoProdCountryError);
            return response;
        }

        //we get the product information 
        List<Product_Information__c> prodInfList = [
            SELECT Id, Name, Product__c, Home_Country__c, Charge_Type_Name__c, Value_Display__c
            FROM Product_Information__c
            WHERE Product__c = :caseRecord.Contact.Product__c
            AND Home_Country__c = :caseRecord.Contact.Home_Country__c
        ];

        //no product info for that contact product and country
        if (prodInfList.isEmpty()) {
            response.setError(System.Label.DisplayContactProdInfCaseController_NoProdInfError);
            return response;
        }

        // we generate our return wrapper list
        for (Product_Information__c pi : prodInfList) {
            response.productInfoList.add(new ProductInfoWrapper(pi.Charge_Type_Name__c, pi.Value_Display__c));
        }

        return response;
    }

    // ------------------------- return wrappers ---------------------------

    public class ProductInfoWrapper {

        @AuraEnabled public String type;
        @AuraEnabled public String value;

        public ProductInfoWrapper(String type, String value) {
            this.type = type;
            this.value = value;
        }
    }

    public class CaseProductInfoResponse {

        @AuraEnabled public List<ProductInfoWrapper> productInfoList { get; private set; }
        @AuraEnabled public String errorMessage { get; private set; }

        public CaseProductInfoResponse() {
            productInfoList = new List<ProductInfoWrapper>();
            errorMessage = '';
        }
        public void setError(String message) {
            this.errorMessage = message;
        }
    }
}