import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopos/src/models/expense.dart';

class ExpenseCardHorizontal extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const ExpenseCardHorizontal({
    Key? key,
    required this.expense,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime? timestamp = expense.createdAt?.toLocal();
    String date =
        timestamp == null ? '--' : DateFormat('dd-MM-yyyy').format(timestamp);
    String time =
        timestamp == null ? '--' : DateFormat('jm').format(timestamp.toUtc());

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    expense.header ?? "",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 2),
                  Text('Date : $date'),
                  const SizedBox(height: 2),
                  Text('Time : $time'),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text('Net Amount :'),
                      Text(' ₹${expense.amount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Payment Method : ${expense.modeOfPayment}'),
                  const SizedBox(height: 2),
                  Text('${expense.description}'),
                  const SizedBox(height: 2),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton<int>(
                child: const Icon(Icons.more_vert_rounded),
                onSelected: (int e) {
                  if (e == 0) {
                    onEdit();
                  } else if (e == 1) {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuItem<int>>[
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ];
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
