global class ScheduledProjectActivityNotification implements Schedulable {
   global void execute(SchedulableContext sc) {
       ProjectActivityNotificationBatch mp =new ProjectActivityNotificationBatch();
       ID batchprocessid = Database.executeBatch(mp);
   }
}