import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'registrarsesion_widget.dart' show RegistrarsesionWidget;
import 'package:flutter/material.dart';

class RegistrarsesionModel extends FlutterFlowModel<RegistrarsesionWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for nombre widget.
  FocusNode? nombreFocusNode;
  TextEditingController? nombreTextController;
  String? Function(BuildContext, String?)? nombreTextControllerValidator;
  // State field(s) for placa widget.
  FocusNode? placaFocusNode;
  TextEditingController? placaTextController;
  String? Function(BuildContext, String?)? placaTextControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for clave1 widget.
  FocusNode? clave1FocusNode;
  TextEditingController? clave1TextController;
  late bool clave1Visibility;
  String? Function(BuildContext, String?)? clave1TextControllerValidator;
  // State field(s) for clave2 widget.
  FocusNode? clave2FocusNode;
  TextEditingController? clave2TextController;
  late bool clave2Visibility;
  String? Function(BuildContext, String?)? clave2TextControllerValidator;

  @override
  void initState(BuildContext context) {
    clave1Visibility = false;
    clave2Visibility = false;
  }

  @override
  void dispose() {
    nombreFocusNode?.dispose();
    nombreTextController?.dispose();

    placaFocusNode?.dispose();
    placaTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    clave1FocusNode?.dispose();
    clave1TextController?.dispose();

    clave2FocusNode?.dispose();
    clave2TextController?.dispose();
  }
}
