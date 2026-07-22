import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/projects/data/professor_api.dart';
import 'dart:async';
import 'package:mobile/features/teams/presentation/widgets/dashed_border_painter.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';

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

  static final Map<String, List<dynamic>> _collaboratorsCache = {};
  static final Map<String, List<dynamic>> _pendingCache = {};

  // Search state
  final ProfessorApi _professorApi = ProfessorApi();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCollaborators(forceRefresh: true);
    _searchProfessors('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchProfessors(String query) async {
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

  Future<void> _loadCollaborators({bool forceRefresh = false}) async {
    if (!forceRefresh && _collaboratorsCache.containsKey(widget.projectId)) {
      if (mounted) {
        setState(() {
          _collaborators = _collaboratorsCache[widget.projectId]!;
          _pendingInvitations = _pendingCache[widget.projectId]!;
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        '${ApiConfig.apiGatewayUrl}${ApiEndpoints.projectCollaborators(widget.projectId)}',
      );
      final response = await sl<AuthInterceptorClient>().get(
        url,
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _collaborators = data['collaborators'] ?? [];
            _pendingInvitations = data['pending'] ?? [];
            _collaboratorsCache[widget.projectId] = _collaborators;
            _pendingCache[widget.projectId] = _pendingInvitations;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _inviteCollaborator(String email) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.apiGatewayUrl}${ApiEndpoints.projectCollaborators(widget.projectId)}',
      );
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      headers['Content-Type'] = 'application/json';

      final response = await sl<AuthInterceptorClient>().post(
        url,
        headers: headers,
        body: jsonEncode({'email': email}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitación enviada exitosamente')),
        );
        _loadCollaborators(forceRefresh: true);
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
        '${ApiConfig.apiGatewayUrl}${ApiEndpoints.projectCollaborators(widget.projectId)}',
      );
      final response = await sl<AuthInterceptorClient>().delete(
        url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'userId': targetUserId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Colaborador eliminado')),
        );
        _loadCollaborators(forceRefresh: true);
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
                padding: const EdgeInsets.all(20.0).copyWith(bottom: 0),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: colorScheme.primary.withValues(alpha: 0.6),
                    borderRadius: 12.0,
                    dashLength: 5.0,
                    gap: 3.0,
                    strokeWidth: 1.2,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Directorio de docentes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Invita a los profesores a colaborar en tu proyecto',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
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
          SizedBox(
            height: 52,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _inviteCollaborator(value);
                  _searchController.clear();
                  _searchProfessors('');
                }
              },
              decoration: InputDecoration(
                hintText: 'Buscar docente...',
                hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withValues(alpha: 0.7)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                filled: true,
                fillColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else if (_searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _searchController.text.isEmpty
                            ? 'No hay otros docentes disponibles para invitar en este momento.'
                            : 'No se encontraron docentes con "${_searchController.text}".',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        if (_searchController.text.isNotEmpty) ...[
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
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final prof = _searchResults[index];
                  final name =
                      prof['full_name'] ?? prof['username'] ?? 'Profesor';
                  final email = prof['email'] ?? '';
                  final carrera = prof['career']?['name'] ?? '';
                  String displayCarrera = carrera;
                  if (displayCarrera.length > 25) {
                    displayCarrera = '${displayCarrera.substring(0, 25)}...';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: colorScheme.primaryContainer,
                            backgroundImage: prof['profile_picture'] != null
                                ? NetworkImage(prof['profile_picture'])
                                : null,
                            child: prof['profile_picture'] == null
                                ? Text(
                                    name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                if (displayCarrera.isNotEmpty)
                                  Text(
                                    displayCarrera,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                else if (email.isNotEmpty)
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                else
                                  Text(
                                    'Docente',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () {
                                      _inviteCollaborator(email);
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text(
                                      'Invitar',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

    if (_isLoading && _collaborators.isEmpty && _pendingInvitations.isEmpty) {
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

    final filteredPending = _pendingInvitations.where((p) {
      final pEmail = p['email'];
      if (pEmail == currentUserEmail) return false;
      if (_collaborators.any((c) => c['email'] == pEmail)) return false;
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => _loadCollaborators(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        physics: const AlwaysScrollableScrollPhysics(),
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
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  icon: Icon(
                    Icons.warning_amber_rounded,
                    color: colorScheme.error,
                    size: 40,
                  ),
                  title: Text(
                    '¿Salir del proyecto?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  content: Text(
                    '¿Estás seguro de que deseas salir de este proyecto? Ya no serás colaborador.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, height: 1.5),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                  actions: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _removeCollaborator(c['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
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
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  icon: Icon(
                    Icons.warning_amber_rounded,
                    color: colorScheme.error,
                    size: 40,
                  ),
                  title: Text(
                    '¿Eliminar colaborador?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  content: Text(
                    '¿Estás seguro de eliminar a $name del proyecto?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, height: 1.5),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                  actions: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _removeCollaborator(c['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
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
              backgroundImage: c['profile_picture'] != null
                  ? NetworkImage(c['profile_picture'])
                  : null,
              child: c['profile_picture'] == null
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
      if (filteredPending.isNotEmpty) ...[
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          'Invitaciones Pendientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...filteredPending.map((p) {
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
                backgroundImage: p['profile_picture'] != null
                    ? NetworkImage(p['profile_picture'])
                    : null,
                child: p['profile_picture'] == null
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
      ),
    );
  }
}
