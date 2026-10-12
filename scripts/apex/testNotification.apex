
List<CustomNotificationType> types = [
    SELECT Id, DeveloperName
    FROM CustomNotificationType
    WHERE DeveloperName = 'StockFlow_Low_Stock_Alert'
    LIMIT 1
];

System.debug('Notification type found: ' + !types.isEmpty());

if (!types.isEmpty()) {
    Messaging.CustomNotification notification =
        new Messaging.CustomNotification();

    notification.setNotificationTypeId(types[0].Id);
    notification.setTitle('StockFlow Test Notification');
    notification.setBody(
        'Test alert: Mechanical Keyboard inventory check.'
    );

    notification.setTargetId('a08g500000DW7q5AAD');

    notification.send(
        new Set<String>{ UserInfo.getUserId() }
    );

    System.debug('Direct notification send call completed.');
}
