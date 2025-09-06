@RestResource(urlMapping='/api/n26/*')
global with sharing class APIRestGetContactInfo {
    //Allowed username to consume integration
    private static final API_Integration_User__mdt USER_INTEGRATION = [SELECT Id, Username__c FROM API_Integration_User__mdt WHERE DeveloperName = 'N26apiUser'];

    @HttpGet
    global static void getContactInfo(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try{

            //we get the UUID from the url of the request
            String uuid = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

            //we ensure only the allowed user consumes the API
            if(UserInfo.getUserName() != USER_INTEGRATION.Username__c && !Test.isRunningTest()){
                throw new SecurityException( System.Label.APIRestGetContactInfo_NotAllowedError );
            }

            //get the contact related to the UUID
            List<Contact> contacts = [
                SELECT Id, Name, Product__c, Home_Country__c 
                FROM Contact 
                WHERE UUID__c = :uuid 
                LIMIT 1
            ];
            if (contacts.isEmpty()) {
                throw new DmlException( System.Label.APIRestGetContactInfo_ContactNotFoundError );
            }
            Contact contact = contacts[0];

            //get the product information related to the contact
            List<Product_Information__c> prodInfList = [SELECT Id, Name, Product__c, Home_Country__c, Charge_Type_Name__c, Value_Display__c 
                FROM Product_Information__c 
                WHERE Product__c = :contact.Product__c 
                AND Home_Country__c = :contact.Home_Country__c];

            if(prodInfList.isEmpty()){
                throw new DmlException(System.Label.APIRestGetContactInfo_NoProdInfoError);
            }


            //we build and return our return wrapper
            List<ProductInfoWrapper> productInfoList = new List<ProductInfoWrapper>();

            for (Product_Information__c pi : prodInfList) {
                productInfoList.add(new ProductInfoWrapper(pi.Charge_Type_Name__c, pi.Value_Display__c));
            }

            Map<String, Object> responseMap = new Map<String, Object>{
                'status' => 'success',
                'uuid' => uuid,
                'charges' => productInfoList
            };

            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            res.statusCode = 200;
        }catch (Exception e){
            //in case of error we return an error response
            Map<String, Object> errorResponse = new Map<String, Object>{
                'status' => 'error',
                'message' => e.getMessage()
            };
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            res.statusCode = 400;
        }
    }

    public class ProductInfoWrapper{
        public String type;
        public String value;
        public ProductInfoWrapper(String type, String value){
            this.type = type;
            this.value = value;
        }
    }
}