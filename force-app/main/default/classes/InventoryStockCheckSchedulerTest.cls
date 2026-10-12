
@IsTest
private class InventoryStockCheckSchedulerTest {

    @IsTest
    static void testSchedulerExecutesBatch() {

        // Define a test schedule: every day at 2 AM.
        String cronExpression = '0 0 2 * * ?';

        Test.startTest();

        // Schedule the StockFlow inventory scheduler.
        String jobId = System.schedule(
            'StockFlow Scheduler Test',
            cronExpression,
            new InventoryStockCheckScheduler()
        );

        // Execute scheduled asynchronous work during the test.
        Test.stopTest();

        // Verify that the scheduled job was created.
        CronTrigger scheduledJob = [
            SELECT Id, CronExpression, TimesTriggered
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        System.assertEquals(
            cronExpression,
            scheduledJob.CronExpression,
            'The scheduler should use the expected CRON expression.'
        );

        System.assertNotEquals(
            null,
            scheduledJob.Id,
            'A scheduled job should exist.'
        );
    }
}
