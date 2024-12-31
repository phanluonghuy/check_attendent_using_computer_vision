import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  static void showSuccess(String message,BuildContext context) {
    toastification.show(
        context:
        context, // optional if you use ToastificationWrapper
        title: Text(message,style: TextStyle(fontSize: 20),),
        type: ToastificationType.success,
        style: ToastificationStyle.minimal,
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.topRight,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        icon: const Icon(Icons.check),
        showIcon: true, // show or hide the icon
        primaryColor: Colors.green,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
            spreadRadius: 0,
          )
        ],
        showProgressBar: true,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true);
  }
  static void showError(String message,BuildContext context) {
    toastification.show(
        context:
        context, // optional if you use ToastificationWrapper
        title: Text(message,style: TextStyle(fontSize: 20),),
        type: ToastificationType.error,
        style: ToastificationStyle.minimal,
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.topRight,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        icon: const Icon(Icons.error_outline_outlined),
        showIcon: true, // show or hide the icon
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
            spreadRadius: 0,
          )
        ],
        showProgressBar: true,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true);
  }
}