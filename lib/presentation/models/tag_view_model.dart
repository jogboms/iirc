import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';

import '../utils/tag_color_scheme.dart';

class TagViewModel with EquatableMixin {
  @visibleForTesting
  const TagViewModel({
    required this.id,
    required this.path,
    required this.title,
    required this.description,
    required this.color,
    required this.brightness,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.createdAt,
    required this.updatedAt,
  });

  static TagViewModel fromTag(TagEntity tag) {
    final TagColorScheme tagColorScheme = TagColorScheme.fromHex(tag.color);

    return TagViewModel(
      id: tag.id,
      path: tag.path,
      title: tag.title,
      description: tag.description,
      color: tag.color,
      brightness: tagColorScheme.brightness,
      foregroundColor: tagColorScheme.foregroundColor,
      backgroundColor: tagColorScheme.backgroundColor,
      createdAt: tag.createdAt,
      updatedAt: tag.updatedAt,
    );
  }

  final String id;
  final String path;
  final String title;
  final String description;
  final int color;
  final Brightness brightness;
  final Color foregroundColor;
  final Color backgroundColor;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[
        id,
        path,
        title,
        description,
        color,
        brightness,
        foregroundColor,
        backgroundColor,
        createdAt,
        updatedAt,
      ];
}

typedef TagViewModelList = List<TagViewModel>;
