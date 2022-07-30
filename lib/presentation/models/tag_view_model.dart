import 'dart:ui';

import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';

import '../utils/tag_color_scheme.dart';

class TagViewModel extends TagModel {
  @visibleForTesting
  const TagViewModel({
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
    final TagColorScheme tagColorScheme = TagColorScheme.fromHex(tag.color);

    return TagViewModel(
      id: tag.id,
      path: tag.path,
      title: tag.title,
      description: tag.description,
      color: tag.color,
      createdAt: tag.createdAt,
      updatedAt: tag.updatedAt,
      brightness: tagColorScheme.brightness,
      foregroundColor: tagColorScheme.foregroundColor,
      backgroundColor: tagColorScheme.backgroundColor,
    );
  }

  final Brightness brightness;
  final Color foregroundColor;
  final Color backgroundColor;
}

typedef TagViewModelList = List<TagViewModel>;
