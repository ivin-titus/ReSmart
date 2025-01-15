import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteWidget extends StatefulWidget {
  final TextStyle? textStyle;
  const QuoteWidget({Key? key, this.textStyle}) : super(key: key);

  @override
  QuoteWidgetState createState() => QuoteWidgetState();
}

class QuoteWidgetState extends State<QuoteWidget> {
  String? _quote;
  String? _author;
  String? _error;
  bool _loading = true;
  Timer? _refreshTimer;
  
  static const String _cacheKey = 'cached_quote';
  static const String _lastFetchKey = 'last_fetch_time';
  static const Duration _cacheDuration = Duration(hours: 2);
  static const Duration _timeout = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final cachedQuote = await _getCachedQuote();
      if (cachedQuote != null) {
        _updateQuoteFromCache(cachedQuote);
      }
      await _fetchNewQuote();
      _startRefreshTimer();
    } catch (e) {
      _handleError('Initialization failed: $e');
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_cacheDuration, (_) => _fetchNewQuote());
  }

  Future<Map<String, dynamic>?> _getCachedQuote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(
          prefs.getInt(_lastFetchKey) ?? 0);
      
      if (DateTime.now().difference(lastFetchTime) < _cacheDuration) {
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          return json.decode(cachedData) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('Cache error: $e');
    }
    return null;
  }

  void _updateQuoteFromCache(Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() {
      _quote = data['q'] as String?;
      _author = data['a'] as String?;
      _loading = false;
      _error = null;
    });
  }

  Future<void> _fetchNewQuote() async {
    if (!mounted) return;

    try {
      final client = HttpClient()
        ..badCertificateCallback = ((cert, host, port) => true)
        ..connectionTimeout = _timeout;
      
      final request = await client.getUrl(Uri.parse('https://zenquotes.io/api/random'));
      request.headers.set('user-agent', 'Mozilla/5.0');
      
      final response = await request.close().timeout(_timeout);
      final responseBody = await response.transform(utf8.decoder).join();

      if (!mounted) return;

      if (response.statusCode == 200 && responseBody.isNotEmpty) {
        dynamic jsonResponse;
        try {
          jsonResponse = json.decode(responseBody);
        } catch (e) {
          throw Exception('Invalid response format');
        }

        if (jsonResponse is! List || jsonResponse.isEmpty) {
          throw Exception('Unexpected data format');
        }

        final data = jsonResponse[0];
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid quote format');
        }

        if (!data.containsKey('q') || !data.containsKey('a')) {
          throw Exception('Missing quote data');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, json.encode(data));
        await prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
            
        _updateQuoteFromCache(data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      _handleError('Network error: Check your connection');
    } on HandshakeException catch (_) {
      _handleError('Security error: Cannot establish secure connection');
    } on TimeoutException catch (_) {
      _handleError('Request timed out');
    } catch (e) {
      _handleError('Error: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                style: widget.textStyle?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchNewQuote,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_quote != null) Text(
            '"$_quote"',
            style: widget.textStyle,
            textAlign: TextAlign.center,
          ),
          if (_author != null) ...[
            const SizedBox(height: 8),
            Text(
              '- $_author',
              style: widget.textStyle?.copyWith(
                fontStyle: FontStyle.italic,
                fontSize: (widget.textStyle?.fontSize ?? 14) * 0.8,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }
}