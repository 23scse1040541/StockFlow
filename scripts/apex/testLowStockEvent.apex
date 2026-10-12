
Low_Stock_Event__e testEvent = new Low_Stock_Event__e(
   Inventory_Item_ID__c = 'a08g500000DW7q5AAD',
    Product_Name__c = 'Test Keyboard',
    Current_Stock__c = 3,
    Reorder_Level__c = 10
);

Database.SaveResult result = EventBus.publish(testEvent);

System.debug('Event publish accepted: ' + result.isSuccess());

if (!result.isSuccess()) {
    for (Database.Error err : result.getErrors()) {
        System.debug('Publish error: ' + err.getMessage());
    }
}
