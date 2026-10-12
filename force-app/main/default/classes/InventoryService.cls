public with sharing class InventoryService {

    /*
     * Method Name: getLowStockItems
     *
     * Purpose:
     * Returns all active inventory items where the
     * current stock is less than or equal to the reorder level.
     *
     * Business Rule:
     * Current Stock <= Reorder Level
     */
    public static List<Inventory_Item__c> getLowStockItems() {

        // Query all active inventory items.
        List<Inventory_Item__c> lowStockItems = [
            SELECT Id,
                   Name,
                   Product__c,
                   Current_Stock__c,
                   Reorder_Level__c,
                   Reorder_Quantity__c,
                   Unit_Price__c,
                   Supplier_Email__c
            FROM Inventory_Item__c
            WHERE Active__c = TRUE
        ];

        // Create a list to store low-stock records.
        List<Inventory_Item__c> filteredLowStockItems =
            new List<Inventory_Item__c>();

        // Apply the StockFlow low-stock business rule.
        for (Inventory_Item__c item : lowStockItems) {

            if (item.Current_Stock__c <= item.Reorder_Level__c) {
                filteredLowStockItems.add(item);
            }
        }

        // Return only low-stock inventory records.
        return filteredLowStockItems;
    }
}