
public class LowStockEventHandler {

    public static void handle(
        List<Low_Stock_Event__e> events
    ) {
        List<CustomNotificationType> types = [
            SELECT Id
            FROM CustomNotificationType
            WHERE DeveloperName = 'StockFlow_Low_Stock_Alert'
            LIMIT 1
        ];

        if (types.isEmpty()) {
            System.debug(
                LoggingLevel.ERROR,
                'StockFlow notification type was not found.'
            );
            return;
        }

        // Demo recipient: your Salesforce User ID.
        Set<String> recipientIds = new Set<String>{
            '005g5000005L0zq'
        };

        for (Low_Stock_Event__e stockEvent : events) {
            if (String.isBlank(stockEvent.Inventory_Item_ID__c)) {
                System.debug(
                    LoggingLevel.ERROR,
                    'Skipping event: Inventory Item ID is missing.'
                );
                continue;
            }

            try {
                Messaging.CustomNotification notification =
                    new Messaging.CustomNotification();

                notification.setNotificationTypeId(types[0].Id);
                notification.setTitle('StockFlow: Low Stock Alert');
                notification.setBody(
                    'Product: ' + stockEvent.Product_Name__c +
                    ' | Current Stock: ' + stockEvent.Current_Stock__c +
                    ' | Reorder Level: ' + stockEvent.Reorder_Level__c
                );
                notification.setTargetId(
                    stockEvent.Inventory_Item_ID__c
                );

                notification.send(recipientIds);

                System.debug(
                    LoggingLevel.INFO,
                    'StockFlow notification send called for ' +
                    stockEvent.Product_Name__c
                );
            } catch (Exception e) {
                System.debug(
                    LoggingLevel.ERROR,
                    'StockFlow notification failed: ' +
                    e.getMessage()
                );
            }
        }
    }
}
