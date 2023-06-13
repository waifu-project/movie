// ignore_for_file: body_might_complete_normally_nullable

import 'dart:ui';

import 'package:command_palette/src/controller/command_palette_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'command_palette_text_field.dart';
import 'options/command_palette_body.dart';

const Key kCommandPaletteModalKey = Key("Command Palette Modal");

/// Modal route which houses the command palette.
///
/// When the palette is opened this modal is what appears.
class CommandPaletteModal extends ModalRoute<void> {
  /// See [CommandPalette.hintText]
  final String hintText;

  /// controller for the command palette. Passed into the modal so that it can
  /// be distributed among this route
  final CommandPaletteController commandPaletteController;

  /// How long it takes for the modal to fade in or out
  final Duration _transitionDuration;

  final Curve _transitionCurve;

  final ShortcutActivator closeKeySet;

  @override
  void dispose() {
    // palette is closed now, tell the controller
    commandPaletteController.onClose();
    super.dispose();
  }

  /// [transitionDuration] How long it takes for the modal to fade in or out
  ///
  /// [transitionCurve] The curve used when fading the modal in and out
  CommandPaletteModal({
    required this.hintText,
    required this.commandPaletteController,
    required Duration transitionDuration,
    required Curve transitionCurve,
    required this.closeKeySet,
    ImageFilter? filter,
  })  : _transitionDuration = transitionDuration,
        _transitionCurve = transitionCurve,
        super(filter: filter);

  @override
  Color? get barrierColor =>
      commandPaletteController.style.commandPaletteBarrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel =>
      "Command Palette barrier. Clicking on the barrier will dismiss the command palette";

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return CommandPaletteControllerProvider(
      key: kCommandPaletteModalKey,
      controller: commandPaletteController,
      child: FadeTransition(
        opacity: CurvedAnimation(
          curve: _transitionCurve,
          parent: animation,
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // figure out size and positioning for the modal
            double height = commandPaletteController.config.height ??
                constraints.maxHeight * (6 / 8);
            double width = commandPaletteController.config.width ??
                constraints.maxWidth * (6 / 8);

            double top = commandPaletteController.config.top ??
                constraints.maxHeight * (1 / 8);
            double left = commandPaletteController.config.left ??
                constraints.maxWidth * (1 / 8);
            double? bottom = commandPaletteController.config.bottom;
            double? right = commandPaletteController.config.right;

            return Stack(
              children: [
                Positioned(
                  top: top,
                  bottom: bottom,
                  left: left,
                  right: right,
                  child: Shortcuts(
                    shortcuts: {
                      const SingleActivator(LogicalKeyboardKey.backspace):
                          const _BackspaceIntent(),
                      const SingleActivator(LogicalKeyboardKey.arrowDown):
                          const _DownArrowIntent(),
                      const SingleActivator(LogicalKeyboardKey.arrowUp):
                          const _UpArrowIntent(),
                      const SingleActivator(LogicalKeyboardKey.keyN, control: true): const _DownArrowIntent(),
                      const SingleActivator(LogicalKeyboardKey.keyP, control: true): const _UpArrowIntent(),
                      const SingleActivator(LogicalKeyboardKey.enter):
                          const _EnterIntent(),
                      closeKeySet: const _CloseIntent(),
                    },
                    child: Actions(
                      actions: {
                        _BackspaceIntent: _BackspaceAction(
                          onInvoke: (intent) =>
                              commandPaletteController.gotoParentAction(),
                          controller: commandPaletteController,
                        ),
                        _DownArrowIntent: CallbackAction<_DownArrowIntent>(
                          onInvoke: (intent) =>
                              commandPaletteController.movedHighlightedAction(
                            down: true,
                          ),
                        ),
                        _UpArrowIntent: CallbackAction<_UpArrowIntent>(
                          onInvoke: (intent) =>
                              commandPaletteController.movedHighlightedAction(
                            down: false,
                          ),
                        ),
                        _EnterIntent: CallbackAction<_EnterIntent>(
                          onInvoke: (intent) => commandPaletteController
                              .performHighlightedAction(context),
                        ),
                        _CloseIntent: CallbackAction<_CloseIntent>(
                          onInvoke: (intent) => Navigator.of(context).pop(),
                        ),
                      },
                      child: Focus(
                        child: SizedBox(
                          height: height,
                          width: width,
                          child: Column(
                            children: [
                              CommandPaletteTextField(
                                hintText: hintText,
                                onSubmit: () => commandPaletteController
                                    .performHighlightedAction(context),
                              ),
                              const Flexible(
                                child: CommandPaletteBody(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// intents for the different control keys
class _BackspaceIntent extends Intent {
  const _BackspaceIntent();
}

class _DownArrowIntent extends Intent {
  const _DownArrowIntent();
}

class _UpArrowIntent extends Intent {
  const _UpArrowIntent();
}

class _EnterIntent extends Intent {
  const _EnterIntent();
}

class _CloseIntent extends Intent {
  const _CloseIntent();
}

class _BackspaceAction extends CallbackAction<_BackspaceIntent> {
  CommandPaletteController controller;
  _BackspaceAction({
    required OnInvokeCallback<_BackspaceIntent> onInvoke,
    required this.controller,
  }) : super(onInvoke: onInvoke);

  @override
  bool isEnabled(_) => controller.backspaceWillBeHandled();
}
