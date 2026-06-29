import 'package:mobile/features/inspiration/data/models/project_model.dart';

class InspirationLocalDataSource {
  Future<List<ProjectModel>> getUnexploredProjects() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      ProjectModel(
        id: '1',
        category: 'IA & Sostenibilidad',
        categoryIcon: 'auto_awesome',
        title: 'IA en Agricultura de Precisión',
        description: 'Optimización de recursos hídricos y predicción de cosechas mediante modelos de RAG alimentados por datos climáticos.',
        status: 'Alto Potencial',
        userAvatars: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD0wLXmNJdheSLYRV0cyw58WRptbP7Tcpj2DYe6d6sJQiytU6tgetCYTsh4-Ov0geC0LLapbMasxnzTMELIMNsnayUh4N9TGK5De10d2W71dWF73JXTBHyjaWFa07BYB77_vkOYSDrr-SvtGzREIK2cHWLZNpEc3oBxuPIFF5-lfeKEPSrbyfJCy2PIjLahEVgXVyF24D6pU3BzhZ6AQHJgFgzuPc1CohlsoHoMho2D-B73NSq78KXkdfio1LlxfaQz9d9DTHm2BG0',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBB6Z3ZJ_PRwCpxoOIqizU9cZGKV_jm4-rJc76sM7LANbkR5QBbSEbSx0LBwM-zN7448oEPNCKCzpr7fPjxxoXtEY9QuNNIZpHrrZLaV1cjT_riWDRkMovSrf8KMP1O7MQrrv0XMOmpazSj2-qj2plISrKVDWIZYg2c7FHh5uxFoTwR4CGnbQ13GCmvZVW4iGGWJK2AuTa8XN1GQEiMv5Z2J0Oa4gCU8YsbMXr1RSEIHS6FKvkOdNUXSLZczcCSFqrBlW_FYq4de5E',
        ],
      ),
      ProjectModel(
        id: '2',
        category: 'Logística & Supply Chain',
        categoryIcon: 'local_shipping',
        title: 'Logística Circular',
        description: 'Rediseño de cadenas de suministro para eliminar residuos, utilizando blockchain para trazabilidad.',
        status: 'Alto Potencial',
        userAvatars: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBXgTC4DnAYNbbZqJiR2_eXQVjVBBU9UAfGrdGXOt0kuaQU0pB6NC2VA430rwd4RXjZ_hC5Hfq92mwXe2lxvfwHF5PEWKa6lPQkYXOsjQVHelRTzu19Dvk4rGSpIO4madR4j--BNrWFv3pXGHVjKPbA1Gwxzy-16impgeDJrVMZ3ur9i2TBCFnRgU_T3BSzAWjaze7feR8wzo2PmgLdiKJ29z5fHVKDnAVOwtf1F07fAyiIjCOTBsgAtrbB2A7g3j41-3bOoHBHjQM',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvyl3ViJFZckZTn5df12QGUERqmAs2Mxthi9pu2gVAQuKICrdGgsXAZXFyIY4Xhz6IE0MgS1Df7-22dDa692S6FuyaNS15mOctmgWbMIn-vfgcy-3DEVsrM64S-8NwZfS8sQH4aOEhzFwbWxyKkNynPjZ4bdau74uzKU0ukoNE553ZQqdy5WBJOdO8YxatJw_iiT8wt3-zDmkL6QtbCr5K7_BO3mp7ZmWHoUdQmxwidq-w-BgjZGCsdid2QZGBlLNudSmQHZN1gIM',
        ],
      ),
      ProjectModel(
        id: '3',
        category: 'BIOTECH',
        categoryIcon: 'biotech',
        title: 'Biomateriales de Construcción',
        description: 'Desarrollo de estructuras vivas y auto-reparables utilizando micelio fúngico.',
        status: 'Alto Potencial',
        userAvatars: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCrL7ehJPOSPFx9kjB2ZvERwzM3OMH8QIwIepB1EPeDn4nneI-XG4DzjJS4U4PbpYTnR-4eZt0JNAZodSqDIh8ddQ5DaGmmlhQ0oR-bgeevIdAUyjzJPhUB5ensFdryjBeIM5P_3kvP1jO2wq1hVCHPr6ZEuQzqa2_Vs_MnF2jOpDPQtSSBSbCbNl7YS_wCAsLGUTPVjepr0lY4VoAGE3GAa5EdTE-XhuxekDzHw7L5qtKjFrupUbS_x0d3pjJUISMHWC_oG_ayC_8',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDvEVDOj6NgggoQ0B66hJrlRmjE24NOQp5aS54AQrQsUadkTYaLcmCvPgT9Hqd9t7lEqn4CHnOuS5ObrYKhRIH3MmZRWzzpP7A4zu1YnAptTrk1GQXp5Z3Eabb-FgQ-kAf22-XqY9azcuyRDPH_qW2D3B2lsg6RcLx5RqJF1rEEgmAMg9PXeTDg8os21x7ZM75jZcEq3QZO2DaVqh_UhdUEfxprRfQStrN0nCpvvagLzyZufD09Z-A57RdBUtYab8bIqahrNkDDDMo',
        ],
      ),
    ];
  }
}
