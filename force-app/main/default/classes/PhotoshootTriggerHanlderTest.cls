/**
 * @description       : 
 * @author            : Andreea Ionescu BearingPoint GmbH
 * @group             : 
 * @last modified on  : 10-17-2021
 * @last modified by  : Andreea Ionescu, BearingPoint GmbH
**/
@isTest
private class PhotoshootTriggerHanlderTest {
    
    @TestSetup
    static void makeData(){
        List<Account> photographers = TestDataFactory.createTestPhotographers();
        TestDataFactory.createTestPhotoshoots(photographers.get(0));
    }

    @isTest
    static void testInsertPhotoshootWithError() {
        List<Account> photographers = [SELECT Name, HourlyWage__c, BillingAddress FROM Account WHERE Name = 'Test 0'];

        List<Photoshoot__c> photoshoots = [SELECT Id FROM Photoshoot__c  WHERE Photographer__c = :photographers.get(0).Id];
        System.debug(photoshoots.size());
        Photoshoot__c shooting = new Photoshoot__c(Name = 'Photoshooting ',
                                                    Address__c = 'Romania, Bucharest, Primaverii',
                                                    Photographer__c = photographers.get(0).Id,
                                                    ShootingDateTime__c = DateTime.valueOf('2021-10-17 08:30:00'),
                                                    ShootingDuration__c = 1);

        try {
            insert shooting;
        } catch (Exception e) {
            System.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, The photographer has another shooting at this time!: [Photographer__c]', e.getMessage(), 'Error message is wrong!');

        }
    }

    @isTest
    static void testUpdatePhotoshoot() {
        List<Account> photographers = [SELECT Name, HourlyWage__c, BillingAddress FROM Account WHERE Name = 'Test 0'];

        List<Photoshoot__c> photoshoots = [SELECT Id FROM Photoshoot__c  WHERE Photographer__c = :photographers.get(0).Id];
        System.debug(photoshoots.size());
        Photoshoot__c shooting = new Photoshoot__c(Name = 'Photoshooting ',
                                                    Address__c = 'Romania, Bucharest, Primaverii',
                                                    Photographer__c = photographers.get(0).Id,
                                                    ShootingDateTime__c = DateTime.valueOf('2021-10-17 10:30:00'),
                                                    ShootingDuration__c = 1);

        insert shooting;
        shooting.ShootingDateTime__c = DateTime.valueOf('2021-10-17 09:27:00');
        try {
            update shooting;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}
