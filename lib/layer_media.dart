import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'viewer.dart';
import 'viewer_controller.dart';
import 'widgets/placeholder_image.dart';

class StoryLayerMedia extends StatefulWidget {
  final StoryViewerController viewerController;
  final StoryViewer viewer;

  const StoryLayerMedia({Key key, this.viewerController, this.viewer})
      : super(key: key);
  @override
  StoryLayerMediaState createState() => StoryLayerMediaState();
}

class StoryLayerMediaState extends State<StoryLayerMedia> {
  StoryViewerController get controller => widget.viewerController;

  @override
  void initState() {
    super.initState();
    controller.addCallBacks(onIndexChanged: onIndexChanged);
  }

  void onIndexChanged() {
    refreshState();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.currentStory.url.isEmpty) {
      return Container();
    }
    return ExtendedImage(
        width: ScreenUtil.screenWidth,
        height: ScreenUtil.screenHeight,
        image: ExtendedNetworkImageProvider(controller.currentStory.url),
        enableSlideOutPage: true,
        mode: ExtendedImageMode.gesture,
        enableMemoryCache: true,
        alignment: widget.viewer.mediaAlignment ?? Alignment.center,
        fit: widget.viewer.mediaFit ?? BoxFit.fitWidth,
        initGestureConfigHandler: (s) {
          return GestureConfig(
            maxScale: 1.0,
            minScale: 1.0,
            animationMinScale: 1.0,
            animationMaxScale: 1.0,
          );
        },
        heroBuilderForSlidingPage: (Widget result) {
          return Hero(
            tag: controller.currentHeroTag,
            child: result,
            flightShuttleBuilder: (BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext) {
              final Hero hero = flightDirection == HeroFlightDirection.pop
                  ? fromHeroContext.widget
                  : toHeroContext.widget;
              return hero.child;
            },
          );
        },
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return PlaceholderImage(
                loading: true,
                backgroundColor: widget.viewer.placeholderBackground,
                backgroundColors: widget.viewer.placeholderBackgrounds,
              );
              break;
            case LoadState.failed:
              return PlaceholderImage(
                iconData: SFSymbols.question,
                backgroundColor: widget.viewer.placeholderBackground,
                backgroundColors: widget.viewer.placeholderBackgrounds,
              );
              break;
            case LoadState.completed:
              SchedulerBinding.instance.addPostFrameCallback((p) {
                controller.play();
              });
              break;
            default:
          }
        });
  }

  void refreshState() {
    if (this.mounted) {
      setState(() {});
    }
  }
}