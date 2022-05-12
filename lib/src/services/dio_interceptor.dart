import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';

class CustomInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    log(err.response?.data.toString() ?? "");
    locator<GlobalServices>().showSnackBar(
      message: err.response?.data.toString() ?? "",
      time: 2,
      bgcolor: Colors.red,
    );
    return super.onError(err, handler);
  }
}
