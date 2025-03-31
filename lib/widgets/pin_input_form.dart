import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vwave_new/utils/validators.dart';
import 'package:vwave_new/widgets/styles/app_colors.dart';
import 'package:vwave_new/widgets/styles/text_styles.dart';
import '../../size_config.dart';

class PinInputForm extends StatefulWidget {
  const PinInputForm({Key? key, this.onFinish}) : super(key: key);

  final Function(String getPin)? onFinish;

  @override
  State<StatefulWidget> createState() => _PinInputForm();
}

class _PinInputForm extends State<PinInputForm> {
  final _formKey = GlobalKey<FormState>();

  FocusNode? pin1FocusNode;
  FocusNode? pin2FocusNode;
  FocusNode? pin3FocusNode;
  FocusNode? pin4FocusNode;
  FocusNode? pin5FocusNode;
  FocusNode? pin6FocusNode;

  @override
  void initState() {
    super.initState();
    pin1FocusNode = FocusNode();
    pin2FocusNode = FocusNode();
    pin3FocusNode = FocusNode();
    pin4FocusNode = FocusNode();
    pin5FocusNode = FocusNode();
    pin6FocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    pin1FocusNode!.dispose();
    pin2FocusNode!.dispose();
    pin3FocusNode!.dispose();
    pin4FocusNode!.dispose();
    pin5FocusNode!.dispose();
    pin6FocusNode!.dispose();
  }

  String pin = "";

  void nextField(String value, FocusNode? focusNode) {
    pin += value;
    // print("nextPin = $pin");
    if (value.length == 1) {
      focusNode!.requestFocus();
    }
  }

  void previousField(FocusNode focusNode) {
    if (pin.isNotEmpty) {
      int next = (pin.length - 1) == -1 ? 0 : pin.length - 1;
      pin = pin.substring(0, next);
    }
    // print("prevPin = $pin");
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // SizedBox(height: SizeConfig.screenHeight * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: TextFormField(
                  focusNode: pin1FocusNode,
                  obscureText: false,
                  autofocus: false,
                  maxLines: 1,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  keyboardType: TextInputType.number,
                  validator: textValidator,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    if(value.isEmpty) {
                      pin = "";
                      return;
                    }
                    nextField(value, pin2FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: TextFormField(
                  focusNode: pin2FocusNode,
                  obscureText: false,
                  validator: textValidator,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      previousField(pin1FocusNode!);
                      return;
                    }
                    nextField(value, pin3FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: TextFormField(
                  focusNode: pin3FocusNode,
                  obscureText: false,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  validator: textValidator,
                  decoration: otpInputDecoration,
                  maxLines: 1,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      previousField(pin2FocusNode!);
                      return;
                    }
                    nextField(value, pin4FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: TextFormField(
                  focusNode: pin4FocusNode,
                  obscureText: false,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  maxLines: 1,
                  validator: textValidator,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      previousField(pin3FocusNode!);
                      return;
                    }
                    nextField(value, pin5FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: TextFormField(
                  focusNode: pin5FocusNode,
                  obscureText: false,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  decoration: otpInputDecoration,
                  validator: textValidator,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      previousField(pin4FocusNode!);
                      return;
                    }
                    nextField(value, pin6FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: TextFormField(
                  focusNode: pin6FocusNode,
                  obscureText: false,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  validator: textValidator,
                  decoration: otpInputDecoration,
                  maxLines: 1,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      previousField(pin5FocusNode!);
                    } else if (value.length == 1) {
                      pin += value;
                      pin6FocusNode!.unfocus();
                      if (_formKey.currentState!.validate()) {
                        widget.onFinish!(pin);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final otpInputDecoration = InputDecoration(
    contentPadding:
        EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none
    ),
    fillColor: AppColors.grey50,
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: AppColors.primaryBase,
      ),
    ),

    // border: outlineInputBorder(),
    // focusedBorder: outlineInputBorder(),
  );
}
