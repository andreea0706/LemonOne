/**
 * @description       : 
 * @author            : Andreea Ionescu BearingPoint GmbH
 * @group             : 
 * @last modified on  : 10-17-2021
 * @last modified by  : Andreea Ionescu, BearingPoint GmbH
**/
@isTest
public class TestDataFactory {
  
    public static List<Account> createTestPhotographers() {
        List<Account> photographers = new List<Account>();

        for (Integer index = 0; index < 1; index++) {
            Account photographer = new Account(Name = 'Test ' + index,
                                                HourlyWage__c = 100,
                                                BillingCountry = 'Romania',
                                                BillingCity= 'Bucharest',
                                                BillingStreet= 'Iuliu Maniu',
                                                BillingPostalCode = '061103');
            photographers.add(photographer);

        }
        insert photographers;
        return photographers;
    }


    public static List<Photoshoot__c> createTestPhotoshoots(Account photographer) {
        List<Photoshoot__c> photoshoots = new List<Photoshoot__c>();
        for (Integer index = 0; index < 1; index++) {
            Photoshoot__c shooting = new Photoshoot__c(Name = 'Photoshooting ' + index,
                                                Address__c = 'Romania, Bucharest, Primaverii',
                                                Photographer__c = photographer.Id,
                                                ShootingDateTime__c = DateTime.valueOf('2021-10-17 08:00:00').addMinutes(index * 30),
                                                ShootingDuration__c = 1);
            photoshoots.add(shooting);

        }

        insert photoshoots;
        return photoshoots;

    }
}
