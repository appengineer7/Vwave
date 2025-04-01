
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vwave/presentation/events/models/club_event.dart';
import 'package:vwave/widgets/nav_back_button.dart';
import '../../../../widgets/styles/app_colors.dart';
import '../../../../widgets/styles/text_styles.dart';
import '../../../events/widgets/club_event_cardview.dart';
import '../../../livestream/widgets/livestream_horizontal_display.dart';

class UserEventsPage extends ConsumerStatefulWidget {
  final List<ClubEvent> clubEvents;
  final String userType;
  final Map<String, dynamic> locationDetails;
  const UserEventsPage(this.clubEvents, this.userType, this.locationDetails, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserEventsPageState();
}

class _UserEventsPageState extends ConsumerState<UserEventsPage> {

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
        title: Text("Events", style: titleStyle.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w700),),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: widget.clubEvents.map((e) => ClubEventCardViewDisplay(e, spaceBetween: 2.2, viewWidth: MediaQuery.of(context).size.width, userType: widget.userType, allowRightMargin: false, locationDetails: widget.locationDetails,)).toList(),
            ),
          ),
        ),
      ),
    );
  }
}