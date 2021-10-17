/**
 * @description       : 
 * @author            : Andreea Ionescu BearingPoint GmbH
 * @group             : 
 * @last modified on  : 10-18-2021
 * @last modified by  : Andreea Ionescu, BearingPoint GmbH
**/
@isTest
private class PhotographerReportControllerTest {
 
    @TestSetup
    static void makeData(){
        List<Account> photographers = TestDataFactory.createTestPhotographers();
        TestDataFactory.createTestPhotoshoots(photographers.get(0));
    }


    @isTest
    static void testGetPhotoshoots() {
        List<Account> photographers = [SELECT Name, HourlyWage__c, BillingAddress FROM Account WHERE Name = 'Test 0'];

        List<Photoshoot__c> photoshoots = PhotographerReportController.getPhotoshoots(photographers.get(0).Id);
        System.assertEquals(photoshoots.size(), 1, 'Number of photoshoots is wrong!');

      
    }

    @isTest
    static void  testFetchDistances() {
        List<Account> photographers = [SELECT Name, HourlyWage__c, BillingAddress FROM Account WHERE Name = 'Test 0'];
        List<Photoshoot__c> photoshoots = PhotographerReportController.getPhotoshoots(photographers.get(0).Id);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DirectionApiHttpCalloutMock());
        List<PhotographerReportController.DistanceWrapper> distancewrapper = PhotographerReportController.fetchDistances(photoshoots, photographers.get(0).Id);
        Test.stopTest(); }
}
