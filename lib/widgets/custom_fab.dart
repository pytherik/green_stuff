import 'package:flutter/material.dart';

class CustomFab extends StatelessWidget {
  final Icon icon;
  final VoidCallback onPressed;
  final String? description;
  final Object? heroTag;

  const CustomFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.description,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: FloatingActionButton(
            heroTag: heroTag,
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
