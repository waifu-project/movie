import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../command_palette.dart';
import 'controller/command_palette_controller.dart';
import 'widgets/command_palette_modal.dart';

/// Used to communicate the toggle status between the inherited widget and
/// stateful inner widget
class _CommandPaletteToggler extends ValueNotifier<bool> {
  _CommandPaletteToggler(bool value) : super(value);
}

/// Command palette is a widget that is summoned by a keyboard shortcut, or by
/// programmatic means.
///
/// The command palette displays a list of actions and the user can type text
/// into the search bar to filter those actions.
class CommandPalette extends InheritedWidget {
  /// List of all the actions that are supported by this command palette
  final List<CommandPaletteAction> actions;

  /// Configuration options for the command pallette, includes both visual and
  /// functional configuration
  final CommandPaletteConfig config;

  final FocusNode? focusNode;

  late final _CommandPaletteToggler _toggler;

  late final CommandPaletteController _controller;

  CommandPalette({
    Key? key,
    CommandPaletteConfig? config,
    required this.actions,
    required Widget child,
    this.focusNode,
  })  : config = config ?? CommandPaletteConfig(),
        super(
          key: key,
          child: _CommandPaletteInner(
            key: key,
            actions: actions,
            controller: CommandPaletteController(
              actions,
              config: config ?? CommandPaletteConfig(),
            ),
            config: config ?? CommandPaletteConfig(),
            toggler: _CommandPaletteToggler(false),
            focusNode: focusNode, 
            child: child,
          ),
        ) {
    _toggler = (super.child as _CommandPaletteInner).toggler;
    _controller = (super.child as _CommandPaletteInner).controller;
  }

  static CommandPalette of(BuildContext context) {
    final CommandPalette? result =
        context.dependOnInheritedWidgetOfExactType<CommandPalette>();
    assert(result != null, "No CommandPalette in context");
    return result!;
  }

  /// Opens the command palette. Closing it can be achieved in the same way as
  /// closing other modal routes
  void open() {
    _toggler.value = true;
  }

  /// Closes the command palette
  void close() {
    _toggler.value = false;
  }

  /// Opens the command palette to the action with the given id. If no action
  /// with the given id is found, a [StateError] will be thrown. The action
  /// should also be a nested action
  void openToAction(Object id) {
    final CommandPaletteAction action;
    try {
      action = actions.firstWhere((a) => a.id == id);
    }
    // create a new state error with more relevant information
    on StateError {
      throw StateError("No CommandPallette Action found with id $id");
    }

    // open the palette and set the selected action
    open();
    _controller.currentlySelectedAction = action;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return !equals(oldWidget);
  }

  bool equals(Object other) {
    if (identical(this, other)) return true;

    return other is CommandPalette &&
        listEquals(other.actions, actions) &&
        other.config == config;
  }
}

