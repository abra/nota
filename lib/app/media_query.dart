// Global override of MediaQuery (textScaleFactor, etc.)

import 'package:flutter/widgets.dart';

/// Clamps text scale factor so large system font sizes don't break the UI.
class MediaQueryRootOverride extends StatelessWidget {
  const MediaQueryRootOverride({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(maxScaleFactor: 2, child: child);
  }
}
