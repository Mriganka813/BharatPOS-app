import 'package:flutter/material.dart';

class PartyCreditPage extends StatefulWidget {
  static const routeName = '/party_credit';

  ///
  final String partyId;

  ///
  const PartyCreditPage({
    Key? key,
    required this.partyId,
  }) : super(key: key);

  @override
  State<PartyCreditPage> createState() => _PartyCreditPageState();
}

class _PartyCreditPageState extends State<PartyCreditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
