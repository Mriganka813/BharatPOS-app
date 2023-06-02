import 'package:flutter/material.dart';

class OnlineStorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Orders'),
      ),
      body: Center(
        child: Text(
          'Online Orders',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
