import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:shopos/src/services/set_or_change_pin.dart';
import 'package:shopos/src/widgets/custom_button.dart';

class SetPinPage extends StatefulWidget {
  static const routeName = 'set-pin';
  const SetPinPage({
    Key? key,
    required this.isPinSet,
  }) : super(key: key);

  final bool isPinSet;

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final TextEditingController oldPinControlller = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController rePinController = TextEditingController();
  final TextEditingController deletePinController = TextEditingController();

  PinService pinService = PinService();

  @override
  void dispose() {
    oldPinControlller.dispose();
    newPinController.dispose();
    rePinController.dispose();
    deletePinController.dispose();
    super.dispose();
  }

  setPin() async {
    final String oldpin = oldPinControlller.text.trim().toString();
    final String newpin = newPinController.text.trim().toString();
    final String repin = rePinController.text.trim().toString();
    print(oldpin);
    print(newpin);
    print(repin);

    if (newpin.length < 6 || repin.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Invalid pin')));
      return;
    }
    if (widget.isPinSet && oldpin == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Invalid pin')));
      return;
    }

    if (newpin != repin) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Pin does not match')));
      return;
    }

    if (widget.isPinSet) {
      // print(int.parse(oldpin));
      // print(int.parse(newpin));
      await pinService.changePin(int.parse(oldpin), int.parse(newpin));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pin lock has changed.')));
    } else {
      await pinService.setPin(int.parse(newpin));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pin lock has activated.')));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back)),
        title: Text("Set /Change Pin"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {},
          child: SizedBox(
            height: height - 100,
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/images/changepin.svg',
                  height: 200,
                  width: 200,
                ),
                if (widget.isPinSet)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Enter old pin',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  height: 10,
                ),
                if (widget.isPinSet)
                  Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: _pinfield(oldPinControlller)),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Enter Your New Pin',
                    style: TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: _pinfield(newPinController)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Re-type Your Pin',
                    style: TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: _pinfield(rePinController)),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                      child: SizedBox(
                        width: !(widget.isPinSet)? 300:170,
                        child: CustomButton(
                          title: !(widget.isPinSet) ? 'SET PIN' : 'CHANGE PIN',
                          onTap: () {
                            setPin();
                          },
                        ),
                      ),
                    ),
                    if (widget.isPinSet)
                      Center(
                        child: SizedBox(
                          width: 170,
                          child: CustomButton(
                            title: "DELETE PIN",
                            onTap: () async {
                              bool? done = await _showPinDialog();
                              if (done != null && done) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pinfield(TextEditingController textEditingController) {
    return PinCodeTextField(
      autoDisposeControllers: false,
      appContext: context,

      length: 6,
      obscureText: true,
      obscuringCharacter: '*',

      blinkWhenObscuring: true,
      animationType: AnimationType.fade,
      validator: (v) {
        if (v!.length < 6) {
          return "Invalid pin";
        }
        return null;
      },

      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 40,
        fieldWidth: 40,
        inactiveColor: Colors.black45,
        inactiveFillColor: Colors.white,
        selectedFillColor: Colors.white,
        selectedColor: Colors.black45,
        disabledColor: Colors.black,
        activeFillColor: Colors.white,
      ),
      cursorColor: Colors.black,
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      // errorAnimationController: errorController,
      controller: textEditingController,
      keyboardType: TextInputType.number,
      boxShadows: const [
        BoxShadow(
          offset: Offset(0, 1),
          color: Colors.black12,
          blurRadius: 10,
        )
      ],
      onCompleted: (v) {
        debugPrint("Completed");
      },
      // onTap: () {
      //   print("Pressed");
      // },
      onChanged: (value) {
        debugPrint(value);
        // setState(() {
        //   currentText = value;
        // });
      },
    );
  }

  Future<bool?> _showPinDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              content: PinCodeTextField(
                autoDisposeControllers: false,
                appContext: context,
                length: 6,
                obscureText: true,
                obscuringCharacter: '*',
                blinkWhenObscuring: true,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 40,
                  fieldWidth: 30,
                  inactiveColor: Colors.black45,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  selectedColor: Colors.black45,
                  disabledColor: Colors.black,
                  activeFillColor: Colors.white,
                ),
                cursorColor: Colors.black,
                controller: deletePinController,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
              ),
              title: Text('Enter your pin'),
              actions: [
                Center(
                    child: CustomButton(
                        title: 'Delete',
                        onTap: () async {
                          final String deletePin = deletePinController.text.trim().toString();
                          bool status = await pinService.verifyPin(int.parse(deletePin));
                          if (status) {
                            try {
                              await pinService.deletePin(int.parse(deletePin));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pin lock has deleted.')));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('pin is not deleted'),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }

                            deletePinController.clear();
                            Navigator.pop(ctx, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Incorrect pin'),
                              backgroundColor: Colors.red,
                            ));
                            Navigator.of(ctx).pop();
                            deletePinController.clear();
                            return;
                          }
                        }))
              ],
            ));
  }
}
