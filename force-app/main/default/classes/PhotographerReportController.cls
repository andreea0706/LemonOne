/**
 * @description       : 
 * @author            : Andreea Ionescu BearingPoint GmbH
 * @group             : 
 * @last modified on  : 10-17-2021
 * @last modified by  : Andreea Ionescu, BearingPoint GmbH
**/
public with sharing class PhotographerReportController {
   
    public class DistanceWrapper {
        @AuraEnabled
       public  Date shootingDate;

        @AuraEnabled
        public Decimal numberKm;
        
        @AuraEnabled
        public List<Photoshoot__c> photoshoots = new List<Photoshoot__c>();
        
        @AuraEnabled
        public Decimal cost;
    }

    public static final String API_KEY = System.Label.API_KEY;

    @AuraEnabled
    public static List<Photoshoot__c> getPhotoshoots(String recordId){
        try {
            if (String.isNotBlank(recordId)) {
                return getPhotoshootsList(recordId);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static List<DistanceWrapper> fetchDistances(List<Photoshoot__c> photoshoots, String photographerId) {
        try {
            String photographerAddress = getPhotographerAddress(photographerId);
            Map<Date, List<Photoshoot__c>> photoshootsByDate = buildMapShootingsByDate(photoshoots);
            List<DistanceWrapper> distanceWrapper = new List<DistanceWrapper>();


           for (Date dateKey : photoshootsByDate.keySet()) {
                DistanceWrapper wrapper = new DistanceWrapper();
                wrapper.shootingDate = dateKey;
                String waypoints = '';
                for (Photoshoot__c photoshoot : photoshootsByDate.get(dateKey)) {
                    wrapper.photoshoots.add(photoshoot);
                    waypoints += photoshoot.Address__c + '|';
                }
                System.debug('Waypoint ' + waypoints);
                Http http = new Http();
                HttpRequest request = new HttpRequest(); 
                String url = (photographerAddress + '&destination=' + photographerAddress + '&waypoints=' + waypoints + '&key=' + API_KEY).replace(' ', '%20');
                request.setEndpoint('https://maps.googleapis.com/maps/api/directions/json?origin=' + url);
                System.debug(request.getEndpoint());
                request.setMethod('GET');  
                HttpResponse response = http.send(request);

                if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                    System.debug(response.getBody());
                    wrapper.numberKm = getTotalNumberOfKm(response.getBody());
                    if (wrapper.numberKm != null) {
                        wrapper.cost = wrapper.numberKm > 11 ? 0.2 * (wrapper.numberKm - 11) : 0;
                    }
                }
                distanceWrapper.add(wrapper);
           }
              
            return distanceWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Decimal getTotalNumberOfKm(String resposeBody) {

        Decimal numerOfKm = 0;
        JSONParser parser = JSON.createParser(resposeBody);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME &&
                parser.getText() == 'steps') {
                parser.nextToken();
                parser.skipChildren();
            } else if (parser.getCurrentToken() == JSONToken.VALUE_STRING &&
            parser.getText().contains('km')) {
                String[] strArr =  parser.getText().split(' ');
                numerOfKm += decimal.valueOf(strArr[0]);
            }
        }
        System.debug(numerOfKm);
        return numerOfKm;
    }


    private static String getPhotographerAddress(String photographerId) {
        Account photographer = getPhotographer(photographerId);
        if (photographer != null) {
            return photographer.BillingCountry + ',' +
                                photographer.BillingCity + ',' +
                                photographer.BillingStreet + ',' +
                                photographer.BillingPostalCode;

        }
        return null;
    }

    private static  Map<Date, List<Photoshoot__c>> buildMapShootingsByDate(List<Photoshoot__c> photoshoots) {
        Map<Date, List<Photoshoot__c>> photoshootsByDate = new Map<Date, List<Photoshoot__c>>();

        for (Photoshoot__c photoshoot : photoshoots) {
            if (!photoshootsByDate.containsKey(photoshoot.ShootingDateTime__c.date())) {
             photoshootsByDate.put(photoshoot.ShootingDateTime__c.date(), new List<Photoshoot__c>());
            }
            photoshootsByDate.get(photoshoot.ShootingDateTime__c.date()).add(photoshoot);
        }

        return photoshootsByDate;
    }


    private static List<Photoshoot__c> getPhotoshootsList(String recordId) {
        return [SELECT Id, 
                        Name,
                        ShootingDateTime__c,
                        ShootingDuration__c,
                        Address__c,
                        Price__c
                FROM Photoshoot__c
                WHERE Photographer__c = :recordId
                WITH SECURITY_ENFORCED
                ORDER BY ShootingDateTime__c ASC
                ];
    }

    private static Account getPhotographer(String recordId) {
        return [SELECT Id, 
                        BillingCountry,
                        BillingCity,
                        BillingStreet, 
                        BillingPostalCode
                FROM Account
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
                LIMIT 1];
    }
}