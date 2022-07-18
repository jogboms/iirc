import 'package:flutter/material.dart';
import 'package:iirc/domain/models/tag.dart';

class TagViewModel extends TagModel {
  const TagViewModel._({
    required super.id,
    required super.path,
    required super.title,
    required super.description,
    required super.color,
    required super.createdAt,
    required super.updatedAt,
    required this.brightness,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  static TagViewModel fromTag(TagModel tag) {
    final Color backgroundColor = Color(tag.color);
    final Brightness brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    final Color foregroundColor = brightness == Brightness.dark ? Colors.white : Colors.black;

    return TagViewModel._(
      id: tag.id,
      path: tag.path,
      title: tag.title,
      description: tag.description,
      color: tag.color,
      createdAt: tag.createdAt,
      updatedAt: tag.updatedAt,
      brightness: brightness,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }

  final Brightness brightness;
  final Color foregroundColor;
  final Color backgroundColor;
}

typedef TagViewModelList = List<TagViewModel>;
