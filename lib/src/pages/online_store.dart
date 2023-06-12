import 'package:flutter/material.dart';

class OnlineStorePage extends StatefulWidget {
  static const routeName = '/onlineStorePage';

  @override
  _OnlineStorePageState createState() => _OnlineStorePageState();
}

class _OnlineStorePageState extends State<OnlineStorePage> {
  String _selectedStatus = 'ALL';
  final List<String> _statusOptions = [
    'PENDING',
    'ACTIVE',
    'ON THE WAY',
    'DELIVERED',
    'COMPLETED',
    'RETURNED',
    'REJECTED',
    'ALL'
  ];

  final List<Map<String, dynamic>> _orders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Store Page'),
      ),
      body: Column(
        children: [
          Center(
            child: DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              items:
                  _statusOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (BuildContext context, int index) {
                final order = _orders[index];
                if (_selectedStatus != order['status'] &&
                    _selectedStatus != 'ALL') return SizedBox.shrink();
                return Card(
                  child: ListTile(
                    title: Text(order['product_name']),
                    subtitle: Text('Order ID: ${order['id']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Qty: ${order['qty']}'),
                        Text('Price: \$${order['price']}'),
                        Text('Total: \$${order['total']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // TODO: If status is PENDING, show accept and reject buttons
          // TODO: Use GestureDetector instead of ElevatedButton
        ],
      ),
    );
  }
}
