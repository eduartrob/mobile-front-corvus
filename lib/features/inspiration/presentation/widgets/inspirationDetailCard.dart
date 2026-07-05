import 'package:flutter/material.dart';

class InspirationDetailCard extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final String resourcesCount;
  final bool isNew;

  const InspirationDetailCard({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    this.resourcesCount = '',
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_outlined, size: 16, color: Color(0xFF6A00FF)),
              const SizedBox(width: 6),
              Text(
                category.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF6A00FF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isNew ? 'Novedad Alta' : '$resourcesCount Recursos',
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.bookmark_border, size: 20, color: Colors.black87),
            ],
          ),
        ],
      ),
    );
  }
}
