public class ProductInformationTriggerHandler {

    public static void handleBeforeInsert(List<Product_Information__c> newProdInf) {
        //we ensure that we don't create duplicates
        Set<Id> productIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();
        Set<String> typeIds = new Set<String>();
        Map<String,String> existingPiKeysNames = new Map<String,String>();
        Set<String> uniquePiKeysNew = new Set<String>();

        for (Product_Information__c pi : newProdInf) {
            if (pi.Product__c != null) productIds.add(pi.Product__c);
            if (pi.Home_Country__c != null) countryIds.add(pi.Home_Country__c);
            if (pi.Type__c != null) typeIds.add(pi.Type__c);
        }

        // query for existing Product Information records, we add the current products and countries Ids to avoid hitting limits in the future
        List<Product_Information__c> existingProdInf = [
            SELECT Id, Type__c, Product__c, Home_Country__c, Name
            FROM Product_Information__c
            WHERE Product__c IN :productIds
            AND Home_Country__c IN :countryIds
            AND Type__c IN : typeIds
        ];

        //geenrate a key to control dupes
        for (Product_Information__c pi : existingProdInf) {
            existingPiKeysNames.put(pi.Type__c + '-' + pi.Home_Country__c + '-' + pi.Product__c,pi.Name);
        }

        //we ensure there are no duplicates in the DB or in the same transaction
        for (Product_Information__c pi : newProdInf) {
            String key = pi.Type__c + '-' + pi.Home_Country__c + '-' + pi.Product__c;

            // already exists in DB
            if (existingPiKeysNames.containsKey(key)) {
                pi.addError(
                    System.Label.ProductInformationTriggerHandler_ProdInfExistsError+existingPiKeysNames.get(key)
                );
            }

            // duplicated in the same transaction
            if (uniquePiKeysNew.contains(key)) {
                pi.addError(
                    System.Label.ProductInformationTriggerHandler_ProdInfAddedError
                );
            } else {
                uniquePiKeysNew.add(key);
            }
        }
    }
}