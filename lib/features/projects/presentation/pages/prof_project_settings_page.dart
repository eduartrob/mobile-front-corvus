import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/projects/data/professor_api.dart';
import 'dart:async';

class ProfProjectSettingsPage extends StatefulWidget {
  final String projectId;
  const ProfProjectSettingsPage({super.key, required this.projectId});

  @override
  State<ProfProjectSettingsPage> createState() =>
      _ProfProjectSettingsPageState();
}

class _ProfProjectSettingsPageState extends State<ProfProjectSettingsPage> {
  bool _isLoading = true;
  List<dynamic> _collaborators = [];
  List<dynamic> _pendingInvitations = [];

  // Search state
  final ProfessorApi _professorApi = ProfessorApi();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCollaborators();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchProfessors(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final token = context.read<AuthProvider>().currentUser?.token;
      if (token != null) {
        final results = await _professorApi.searchProfessors(
          query: query,
          token: token,
        );
        if (mounted) {
          setState(() {
            _searchResults = results.where((r) {
              final inCollabs = _collaborators.any((c) => c['id'] == r['id']);
              final inPending = _pendingInvitations.any((c) => c['id'] == r['id']);
              return !inCollabs && !inPending;
            }).toList();
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchProfessors(query);
    });
  }

  Future<void> _loadCollaborators() async {
    setState(() {
      _isLoading = true;
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        '${ApiConfig.apiGatewayUrl}/projects/${widget.projectId}/collaborators',
      );
      final response = await apiClient.get(
        url,
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _collaborators = data['collaborators'] ?? [];
          _pendingInvitations = data['pending'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _inviteCollaborator(String email) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.apiGatewayUrl}/projects/${widget.projectId}/collaborators',
      );
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      headers['Content-Type'] = 'application/json';

      final response = await apiClient.post(
        url,
        headers: headers,
        body: jsonEncode({'email': email}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitación enviada exitosamente')),
        );
        _loadCollaborators();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al invitar: ${jsonDecode(response.body)['message'] ?? 'Desconocido'}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _removeCollaborator(String targetUserId) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.apiGatewayUrl}/projects/${widget.projectId}/collaborators',
      );
      final response = await apiClient.delete(
        url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'userId': targetUserId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Colaborador eliminado')),
        );
        _loadCollaborators();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al eliminar: ${jsonDecode(response.body)['message'] ?? 'Desconocido'}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserEmail = context.read<AuthProvider>().currentUser?.email;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Directorio de docentes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestiona a los profesores colaboradores de tu proyecto',
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                tabs: const [
                  Tab(text: 'Colaboradores'),
                  Tab(text: 'Invitar'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildCollaboratorsTab(context, currentUserEmail),
                    _buildInviteTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitar Profesores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Busca e invita a profesores a colaborar en tu proyecto integrador ingresando su correo electrónico.',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _inviteCollaborator(value);
                  _searchController.clear();
                  _searchProfessors('');
                }
              },
              decoration: InputDecoration(
                hintText: 'Busca por nombre, usuario o correo...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  size: 22,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.15,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No se encontraron docentes con "${_searchController.text}".',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            _inviteCollaborator(_searchController.text);
                            _searchController.clear();
                            _searchProfessors('');
                          },
                          icon: const Icon(Icons.mail),
                          label: const Text('Invitar por correo'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final prof = _searchResults[index];
                  final name =
                      prof['full_name'] ?? prof['username'] ?? 'Profesor';
                  final email = prof['email'] ?? '';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: prof['profile_image'] != null
                            ? NetworkImage(prof['profile_image'])
                            : null,
                        child: prof['profile_image'] == null
                            ? Text(
                                name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email),
                          if (prof['university'] != null)
                            Text(
                              prof['university']['name'],
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                              ),
                            ),
                          if (prof['career'] != null)
                            Text(
                              prof['career']['name'],
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _inviteCollaborator(email);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Invitar'),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorsTab(
    BuildContext context,
    String? currentUserEmail,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_collaborators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay docentes colaboradores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final creatorEmail = _collaborators.firstWhere(
      (c) => c['isCreator'] == true,
      orElse: () => <String, dynamic>{},
    )['email'];
    final iAmCreator = currentUserEmail != null && currentUserEmail == creatorEmail;

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        if (_collaborators.isNotEmpty) ...[
          const Text(
            'Colaboradores',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._collaborators.map((c) {
        final name = c['full_name'] ?? c['username'] ?? 'Profesor';
        final isMe = c['email'] != null && c['email'] == currentUserEmail;
        final isCreator = c['isCreator'] == true;

        Widget trailingIcon = const SizedBox.shrink();

        if (isCreator) {
          trailingIcon = const SizedBox.shrink();
        } else if (isMe) {
          trailingIcon = IconButton(
            icon: const Icon(Icons.logout),
            color: colorScheme.error,
            tooltip: 'Salir del proyecto',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Salir del proyecto'),
                  content: const Text('¿Estás seguro de que deseas salir de este proyecto? Ya no serás colaborador.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _removeCollaborator(c['id']);
                      },
                      style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );
            },
          );
        } else if (iAmCreator) {
          trailingIcon = IconButton(
            icon: const Icon(Icons.person_remove_outlined),
            color: colorScheme.error,
            tooltip: 'Eliminar colaborador',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Eliminar colaborador'),
                  content: Text('¿Estás seguro de eliminar a $name del proyecto?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _removeCollaborator(c['id']);
                      },
                      style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: c['profile_image'] != null
                  ? NetworkImage(c['profile_image'])
                  : null,
              child: c['profile_image'] == null
                  ? Text(
                      name.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                    )
                  : null,
            ),
            title: Text(
              name + (isMe ? ' (Tú)' : ''),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(isCreator ? 'Creador' : (c['email'] ?? '')),
            trailing: trailingIcon,
          ),
        );
      }),
      ],
      if (_pendingInvitations.isNotEmpty) ...[
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          'Invitaciones Pendientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._pendingInvitations.map((p) {
          final name = p['full_name'] ?? p['username'] ?? 'Profesor';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: p['profile_image'] != null
                    ? NetworkImage(p['profile_image'])
                    : null,
                child: p['profile_image'] == null
                    ? Text(
                        name.substring(0, 1).toUpperCase(),
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      )
                    : null,
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(p['email'] ?? ''),
              trailing: iAmCreator
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      color: colorScheme.error,
                      tooltip: 'Cancelar invitación',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cancelar invitación'),
                            content: Text('¿Estás seguro de cancelar la invitación a $name?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _removeCollaborator(p['id']);
                                },
                                style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                                child: const Text('Sí, cancelar'),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          );
        }),
      ],
      ],
    );
  }
}
