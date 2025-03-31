
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vwave_new/presentation/livestream/models/livestream.dart';
import 'package:vwave_new/utils/general.dart';
import 'package:vwave_new/utils/storage.dart';
import 'package:vwave_new/widgets/nav_back_button.dart';
import 'package:vwave_new/widgets/user_avatar.dart';

import '../../../../widgets/search_field.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../livestream/widgets/livestream_horizontal_display.dart';

class UserLivestreamPage extends ConsumerStatefulWidget {
  final List<Livestream> livestreams;
  const UserLivestreamPage(this.livestreams, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserLivestreamPage();
}

class _UserLivestreamPage extends ConsumerState<UserLivestreamPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: NavBackButton(
            color: AppColors.titleTextColor,
            onPress: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text("Livestreams", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: widget.livestreams.map((e) => LivestreamHorizontalDisplay(e, userView: true,)).toList(),
            ),
          ),
        ),
      ),
    );
  }
}