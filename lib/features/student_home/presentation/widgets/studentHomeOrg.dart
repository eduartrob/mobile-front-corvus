import 'package:flutter/material.dart';
import 'package:mobile/features/student_home/presentation/widgets/inspirationCard.dart';

class StudentHomeOrg extends StatelessWidget {
  const StudentHomeOrg({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121827),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.school, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Corvus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFF1F2937),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de la app
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF374151)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.insights, color: Color(0xFFB266FF), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Bienvenido a Corvus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Corvus analiza y agrupa repositorios académicos para revelar áreas de investigación inexploradas. Descubre oportunidades únicas para tu próximo gran proyecto.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Proyectos Inexplorados',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Basado en el análisis de +10,000 tesis recientes.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              InspirationCard(
                category: 'IA & Sostenibilidad',
                title: 'IA en Agricultura de Precisión',
                description: 'Optimización de recursos hídricos y predicción de cosechas mediante modelos de RAG alimentados por datos climáticos.',
                isHighPotential: true,
                onExplore: () {
                  Navigator.pushNamed(context, '/inspiration');
                },
              ),
              InspirationCard(
                category: 'Logística & Supply Chain',
                categoryColor: const Color(0xFF00B8D9),
                categoryBgColor: const Color(0xFF00B8D9).withOpacity(0.15),
                title: 'Logística Circular',
                description: 'Rediseño de cadenas de suministro para eliminar residuos, utilizando blockchain para trazabilidad.',
                isHighPotential: true,
                onExplore: () {
                  Navigator.pushNamed(context, '/inspiration');
                },
              ),
              InspirationCard(
                category: 'BIOTECH',
                title: 'Biomateriales de Construcción',
                description: 'Desarrollo de estructuras vivas y auto-reparables utilizando micelio fúngico.',
                isHighPotential: true,
                onExplore: () {
                  Navigator.pushNamed(context, '/inspiration');
                },
              ),
              const SizedBox(height: 16),
              
              // Card de "Generar Ideas" adaptada
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF374151)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, size: 16, color: Color(0xFFB266FF)),
                        SizedBox(width: 8),
                        Text(
                          'Generar Ideas',
                          style: TextStyle(
                            color: Color(0xFFB266FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '¿Buscas algo diferente?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escribe tus temas de interés y nuestra Inteligencia Artificial creará propuestas de investigación únicas y a tu medida.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        border: Border.all(color: const Color(0xFF374151)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              style: TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Ej: Energía + Sociología...',
                                hintStyle: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB266FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.send, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121827),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFB266FF),
        unselectedItemColor: Colors.white54,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Inspiration',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch_outlined),
            label: 'My Project',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
