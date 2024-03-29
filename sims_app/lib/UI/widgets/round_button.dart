import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;

  const RoundButton({Key? key, required this.onTap, required this.title, this.loading=false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: loading ? CircularProgressIndicator(strokeWidth: 4,color: Colors.white,):
           Text(
             title,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
