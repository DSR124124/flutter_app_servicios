import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../config/theme/app_colors.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadHtmlString(
        _buildHtmlContent(),
        baseUrl: 'https://edugen.brianuceda.xyz',
      );
  }

  String _buildHtmlContent() {
    return '''
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>GabIA - Asistente de Nettalco</title>
    <link href="https://cdn.jsdelivr.net/npm/@n8n/chat/dist/style.css" rel="stylesheet" />
    <style>
        :root {
            /* Colores primarios Nettalco */
            --chat--color--primary: #1C224D; /* Navy Dark */
            --chat--color--primary-shade-50: #161B3F;
            --chat--color--primary--shade-100: #111530;
            
            /* Colores secundarios Nettalco */
            --chat--color--secondary: #4A7AFF; /* Blue Light */
            --chat--color-secondary-shade-50: #2954FF; /* Blue Darker */
            
            /* Colores neutros */
            --chat--color-white: #FFFFFF;
            --chat--color-light: #F7FAFC; /* Gray Light */
            --chat--color-light-shade-50: #EDF2F7; /* Gray Lighter */
            --chat--color-light-shade-100: #E6E6E6; /* Light Gray */
            --chat--color-medium: #7A7A7A; /* Gray Medium */
            --chat--color-dark: #1C224D; /* Navy Dark */
            --chat--color-disabled: #7A7A7A;
            --chat--color-typing: #4A5568; /* Gray Dark */
            
            /* Espaciado y diseño */
            --chat--spacing: 1rem;
            --chat--border-radius: 0.5rem;
            --chat--transition-duration: 0.2s;
            
            /* Dimensiones del chat */
            --chat--window--width: 100%;
            --chat--window--height: 100vh;
            --chat--header-height: auto;
            --chat--header--padding: var(--chat--spacing);
            --chat--header--background: var(--chat--color--primary);
            --chat--header--color: var(--chat--color-white);
            --chat--header--border-top: none;
            --chat--header--border-bottom: none;
            
            /* Tipografía */
            --chat--heading--font-size: 1.5rem;
            --chat--subtitle--font-size: 0.875rem;
            --chat--subtitle--line-height: 1.5;
            --chat--message--font-size: 0.9375rem;
            --chat--message--padding: var(--chat--spacing);
            --chat--message--border-radius: var(--chat--border-radius);
            --chat--message-line-height: 1.6;
            
            /* Mensajes del bot */
            --chat--message--bot--background: var(--chat--color-white);
            --chat--message--bot--color: var(--chat--color-dark);
            --chat--message--bot--border: 1px solid var(--chat--color-light-shade-100);
            
            /* Mensajes del usuario */
            --chat--message--user--background: var(--chat--color--secondary);
            --chat--message--user--color: var(--chat--color-white);
            --chat--message--user--border: none;
            
            /* Input */
            --chat--textarea--height: 56px;
            --chat--input--padding-bottom: env(safe-area-inset-bottom, 0px);
            
            /* Botón toggle */
            --chat--toggle--background: var(--chat--color--primary);
            --chat--toggle--hover--background: var(--chat--color--primary-shade-50);
            --chat--toggle--active--background: var(--chat--color--primary--shade-100);
            --chat--toggle--color: var(--chat--color-white);
            --chat--toggle--size: 64px;
        }
        
        body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100vh;
            height: 100dvh; /* Dynamic viewport height para móviles */
            overflow: hidden;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background-color: var(--chat--color-light);
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
        }
        #n8n-chat {
            width: 100%;
            height: 100vh;
            height: 100dvh; /* Dynamic viewport height para móviles */
            position: relative;
        }
        
        /* Ajustes para el input en móviles */
        @media (max-width: 768px) {
            #n8n-chat {
                padding-bottom: env(safe-area-inset-bottom, 0px);
            }
            
            /* Asegurar que el input esté visible */
            [data-testid="chat-input"] {
                position: sticky !important;
                bottom: 0 !important;
                padding-bottom: env(safe-area-inset-bottom, 8px) !important;
                background-color: var(--chat--color-white) !important;
                z-index: 1000 !important;
            }
        }
        
        /* Ajustes generales para el contenedor del input */
        [data-testid="chat-input-container"] {
            position: sticky !important;
            bottom: 0 !important;
            background-color: var(--chat--color-white) !important;
            border-top: 1px solid var(--chat--color-light-shade-100) !important;
            padding-bottom: env(safe-area-inset-bottom, 0px) !important;
        }
        
        /* Ocultar el banner/subtitle del header */
        [data-testid="chat-header-subtitle"],
        .chat-header-subtitle,
        header p,
        header .subtitle {
            display: none !important;
        }
        
        /* Ocultar cualquier banner informativo */
        [class*="banner"],
        [class*="subtitle"],
        [class*="info-banner"] {
            display: none !important;
        }
    </style>
</head>
<body>
    <div id="n8n-chat"></div>
    <script type="module">
        import { createChat } from 'https://cdn.jsdelivr.net/npm/@n8n/chat/dist/chat.bundle.es.js';
        
        createChat({
            webhookUrl: '${AppConfig.n8nChatWebhookUrl}',
            target: '#n8n-chat',
            mode: 'fullscreen',
            showWelcomeScreen: true,
            loadPreviousSession: true,
            defaultLanguage: 'es',
            initialMessages: [
                '¡Hola! 👋',
                'Soy GabIA, tu asistente virtual de Nettalco. ¿En qué puedo ayudarte hoy?'
            ],
            i18n: {
                es: {
                    title: 'GabIA',
                    subtitle: '', // Vacío para no mostrar el banner
                    footer: '© 2025 Nettalco - Todos los derechos reservados',
                    getStarted: 'Nueva Conversación',
                    inputPlaceholder: 'Escribe tu pregunta...',
                },
            },
            enableStreaming: false,
        });
    </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            context.pop();
          },
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textoHeader,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

