global class ScheduledSubmitPendingMonitoringPeriod implements Schedulable {
   public Integer numberOfRecords;
   global void execute(SchedulableContext sc) {
       SubmitPendingMonitoringPeriodBatch mp = new SubmitPendingMonitoringPeriodBatch(this.numberOfRecords);
       ID batchprocessid = Database.executeBatch(mp);
   }
}