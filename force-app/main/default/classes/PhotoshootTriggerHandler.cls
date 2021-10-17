/**
 * @description       : 
 * @author            : Andreea Ionescu BearingPoint GmbH
 * @group             : 
 * @last modified on  : 10-17-2021
 * @last modified by  : Andreea Ionescu, BearingPoint GmbH
**/
public with sharing class PhotoshootTriggerHandler {
   
    static final Integer BREAK_BETWEEN_SHOOTINGS = 30;

    public static void handleBeforeInsert(List<Photoshoot__c> photoshoots) {   
        buildMapAndValidate(photoshoots);
    }

    public static void handleBeforeUpdate(Map<Id, Photoshoot__c> newPhotoshoots, Map<Id, Photoshoot__c> oldPhotoshoots) {
        List<Photoshoot__c> updatedPhotoshoots = new List<Photoshoot__c>();
        for (Id photoshootId : newPhotoshoots.keySet()) {
            if (newPhotoshoots.get(photoshootId).Photographer__c != oldPhotoshoots.get(photoshootId).Photographer__c ||
                newPhotoshoots.get(photoshootId).ShootingDateTime__c != oldPhotoshoots.get(photoshootId).ShootingDateTime__c ||
                newPhotoshoots.get(photoshootId).ShootingDuration__c != oldPhotoshoots.get(photoshootId).ShootingDuration__c) 
            {
                updatedPhotoshoots.add(newPhotoshoots.get(photoshootId));
            }
        }
        buildMapAndValidate(updatedPhotoshoots);
    }


    private static void buildMapAndValidate(List<Photoshoot__c> photoshoots) {
        Map<Id, Photoshoot__c> photographersByPhotoshoot = new Map<Id, Photoshoot__c>();
        if (!photoshoots.isEmpty()) {
            for (Photoshoot__c photoshoot : photoshoots) {
                if (!String.isBlank(photoshoot.Photographer__c)) {
                    photographersByPhotoshoot.put(photoshoot.Photographer__c, photoshoot);
                }
            }

            if (!photographersByPhotoshoot.isEmpty()) {
                validateAsignmentToPhotoshoot(photographersByPhotoshoot);
            }
        }
    }


    private static void validateAsignmentToPhotoshoot(Map<Id, Photoshoot__c> photographersByPhotoshoot) {

        List<Account> photographersWithSootings = getPhotographersWithShootings(photographersByPhotoshoot.keySet());
        Map<Id, List<Photoshoot__c>> photographerByPhotoshoots = buildMapPhotographerWithShootings(photographersWithSootings);

        if (!photographerByPhotoshoots.isEmpty()) {
            for (Id photographerId : photographerByPhotoshoots.keySet()) {
                if (!photographerByPhotoshoots.get(photographerId).isEmpty()) {
                    for (Photoshoot__c photoshoot : photographerByPhotoshoots.get(photographerId)) {

                        if (checkNewShootingOverlapsWithPhotogrpherBreak(photographersByPhotoshoot.get(photographerId),photoshoot)) {
                            //The new shooting interfere with the photographer's break
                            photographersByPhotoshoot.get(photographerId).Photographer__c.addError('The photographer needs a break of 30 minutes between shootings!');

                        } else if (checkNewShootingOverlapsWithAnExistingOne(photographersByPhotoshoot.get(photographerId),photoshoot)) {
                            // The nre shooting intefere with one of the existing shootings
                            photographersByPhotoshoot.get(photographerId).Photographer__c.addError('The photographer has another shooting at this time!');
                        } else {
                            continue;
                        }
                    }
                }
            }
        }       
    }

    private static Boolean checkNewShootingOverlapsWithAnExistingOne(Photoshoot__c newShooting, Photoshoot__c existingShooting) {
        return newShooting.ShootingDateTime__c.date() == existingShooting.ShootingDateTime__c.date() &&
        newShooting.ShootingDateTime__c.time() >= existingShooting.ShootingDateTime__c.time() &&
        newShooting.ShootingDateTime__c.time() <= existingShooting.ShootingDateTime__c.time().addMinutes((Integer) (existingShooting.ShootingDuration__c * 60));
    }

    private static Boolean checkNewShootingOverlapsWithPhotogrpherBreak(Photoshoot__c newShooting, Photoshoot__c existingShooting) {
        return newShooting.ShootingDateTime__c.date() == existingShooting.ShootingDateTime__c.date() &&
        newShooting.ShootingDateTime__c.time() > (existingShooting.ShootingDateTime__c.time().addMinutes((Integer) (existingShooting.ShootingDuration__c * 60))) &&
        newShooting.ShootingDateTime__c.time() < (existingShooting.ShootingDateTime__c.time().addMinutes((Integer) (existingShooting.ShootingDuration__c * 60))).addMinutes(BREAK_BETWEEN_SHOOTINGS);
    }


    private static List<Account> getPhotographersWithShootings(Set<Id> photographersIds) {
        return [SELECT Id,
            Name,
            (SELECT Id, 
                ShootingDateTime__c,
                ShootingDuration__c
            FROM Photoshoots__r
            ORDER BY ShootingDateTime__c DESC)
        FROM Account
        WHERE Id IN :photographersIds
        WITH SECURITY_ENFORCED];
    }

    private static Map<Id, List<Photoshoot__c>> buildMapPhotographerWithShootings(List<Account> photographersWithSootings) {
        Map<Id, List<Photoshoot__c>> photographerByPhotoshoots = new  Map<Id, List<Photoshoot__c>>();
        for (Account photographer : photographersWithSootings)  {
            if (!photographer.Photoshoots__r.isEmpty()) {
                photographerByPhotoshoots.put(photographer.Id, photographer.Photoshoots__r);
            } else {
                photographerByPhotoshoots.put(photographer.Id, new List<Photoshoot__c>());

            }
        }
        return photographerByPhotoshoots;
    }
}