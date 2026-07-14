import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/features/prof_history/presentation/provider/prof_history_provider.dart';
import 'package:intl/intl.dart';

class ProfHistoryPage extends StatefulWidget {
  const ProfHistoryPage({super.key});

  @override
  State<ProfHistoryPage> createState() => _ProfHistoryPageState();
}

class _ProfHistoryPageState extends State<ProfHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _selectedFilters = {'Todos'};
  final List<String> _filterOptions = ['Todos', 'Propuestas', 'Reglas y Temas', 'Accesos'];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfHistoryProvider>().fetchHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: Consumer<ProfHistoryProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial de Decisiones',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Registro de acciones, propuestas evaluadas y sus veredictos correspondientes.',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar en el historial...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((option) {
                      final isSelected = _selectedFilters.contains(option);
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          label: Text(option),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (option == 'Todos') {
                                if (selected) {
                                  _selectedFilters = {'Todos'};
                                }
                              } else {
                                if (selected) {
                                  _selectedFilters.remove('Todos');
                                  _selectedFilters.add(option);
                                } else {
                                  _selectedFilters.remove(option);
                                  if (_selectedFilters.isEmpty) {
                                    _selectedFilters.add('Todos');
                                  }
                                }
                              }
                            });
                          },
                          selectedColor: colorScheme.primaryContainer,
                          checkmarkColor: colorScheme.onPrimaryContainer,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.errorMessage != null)
                  Center(child: Text('Error: ${provider.errorMessage}', style: TextStyle(color: colorScheme.error)))
                else if (provider.history.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Aún no hay acciones registradas en el historial.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    ),
                  )
                else
                  Builder(
                    builder: (context) {
                      final filteredHistory = provider.history.where((log) {
                        bool matchesCategory = _selectedFilters.contains('Todos');
                        if (!matchesCategory) {
                          if (_selectedFilters.contains('Propuestas') && log.action == 'EVALUATE_PROPOSAL') matchesCategory = true;
                          if (_selectedFilters.contains('Reglas y Temas') && log.action == 'UPDATE_RULES') matchesCategory = true;
                          if (_selectedFilters.contains('Accesos') && (log.action == 'LOGIN' || log.action == 'SIGN_IN')) matchesCategory = true;
                        }

                        if (!matchesCategory) return false;

                        if (_searchQuery.isEmpty) return true;
                        
                        String title = 'Acción';
                        if (log.action == 'EVALUATE_PROPOSAL') {
                          title = 'Evaluación de Proyecto';
                        } else if (log.action == 'UPDATE_RULES') {
                          title = 'Actualización de Reglas';
                        } else if (log.action == 'LOGIN' || log.action == 'SIGN_IN') {
                          title = 'Inicio de Sesión';
                        }

                        return title.toLowerCase().contains(_searchQuery) ||
                               log.detail.toLowerCase().contains(_searchQuery) ||
                               log.action.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (filteredHistory.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text('No se encontraron resultados.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final log = filteredHistory[index];
                      final dateStr = DateFormat('dd MMM, yyyy - HH:mm').format(log.createdAt);

                      String title = 'Acción';
                      String status = 'Información';
                      bool isRejected = false;
                      bool isApproved = false;

                      if (log.action == 'EVALUATE_PROPOSAL') {
                        title = 'Evaluación de Proyecto';
                        if (log.detail.contains('REJECTED')) {
                          status = 'Rechazado';
                          isRejected = true;
                        } else if (log.detail.contains('APPROVED')) {
                          status = 'Aprobado';
                          isApproved = true;
                        } else {
                          status = 'Evaluado';
                        }
                      } else if (log.action == 'UPDATE_RULES') {
                        title = 'Actualización de Reglas';
                        status = 'Sistema';
                      } else if (log.action == 'LOGIN' || log.action == 'SIGN_IN') {
                        title = 'Inicio de Sesión';
                        status = 'Acceso';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildHistoryCard(
                          context,
                          title: title,
                          status: status,
                          date: dateStr,
                          reason: log.detail,
                          isRejected: isRejected,
                          isApproved: isApproved,
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required String title,
    required String status,
    required String date,
    required String reason,
    required bool isRejected,
    required bool isApproved,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final statusColor = isRejected 
        ? colorScheme.error 
        : (isApproved ? colorScheme.primary : colorScheme.secondary);
        
    final statusBgColor = isRejected 
        ? colorScheme.errorContainer.withValues(alpha: 0.5) 
        : (isApproved ? colorScheme.primaryContainer.withValues(alpha: 0.5) : colorScheme.secondaryContainer.withValues(alpha: 0.5));
    
    final icon = isRejected ? Icons.cancel_outlined : (isApproved ? Icons.check_circle_outline : Icons.info_outline);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(),
          ),
          Text(
            'Detalle',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
