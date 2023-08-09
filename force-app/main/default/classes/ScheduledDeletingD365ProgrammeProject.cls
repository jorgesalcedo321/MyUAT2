global class ScheduledDeletingD365ProgrammeProject implements Schedulable {
   global void execute(SchedulableContext sc) {
       DeletingD365ProgrammeProjectBatch mp = new DeletingD365ProgrammeProjectBatch();
       ID batchprocessid = Database.executeBatch(mp);
   }
}