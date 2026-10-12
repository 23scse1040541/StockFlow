@IsTest
private class InventoryServiceTest {

    @IsTest
    static void testGetLowStockItems() {

        // Create a test Product
        Product2 product = new Product2(
            Name = 'Test Keyboard',
            IsActive = true
        );
        insert product;

        // Create a low-stock Inventory Item
        Inventory_Item__c inventoryItem = new Inventory_Item__c(
            Product__c = product.Id,
            Current_Stock__c = 5,
            Reorder_Level__c = 10,
            Reorder_Quantity__c = 20,
            Unit_Price__c = 3000,
            Supplier_Email__c = 'test@example.com',
            Active__c = true
        );
        insert inventoryItem;

        // Start test execution
        Test.startTest();

        List<Inventory_Item__c> result =
            InventoryService.getLowStockItems();

        Test.stopTest();

        // Verify that one low-stock item is returned
        System.assertEquals(
            1,
            result.size(),
            'One low-stock inventory item should be returned.'
        );

        // Verify the returned record
        System.assertEquals(
            inventoryItem.Id,
            result[0].Id,
            'The returned inventory item should match the test record.'
        );
    }
}