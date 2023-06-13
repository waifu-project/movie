// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:command_palette/command_palette.dart';
import 'package:command_palette/src/controller/command_palette_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The Text Field portion of the command palette
class CommandPaletteTextField extends StatefulWidget {
  /// See [CommandPalette.hintText]
  final String hintText;

  /// The field has been submitted. Only gets called on Android and iOS
  final VoidCallback onSubmit;

  const CommandPaletteTextField({
    required this.hintText,
    required this.onSubmit,
    Key? key,
  }) : super(key: key);

  @override
  _CommandPaletteTextFieldState createState() =>
      _CommandPaletteTextFieldState();
}

class _CommandPaletteTextFieldState extends State<CommandPaletteTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();

    // we're a greedy focus node. Make sure we always have it (so long as the
    // command palette is up)
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommandPaletteController controller =
        CommandPaletteControllerProvider.of(context);
    final style = controller.style;
    InputDecoration inputDecoration = style.textFieldInputDecoration!;

    // if no prefix was provided, the selected action is a nested action, and
    // the user indicates that they want nested actions to have prefix text,
    // then we'll create prefix text with the nested action's parent's label
    final bool styleHasNoPrefix = inputDecoration.prefix == null &&
        inputDecoration.prefixIcon == null &&
        inputDecoration.prefixText == null;
    if (styleHasNoPrefix &&
        style.prefixNestedActions &&
        controller.currentlySelectedAction?.actionType ==
            CommandPaletteActionType.nested) {
      inputDecoration = inputDecoration.copyWith(
        prefixText: "${controller.currentlySelectedAction!.label}: ",
        hintText: "",
      );
    }

    final radius = style.borderRadius.resolve(Directionality.of(context));
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.only(
        topLeft: radius.topLeft,
        topRight: radius.topRight,
      ),
      child: TextField(
        controller: controller.textEditingController,
        textInputAction: TextInputAction.done,
        focusNode: _focusNode,
        decoration: inputDecoration,
        onSubmitted: (val) {
          // with on-screen keyboards, the "enter" (or action key), doesn't get
          // mapped to an enter key event. There are some exceptions, e.g.
          // Hacker's Keyboard (but only if the text input action is none).
          // As such I'll just capture the submit action here and bubble that
          // up to the modal so it knows to process the selected action
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
            widget.onSubmit();
          }
        },
      ),
    );
  }
}
