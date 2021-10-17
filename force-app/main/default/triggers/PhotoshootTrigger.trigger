/**
 * @description       : 
 * @author            : Andreea Ionescu BearingPoint GmbH
 * @group             : 
 * @last modified on  : 10-16-2021
 * @last modified by  : Andreea Ionescu, BearingPoint GmbH
**/
trigger PhotoshootTrigger on Photoshoot__c (before insert, before update) {

    switch on trigger.operationType {
        when BEFORE_INSERT {
            PhotoshootTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            PhotoshootTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}