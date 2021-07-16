import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../pages/image_picker_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/page_utils.dart';
import '../widgets/widget.dart';

/// An input widget that allows selection of one or more photos, as well as
/// taking a photo from the device's camera.
class ImageInput extends StatelessWidget {
  final bool enabled;
  final bool allowsMultipleSelection;
  final List<PickedImage> currentImages;
  final void Function(List<PickedImage>) onImagesPicked;

  ImageInput({
    required this.onImagesPicked,
    this.enabled = true,
    this.allowsMultipleSelection = true,
    List<PickedImage> initialImages = const [],
  }) : currentImages = initialImages;

  ImageInput.single({
    required Future<bool> Function() requestPhotoPermission,
    bool enabled = true,
    PickedImage? currentImage,
    required Function(PickedImage?) onImagePicked,
  }) : this(
          enabled: enabled,
          allowsMultipleSelection: false,
          initialImages: currentImage == null ? [] : [currentImage],
          onImagesPicked: (images) =>
              onImagePicked(images.isNotEmpty ? images.first : null),
        );

  @override
  Widget build(BuildContext context) {
    return EnabledOpacity(
      enabled: enabled,
      child: InkWell(
        onTap: enabled
            ? () {
                push(
                  context,
                  ImagePickerPage(
                    allowsMultipleSelection: allowsMultipleSelection,
                    initialImages: currentImages,
                    onImagesPicked: (_, images) => onImagesPicked(images),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: insetsVerticalDefault,
          child: HorizontalSafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: insetsHorizontalDefault,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        allowsMultipleSelection
                            ? Strings.of(context).inputPhotosLabel
                            : Strings.of(context).inputPhotoLabel,
                        style: stylePrimary(context),
                      ),
                      RightChevronIcon(),
                    ],
                  ),
                ),
                _buildThumbnails(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnails() {
    if (currentImages.isEmpty) {
      return Empty();
    }

    return Container(
      padding: insetsTopWidgetSmall,
      constraints: BoxConstraints(maxHeight: galleryMaxThumbSize),
      child: ListView.separated(
        physics: enabled ? null : NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: currentImages.length,
        itemBuilder: (context, i) {
          var image = currentImages[i];
          var leftPadding = i == 0 ? paddingDefault : 0.0;
          var rightPadding =
              i == currentImages.length - 1 ? paddingDefault : 0.0;
          return Container(
            padding: EdgeInsets.only(
              left: leftPadding,
              right: rightPadding,
            ),
            width: galleryMaxThumbSize + leftPadding + rightPadding,
            child: ClipRRect(
              child: image.thumbData == null
                  ? Image.file(image.originalFile!, fit: BoxFit.cover)
                  : Image.memory(image.thumbData!, fit: BoxFit.cover),
              borderRadius: BorderRadius.all(
                Radius.circular(floatingCornerRadius),
              ),
            ),
          );
        },
        separatorBuilder: (context, i) => Container(width: gallerySpacing),
      ),
    );
  }
}
