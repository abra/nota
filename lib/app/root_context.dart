// Widget tree root, collects app widgets together

import 'package:flutter/widgets.dart';
import 'package:qnotes/app/dependency_scope.dart';
import 'package:qnotes/app/material_context.dart';
import 'package:qnotes/app/window_size_scope.dart';
import 'package:qnotes/bootstrap/composition.dart';

class RootContext extends StatelessWidget {
  const RootContext({required this.compositionResult, super.key});

  final CompositionResult compositionResult;

  @override
  Widget build(BuildContext context) {
    return DependenciesScope(
      dependencies: compositionResult.dependencies,
      child: const WindowSizeScope(child: MaterialContext()),
    );
  }
}

