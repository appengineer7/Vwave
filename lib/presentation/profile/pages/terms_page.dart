
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../constants.dart';
import '../../../utils/general.dart';
import '../../../widgets/styles/text_styles.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<StatefulWidget> createState() => _TermsPage();
}

class _TermsPage extends State<TermsPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Terms and Conditions",
          style: titleStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HtmlWidget(terms,
                onTapUrl: (url) {
                  GeneralUtils().launchInWebViewOrVC(url);
                  return true;
                },),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}