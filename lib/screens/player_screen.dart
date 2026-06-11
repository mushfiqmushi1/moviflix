import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlayerScreen extends StatefulWidget {
  final String serverUrl;
  final String serverName;

  const PlayerScreen({
    super.key,
    required this.serverUrl,
    required this.serverName,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isLandscape = false;


  static const String _adCloakScript = '''
    (function() {

     
      window.open = function(url, target, features) {
        console.log("Ad popup intercepted: " + url);
       
        return {
          closed: false,
          close: function() {},
          focus: function() {},
          location: { href: url }
        };
      };

      var style = document.createElement('style');
      style.innerHTML = `
        
        iframe[src*="ads"], iframe[id*="ad"], iframe[class*="ad"],
        iframe[src*="doubleclick"], iframe[src*="googlesyndication"],
        iframe[src*="adservice"], iframe[src*="popup"],
        div[id*="overlay"], div[class*="overlay"],
        div[id*="popup"], div[class*="popup"],
        div[class*="advertisement"], div[id*="advertisement"] {
          opacity: 0 !important;
          pointer-events: none !important;
          width: 1px !important;
          height: 1px !important;
          position: fixed !important;
          top: -9999px !important;
          left: -9999px !important;
        }

       
        div[style*="z-index: 9"], div[style*="z-index:9"] {
          opacity: 0 !important;
          pointer-events: none !important;
        }
      `;
      document.head.appendChild(style);

    
      var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          mutation.addedNodes.forEach(function(node) {
            if (node.nodeType !== 1) return; // শুধু element nodes

            var el = node;
            var id = (el.id || '').toLowerCase();
            var cls = (el.className || '').toLowerCase();
            var tag = (el.tagName || '').toLowerCase();

           
            var isAd = 
              id.includes('ad') || id.includes('popup') || id.includes('overlay') ||
              cls.includes('ad') || cls.includes('popup') || cls.includes('overlay') ||
              cls.includes('banner') || cls.includes('interstitial');

            if (isAd) {
             
              el.style.opacity = '0';
              el.style.pointerEvents = 'none';
              el.style.position = 'fixed';
              el.style.top = '-9999px';
              el.style.left = '-9999px';
              el.style.width = '1px';
              el.style.height = '1px';
              console.log("Ad cloaked: " + (id || cls));
            }

           ধ
            if (tag === 'a') {
              el.setAttribute('target', '_self');
              el.addEventListener('click', function(e) {
                var href = el.getAttribute('href') || '';
            
                if (href && !href.startsWith('#') && !href.startsWith('javascript')) {
                  var isVideoRelated = 
                    href.includes('vidsrc') || href.includes('embed') ||
                    href.includes('stream') || href.includes('play');
                  if (!isVideoRelated) {
                    e.preventDefault();
                    e.stopPropagation();
                    console.log("External link blocked: " + href);
                  }
                }
              });
            }
          });
        });
      });

      
      if (document.body) {
        observer.observe(document.body, { childList: true, subtree: true });
      } else {
        document.addEventListener('DOMContentLoaded', function() {
          observer.observe(document.body, { childList: true, subtree: true });
        });
      }

    
      document.querySelectorAll('a').forEach(function(a) {
        a.setAttribute('target', '_self');
      });

      console.log("Ad cloak active ✅");
    })();
  ''';

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
     
            _controller.runJavaScript(_adCloakScript);
          },
          onPageFinished: (String url) {
           
            _controller.runJavaScript(_adCloakScript);
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();

          
            if (!url.startsWith('http')) {
              return NavigationDecision.prevent;
            }

           
            if (request.isMainFrame) {
              final allowedHosts = [
                'vidsrc.mov',
                'vidsrc.ru',
                'vidsrc.xyz',
                'vidsrc.cc',
                'vidsrc.in',
                'multiembed.mov',
                'embed.su',
                '2embed.cc',
                'tmdb.org',
                'themoviedb.org',
              ];

              final isAllowed =
                  allowedHosts.any((host) => url.contains(host));

              if (!isAllowed) {
                debugPrint('🚫 Main frame redirect blocked: $url');
                return NavigationDecision.prevent;
              }
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..setUserAgent("Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36")
      ..loadRequest(Uri.parse(widget.serverUrl));
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
      if (_isLandscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.cyan),
              ),

           
            Positioned(
              top: 20,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _handleBack,
                ),
              ),
            ),

            
            Positioned(
              top: 20,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: Icon(
                    _isLandscape
                        ? Icons.screen_lock_portrait
                        : Icons.screen_rotation,
                    color: Colors.white,
                  ),
                  onPressed: _toggleOrientation,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
