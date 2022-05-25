import 'package:flutter/material.dart';
import 'package:magicstep/src/models/expense.dart';

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
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image.network(
          //   img,
          //   height: 200,
          // ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.header ?? "",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 2),
                  Text('${expense.description} pcs'),
                  // const SizedBox(height: 2),
                  // Text(color),
                  const SizedBox(height: 2),
                  Text('Amount ${expense.amount}'),
                  const SizedBox(height: 2),
                  Text('Mode: ${expense.modeOfPayment}'),
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
