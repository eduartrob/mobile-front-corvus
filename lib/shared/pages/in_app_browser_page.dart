import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppBrowserPage extends StatefulWidget {
  final String initialUrl;
  final String? title;
  // URL fragment that signals payment is complete (e.g. "/pagos/resultado")
  final String? completionUrlFragment;

  const InAppBrowserPage({
    super.key,
    required this.initialUrl,
    this.title,
    this.completionUrlFragment,
  });

  @override
  State<InAppBrowserPage> createState() => _InAppBrowserPageState();
}

class _InAppBrowserPageState extends State<InAppBrowserPage> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  String _currentUrl = '';
  String _pageTitle = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _pageTitle = widget.title ?? _extractDomain(widget.initialUrl);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _currentUrl = url;
                _pageTitle = widget.title ?? _extractDomain(url);
                _loadingProgress = 10;
              });
            }
            // Auto-close when MercadoPago redirects back to our resultado endpoint
            _checkForCompletion(url);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _currentUrl = url;
                _loadingProgress = 100;
              });
            }
            _checkForCompletion(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('InAppBrowser error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _checkForCompletion(String url) {
    final fragment = widget.completionUrlFragment;
    if (fragment != null && url.contains(fragment)) {
      // Extract payment state from URL query params
      final uri = Uri.tryParse(url);
      final estado = uri?.queryParameters['estado'];
      if (mounted) {
        Navigator.of(context).pop(estado ?? 'aprobado');
      }
    }
  }

  String _extractDomain(String urlString) {
    try {
      final uri = Uri.parse(urlString);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return urlString;
    }
  }

  Future<void> _openExternalBrowser() async {
    final uri = Uri.parse(_currentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.2),
          leading: IconButton(
            icon: const Icon(Icons.close, size: 24),
            tooltip: 'Cerrar y volver a la app',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _pageTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentUrl.startsWith('https') ? Icons.lock : Icons.lock_open,
                    size: 11,
                    color: _currentUrl.startsWith('https') ? Colors.green : Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _extractDomain(_currentUrl),
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                switch (value) {
                  case 'reload':
                    _controller.reload();
                    break;
                  case 'copy':
                    await Clipboard.setData(ClipboardData(text: _currentUrl));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enlace copiado al portapapeles'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    break;
                  case 'open_external':
                    _openExternalBrowser();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'reload',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 12),
                      Text('Actualizar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 20),
                      SizedBox(width: 12),
                      Text('Copiar enlace'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'open_external',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_browser, size: 20),
                      SizedBox(width: 12),
                      Text('Abrir en el navegador'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_loadingProgress > 0 && _loadingProgress < 100)
                LinearProgressIndicator(
                  value: _loadingProgress / 100.0,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                  minHeight: 3,
                ),
              Expanded(
                child: WebViewWidget(controller: _controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