/// The actual widget which that handles the opening and closing of the palette.
class _CommandPaletteInner extends StatefulWidget {
  final Widget child;
  final List<CommandPaletteAction> actions;
  final CommandPaletteConfig config;
  final _CommandPaletteToggler toggler;
  final CommandPaletteController controller;
  final FocusNode? focusNode;
  const _CommandPaletteInner({
    Key? key,
    required this.child,
    required this.actions,
    required this.config,
    required this.toggler,
    required this.controller,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<_CommandPaletteInner> createState() => _CommandPaletteInnerState();
}

class _CommandPaletteInnerState extends State<_CommandPaletteInner> {
  bool _commandPaletteOpen = false;

  late CommandPaletteStyle _style;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _CommandPaletteInner oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool actionsChanged = !listEquals(oldWidget.actions, widget.actions);

    if (oldWidget.config != widget.config || actionsChanged) {
      _initStyle();
    }

    // if (actionsChanged) {
    //   widget.controller.actions = widget.actions;
    // }

    // refresh toggler listeners if need be
    if (oldWidget.toggler != widget.toggler) {
      oldWidget.toggler.removeListener(_handleToggle);
      widget.toggler.addListener(_handleToggle);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    widget.toggler.addListener(_handleToggle);

    _initStyle();
  }

  void _handleToggle() {
    // is open
    if (widget.toggler.value && !_commandPaletteOpen) {
      _openCommandPalette(context);
    } else if (!widget.toggler.value && _commandPaletteOpen) {
      _closeCommandPalette();
    }
  }

  /// Initialize all the styles and stuff
  void _initStyle() {
    CommandPaletteStyle styleToCopy =
        widget.config.style ?? const CommandPaletteStyle();

    var newActionLabelTextStyle = styleToCopy.actionLabelTextStyle ??
        Theme.of(context).primaryTextTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            );
    _style = CommandPaletteStyle(
      actionColor: styleToCopy.actionColor ?? Theme.of(context).canvasColor,
      selectedColor:
          styleToCopy.selectedColor ?? Theme.of(context).highlightColor,
      actionLabelTextStyle: newActionLabelTextStyle,
      highlightedLabelTextStyle: styleToCopy.highlightedLabelTextStyle ??
          Theme.of(context).primaryTextTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
      actionDescriptionTextStyle: styleToCopy.actionDescriptionTextStyle ??
          Theme.of(context).primaryTextTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
      actionLabelTextAlign: styleToCopy.actionLabelTextAlign,
      borderRadius: styleToCopy.borderRadius,
      commandPaletteBarrierColor: styleToCopy.commandPaletteBarrierColor,
      elevation: styleToCopy.elevation,
      highlightSearchSubstring: styleToCopy.highlightSearchSubstring,
      textFieldInputDecoration: styleToCopy.textFieldInputDecoration == null
          ? kDefaultInputDecoration
              .applyDefaults(Theme.of(context).inputDecorationTheme)
          : styleToCopy.textFieldInputDecoration!
              .applyDefaults(Theme.of(context).inputDecorationTheme),
      prefixNestedActions: styleToCopy.prefixNestedActions,
      instructionColor: styleToCopy.instructionColor ??
          newActionLabelTextStyle?.color?.withOpacity(.84),
      barrierFilter: styleToCopy.barrierFilter,
    );

    widget.controller.style = _style;
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommandPaletteControllerProvider(
      controller: widget.controller,
      child: Builder(
        builder: (context) {
          return Shortcuts(
            shortcuts: {
              widget.config.openKeySet: const _OpenCommandPaletteIntent()
            },
            child: Actions(
              actions: {
                _OpenCommandPaletteIntent:
                    CallbackAction<_OpenCommandPaletteIntent>(
                  // ignore: body_might_complete_normally_nullable
                  onInvoke: (_) => _openCommandPalette(context),
                )
              },
              child: Focus(
                focusNode: widget.focusNode,
                autofocus: true,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Opens the command palette
  void _openCommandPalette(BuildContext context) {
    setState(() {
      _commandPaletteOpen = true;
      widget.toggler.value = true;
    });

    Navigator.of(context)
        .push(
          CommandPaletteModal(
            hintText: widget.config.hintText,

            // we pass the controller in so that it can be re-provided within the
            // tree of the modal
            commandPaletteController: widget.controller,
            transitionCurve: widget.config.transitionCurve,
            transitionDuration: widget.config.transitionDuration,
            closeKeySet: widget.config.closeKeySet,
            filter: widget.config.style?.barrierFilter,
          ),
        )
        .then(
          (value) => setState(() {
            _commandPaletteOpen = false;
            widget.toggler.value = false;
          }),
        );
  }

  /// Closes the command bar
  void _closeCommandPalette() {
    setState(() {
      _commandPaletteOpen = false;
      widget.toggler.value = false;
    });
    Navigator.of(context).pop();
  }
}

class _OpenCommandPaletteIntent extends Intent {
  const _OpenCommandPaletteIntent();
}
