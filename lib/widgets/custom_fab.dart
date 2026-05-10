import 'package:flutter/material.dart';

class CustomFab extends StatelessWidget {
  final Icon icon;
  final VoidCallback onPressed;
  final String? description;

  const CustomFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: FloatingActionButton(
            backgroundColor: Color(0xffd1d98d),
            onPressed: onPressed,
            child: icon,
          ),
        ),
        SizedBox(height: 16,),
        Text(description ?? ''),
      ],
    );
  }
}
