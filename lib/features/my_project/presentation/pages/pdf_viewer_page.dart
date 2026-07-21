import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerPage extends StatefulWidget {
  final String filePath;
  final String fileName;

  const PDFViewerPage({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  int _totalPages = 0;
  int _currentPage = 1;
  bool _isReady = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.fileName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isReady && _totalPages > 0)
              Text(
                'Página $_currentPage de $_totalPages',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: 0,
            fitPolicy: FitPolicy.BOTH,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = (page ?? 0) + 1;
                _totalPages = total ?? _totalPages;
              });
            },
          ),
          if (!_isReady && _errorMessage.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                    const SizedBox(height: 12),
                    Text(
                      'No se pudo renderizar el PDF.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
