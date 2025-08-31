// web_utils.dart
import 'dart:ui_web' as ui_web;

// Use this instead of the deprecated platformViewRegistry
ui_web.PlatformViewRegistry get platformViewRegistry =>
    ui_web.platformViewRegistry;
