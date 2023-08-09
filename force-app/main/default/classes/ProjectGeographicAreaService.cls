public class ProjectGeographicAreaService  {

	public static void deletePIGAs(List<ampi__Project_Geographic_Area__c> projectGeographicAreas, Map<Id, ampi__Project_Geographic_Area__c> oldProjectGeographicAreas){
		Set<Id> gAreasIds = new Set<Id>();
		Set<Id> pIds = new Set<Id>();
		for(ampi__Project_Geographic_Area__c pga : projectGeographicAreas){
			if(pga.Delete_PIGAs__c && !oldProjectGeographicAreas.get(pga.Id).Delete_PIGAs__c){
				gAreasIds.add(pga.ampi__Geographic_Area__c);
				pIds.add(pga.ampi__Project__c);
			}
		}
		System.debug('#### ' + gAreasIds.size());
		if(gAreasIds.size()>0){// && pIds.size()>0){
			List<ampi__Project_Indicator_Geographic_Area__c> PIGAs = [SELECT Id, ampi__Geographic_Area__c, ampi__Geographic_Area__r.Thematic_Area__c, ampi__Project_Indicator__c, ampi__Project_Indicator__r.ampi__Project__c, ampi__Project_Indicator__r.ampi__Catalog_Indicator__c FROM ampi__Project_Indicator_Geographic_Area__c WHERE ampi__Geographic_Area__c IN: gAreasIds];// AND ampi__Project_Indicator__r.ampi__Project__c IN: pIds];
			if(PIGAs.size()>0){
				System.debug('#### ' + PIGAs.size());
					//delete PIGAs;
				List<ampi__Geographical_Area__c> gAreas = [SELECT Id, Thematic_Area__c FROM ampi__Geographical_Area__c WHERE Id IN: gAreasIds];
				Set<Id> thematicAreaIds = new Set<Id>();
				if(gAreas.size()>0){
					System.debug('#### ' + gAreas.size());
					for(ampi__Geographical_Area__c ga : gAreas){
						thematicAreaIds.add(ga.Thematic_Area__c);
					}
					if(thematicAreaIds.size()>0){
						System.debug('#### ' + thematicAreaIds.size());
						List<ampi__Indicator_Thematic_Area__c> ITAs = [SELECT Id, ampi__Indicator__c, ampi__Required__c, ampi__Thematic_Area__c FROM ampi__Indicator_Thematic_Area__c WHERE ampi__Thematic_Area__c IN: thematicAreaIds];
						Map<Id, Set<Id>> ITAThematicArea = new Map<Id, Set<Id>>();
						for(Id id : thematicAreaIds){
							Set<Id> ITAIndicators = new Set<Id>();	
							for(ampi__Indicator_Thematic_Area__c ITA : ITAs){
								if(id == ITA.ampi__Thematic_Area__c){
									ITAIndicators.add(ITA.ampi__Indicator__c);
								}
							}
							ITAThematicArea.put(id, ITAIndicators);
						}					
						
						System.debug('#### ' + ITAThematicArea.size());
						List<ampi__Project_Indicator_Geographic_Area__c> PIGAs2Delete = new List<ampi__Project_Indicator_Geographic_Area__c>();
						for(ampi__Project_Indicator_Geographic_Area__c PIGA : PIGAs){
							Boolean found = false;
							//for(ampi__Indicator_Thematic_Area__c ITA : ITAs){								
								//if(PIGA.ampi__Project_Indicator__r.ampi__Catalog_Indicator__c == ITA.ampi__Indicator__c){
								//System.debug('#### ' + PIGA.ampi__Geographic_Area__c + ' ' + PIGA.ampi__Project_Indicator__r.ampi__Catalog_Indicator__c + ' ' + PIGA.ampi__Geographic_Area__r.Thematic_Area__c);
								if(ITAThematicArea.containsKey(PIGA.ampi__Geographic_Area__r.Thematic_Area__c)){
									if(ITAThematicArea.get(PIGA.ampi__Geographic_Area__r.Thematic_Area__c).contains(PIGA.ampi__Project_Indicator__r.ampi__Catalog_Indicator__c)){
										found = true;	
									}
									else{
									
									}
								}
								//if(ITAIndicators.contains(PIGA.ampi__Project_Indicator__r.ampi__Catalog_Indicator__c)){
									//found = true;
								//}
								else{
									//System.debug('#### ' + PIGA.ampi__Geographic_Area__c + ' ' + PIGA.ampi__Project_Indicator__r.ampi__Catalog_Indicator__c + ' ' + ITAIndicators.contains(PIGA.ampi__Project_Indicator__r.ampi__Catalog_Indicator__c));
								}
							//}
							if(!found){
								PIGAs2Delete.add(PIGA);		
							}
						}
						if(PIGAs2Delete.size()>0){
							delete PIGAs2Delete;
						}
					}
					else{
						delete PIGAs;
					}
				}
				/*
						Set<Id> indicatorIds = new Set<Id>();
						for(ampi__Indicator_Thematic_Area__c ita : ITAs){
							if(ita.ampi__Indicator__c != NULL){
								indicatorIds.add(ita.ampi__Indicator__c);
							}
						}
						List<ampi__Project_Indicator__c> porjectIndicators = [SELECT Id, ampi__Catalog_Indicator__c FROM ampi__Project_Indicator__c WHERE ampi__Catalog_Indicator__c IN: indicatorIds];
						List<ampi__Project_Indicator_Geographic_Area__c> newPIGAs = new List<ampi__Project_Indicator_Geographic_Area__c>();
						if(porjectIndicators.size()>0){
							for(ampi__Project_Geographic_Area__c pga : projectGeographicAreas){
								for(ampi__Geographical_Area__c ga : gAreas){
									for(ampi__Indicator_Thematic_Area__c ita : ITAs){
										for(ampi__Project_Indicator__c pi : porjectIndicators){
											if(pi.ampi__Catalog_Indicator__c == ita.ampi__Indicator__c){
												if(ita.ampi__Thematic_Area__c == ga.Thematic_Area__c){
													if(ga.Thematic_Area__c == pga.ampi__Geographic_Area__c){
														ampi__Project_Indicator_Geographic_Area__c newPIGA = new ampi__Project_Indicator_Geographic_Area__c();
														newPIGA.ampi__Geographic_Area__c = ga.Id;
														newPIGA.ampi__Project_Indicator__c = pi.Id;
														newPIGAs.add(newPIGA);
													}
												}
											}
										}
									}
								}
							}
							if(newPIGAs.size()>0){
								insert newPIGAs;
							}
						}
						else{
					
						}
					}
				}*/
			}

		}
	}
}