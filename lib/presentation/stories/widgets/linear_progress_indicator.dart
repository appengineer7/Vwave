

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../widgets/styles/app_colors.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final String barId;
  const ProgressIndicatorWidget(this.barId, {super.key});

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget> {


  final ValueNotifier<double> valueNotifier = ValueNotifier(0.0);
  late StreamSubscription<Map<String, dynamic>> progressStream;

  @override
  void initState() {
    super.initState();
    progressStream = linearProgressIndicatorController.stream.listen((data) {
      if(data["barId"] == widget.barId) {
        valueNotifier.value = data["value"];
      }
    });
  }

  @override
  void dispose() {
    progressStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
    // return ValueListenableBuilder(
    //   valueListenable: valueNotifier,
    //   builder: (context, v, c) {
    //     return AnimatedLinearProgressIndicator(
    //       value: v,
    //       animationDuration: const Duration(seconds: 2),
    //       minHeight: 7,
    //       valueColor:
    //       const AlwaysStoppedAnimation<Color>(AppColors.secondaryBase),
    //       backgroundColor: Colors.white,
    //     );
    //   },
    // );
  }

}