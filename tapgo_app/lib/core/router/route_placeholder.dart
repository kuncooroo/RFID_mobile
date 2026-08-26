import 'package:flutter/material.dart';

/// Temporary route body used until feature screens are implemented.
///
/// This is routing infrastructure, not production UI.
class RoutePlaceholder extends StatelessWidget {
  const RoutePlaceholder({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Unknown / 404 route page.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.uri});

  final String? uri;

  @override
  Widget build(BuildContext context) {
    return RoutePlaceholder(
      title: 'Page not found',
      subtitle: uri == null ? 'Unknown route' : 'No route for: $uri',
    );
  }
}
