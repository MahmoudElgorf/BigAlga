import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({Key? key, this.message = 'جاري التحميل...'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.seaGreen),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}