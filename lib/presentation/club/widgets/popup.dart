import 'package:flutter/material.dart';

/// A widget that shows a popup relative to a target widget.
///
/// The popup is declaratively shown/hidden using an [OverlayPortalController].
///
/// It is positioned relative to the target widget using the [followerAnchor] and [targetAnchor] properties.
class Popup extends StatefulWidget {
  const Popup({
    required this.child,
    required this.follower,
    required this.controller,
    this.offset = Offset.zero,
    this.followerAnchor = Alignment.topCenter,
    this.targetAnchor = Alignment.bottomCenter,
    this.dismissible = true,
    super.key,
  });

  /// The target widget that will be used to position the follower widget.
  final Widget child;

  /// The widget that will be positioned relative to the target widget.
  final Widget follower;

  /// The controller that will be used to show/hide the overlay.
  final OverlayPortalController controller;

  /// The alignment of the follower widget relative to the target widget.
  ///
  /// Defaults to [Alignment.topCenter].
  final Alignment followerAnchor;

  /// The alignment of the target widget relative to the follower widget.
  ///
  /// Defaults to [Alignment.bottomCenter].
  final Alignment targetAnchor;

  /// The offset of the follower widget relative to the target widget.
  /// This is useful for fine-tuning the position of the follower widget.
  ///
  /// Defaults to [Offset.zero].
  final Offset offset;

  /// Whether the popup should be dismissed when the user taps outside of it.
  final bool dismissible;

  @override
  State<Popup> createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  /// The link between the target widget and the follower widget.
  final _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      // Link the target widget to the follower widget.
      link: _layerLink,
      child: OverlayPortal(
        controller: widget.controller,
        child: widget.child,
        overlayChildBuilder: (BuildContext context) {
          // It is needed to wrap the follower widget in a widget that fills the space of the overlay.
          // This is needed to make sure that the follower widget is positioned relative to the target widget.
          // If not wrapped, the follower widget will fill the screen and be positioned incorrectly.
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.dismissible ? widget.controller.hide : null,
            child: UnconstrainedBox(
              child: CompositedTransformFollower(
                // Link the follower widget to the target widget.
                link: _layerLink,
                // The follower widget should not be shown when the link is broken.
                showWhenUnlinked: false,
                followerAnchor: widget.followerAnchor,
                targetAnchor: widget.targetAnchor,
                offset: widget.offset,
                child: widget.follower,
              ),
            ),
          );
        },
      ),
    );
  }
}