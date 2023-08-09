global class ScheduledExternalProjectTeamBatch implements Schedulable {
   global void execute(SchedulableContext sc) {
       ExternalProjectTeamBatch mp = new ExternalProjectTeamBatch();
       ID batchprocessid = Database.executeBatch(mp);
   }
}