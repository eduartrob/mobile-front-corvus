import 'package:flutter/material.dart';

class InspirationCard extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final bool isHighPotential;
  final VoidCallback onExplore;
  final Color categoryColor;
  final Color categoryBgColor;

  const InspirationCard({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.isHighPotential,
    required this.onExplore,
    this.categoryColor = const Color(0xFFB266FF),
    this.categoryBgColor = const Color(0x26B266FF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hub_outlined, size: 14, color: categoryColor),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isHighPotential) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Alto Potencial',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Simulación de avatares
                if (isHighPotential)
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF4B5563),
                        child: Icon(Icons.person, size: 14, color: Colors.white),
                      ),
                      Transform.translate(
                        offset: const Offset(-8, 0),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Color(0xFF6B7280),
                          child: Icon(Icons.person, size: 14, color: Colors.white),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-16, 0),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF374151),
                          child: const Text('+3', style: TextStyle(fontSize: 8, color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(),
                GestureDetector(
                  onTap: onExplore,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: isHighPotential 
                        ? BoxDecoration(
                            color: const Color(0xFF6A00FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF6A00FF)),
                          )
                        : BoxDecoration(
                            color: const Color(0xFF374151),
                            borderRadius: BorderRadius.circular(8),
                          ),
                    child: Row(
                      children: [
                        Text(
                          'Explorar',
                          style: TextStyle(
                            color: isHighPotential ? const Color(0xFFD8B4FF) : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isHighPotential) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFD8B4FF)),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
