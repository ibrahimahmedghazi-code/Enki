import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class MarkdownReaderPage extends StatefulWidget {
  final String url;
  final String title;

  const MarkdownReaderPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<MarkdownReaderPage> createState() => _MarkdownReaderPageState();
}

class _MarkdownReaderPageState extends State<MarkdownReaderPage> {
  String? _content;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _content = response.body;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load');
      }
    } catch (_) {
      if (mounted) setState(() => _isError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      const Text('Failed to load article.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _isError = false;
                          });
                          _loadMarkdown();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Markdown(
                  data: _content!,
                  padding: const EdgeInsets.all(16.0),
                  styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context))
                          .copyWith(
                    p: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.6),
                    code: const TextStyle(
                      fontFamily: 'monospace',
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ),
    );
  }
}
