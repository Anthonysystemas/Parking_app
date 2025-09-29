import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'reservar_parking_widget.dart' show ReservarParkingWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReservarParkingModel extends FlutterFlowModel<ReservarParkingWidget> {
  /// State fields for stateful widgets in this page.

  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  
  // State field(s) for Checkbox widgets.
  bool? checkboxValue1;
  bool? checkboxValue2;
  bool? checkboxValue3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dropDownValueController?.dispose();
  }
}