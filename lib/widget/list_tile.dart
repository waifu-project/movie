/// the package: https://pub.dev/packages/cupertino_list_tile

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart'
    show
        ListTileTheme,
        MaterialState,
        MaterialStateMouseCursor,
        MaterialStateProperty;
export 'package:flutter/material.dart' show ListTileTheme;

import 'package:flutter/gestures.dart';

typedef RectCallback = Rect Function();
typedef _GetRectCallback = RectCallback? Function(RenderBox referenceBox);
typedef _CheckContext = bool Function(BuildContext context);

class ListTileBackground extends StatelessWidget {
  const ListTileBackground({
    Key? key,
    this.child,
    this.onTap,
    this.onTapDown,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor = MouseCursor.defer,
    this.borderRadius,
    this.customBorder,
    this.focusColor,
    this.hoverColor,
    this.pressColor,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
  }) : super(key: key);

  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCallback? onTapCancel;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final ValueChanged<bool?>? onHighlightChanged;
  final ValueChanged<bool?>? onHover;
  final MouseCursor mouseCursor;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? pressColor;
  final bool excludeFromSemantics;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool canRequestFocus;

  RectCallback? getRectCallback(RenderBox referenceBox) => null;

  @override
  Widget build(BuildContext context) {
    return _ListTileBackgroundStateWidget(
      child: child,
      onTap: onTap,
      onTapDown: onTapDown,
      onTapCancel: onTapCancel,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHighlightChanged: onHighlightChanged,
      onHover: onHover,
      mouseCursor: mouseCursor,
      borderRadius: borderRadius,
      customBorder: customBorder,
      focusColor: focusColor,
      hoverColor: hoverColor,
      pressColor: pressColor,
      excludeFromSemantics: excludeFromSemantics,
      focusNode: focusNode,
      canRequestFocus: canRequestFocus,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      getRectCallback: getRectCallback,
      debugCheckContext: debugCheckContext,
    );
  }

  @mustCallSuper
  bool debugCheckContext(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    return true;
  }
}

class _ListTileBackgroundStateWidget extends StatefulWidget {
  const _ListTileBackgroundStateWidget({
    this.child,
    this.onTap,
    this.onTapDown,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor = MouseCursor.defer,
    this.borderRadius,
    this.customBorder,
    this.focusColor,
    this.hoverColor,
    this.pressColor,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
    this.getRectCallback,
    this.debugCheckContext,
  });

  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCallback? onTapCancel;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final ValueChanged<bool?>? onHighlightChanged;
  final ValueChanged<bool?>? onHover;
  final MouseCursor mouseCursor;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? pressColor;
  final bool excludeFromSemantics;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool canRequestFocus;
  final _GetRectCallback? getRectCallback;
  final _CheckContext? debugCheckContext;

  @override
  _ListTileBackgroundState createState() => _ListTileBackgroundState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> gestures = <String>[
      if (onTap != null) 'tap',
      if (onDoubleTap != null) 'double tap',
      if (onLongPress != null) 'long press',
      if (onTapDown != null) 'tap down',
      if (onTapCancel != null) 'tap cancel',
    ];
    properties
        .add(IterableProperty<String>('gestures', gestures, ifEmpty: '<none>'));
    properties.add(DiagnosticsProperty<MouseCursor>('mouseCursor', mouseCursor,
        defaultValue: MouseCursor.defer));
  }
}

enum _HighlightType {
  pressed,
  hover,
  focus,
}

class _ListTileBackgroundState extends State<_ListTileBackgroundStateWidget> {
  bool _hovering = false;
  late Map<Type, Action<Intent>> _actionMap;
  Color? _highlightColor;

  void _handleAction(ActivateIntent intent) {
    _handleTap(context);
  }

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _handleAction),
    };
    FocusManager.instance
        .addHighlightModeListener(_handleFocusHighlightModeChange);
  }

  @override
  void didUpdateWidget(_ListTileBackgroundStateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isWidgetEnabled(widget) != _isWidgetEnabled(oldWidget)) {
      _handleHoverChange(_hovering);
      _updateFocusHighlights();
    }
  }

  @override
  void dispose() {
    FocusManager.instance
        .removeHighlightModeListener(_handleFocusHighlightModeChange);
    super.dispose();
  }

  Color? getHighlightColorForType(_HighlightType type) {
    switch (type) {
      case _HighlightType.pressed:
        return widget.pressColor;
      case _HighlightType.focus:
        return widget.focusColor;
      case _HighlightType.hover:
        return widget.hoverColor;
    }
  }

  Duration? getFadeDurationForType(_HighlightType type) {
    switch (type) {
      case _HighlightType.pressed:
        return const Duration(milliseconds: 200);
      case _HighlightType.hover:
      case _HighlightType.focus:
        return const Duration(milliseconds: 50);
    }
  }

  void updateHighlight(_HighlightType type, {required bool? value}) {
    switch (type) {
      case _HighlightType.pressed:
        if (widget.onHighlightChanged != null)
          widget.onHighlightChanged!(value);
        break;
      case _HighlightType.hover:
        if (widget.onHover != null) widget.onHover!(value);
        break;
      case _HighlightType.focus:
        break;
    }
    _setHighlightColor(value! ? getHighlightColorForType(type) : null);
  }

  void _setHighlightColor(Color? color) {
    setState(() {
      _highlightColor = color;
    });
  }

  void _handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      _updateFocusHighlights();
    });
  }

  bool? get _shouldShowFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ??
        NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return enabled && _hasFocus;
      case NavigationMode.directional:
        return _hasFocus;
    }
  }

  void _updateFocusHighlights() {
    bool? showFocus;
    switch (FocusManager.instance.highlightMode) {
      case FocusHighlightMode.touch:
        showFocus = false;
        break;
      case FocusHighlightMode.traditional:
        showFocus = _shouldShowFocus;
        break;
    }
    updateHighlight(_HighlightType.focus, value: showFocus);
  }

  bool _hasFocus = false;
  void _handleFocusUpdate(bool hasFocus) {
    _hasFocus = hasFocus;
    _updateFocusHighlights();
    if (widget.onFocusChange != null) {
      widget.onFocusChange!(hasFocus);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    updateHighlight(_HighlightType.pressed, value: true);
    if (widget.onTapDown != null) {
      widget.onTapDown!(details);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (enabled && _hovering) {
      updateHighlight(_HighlightType.hover, value: enabled);
    } else {
      updateHighlight(_HighlightType.pressed, value: false);
    }
  }

  void _handleTap(BuildContext context) {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTapCancel != null) {
      widget.onTapCancel!();
    }
    updateHighlight(_HighlightType.pressed, value: false);
  }

  void _handleDoubleTap() {
    if (widget.onDoubleTap != null) widget.onDoubleTap!();
  }

  void _handleLongPress(BuildContext context) {
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    }
  }

  bool _isWidgetEnabled(_ListTileBackgroundStateWidget widget) {
    return widget.onTap != null ||
        widget.onDoubleTap != null ||
        widget.onLongPress != null;
  }

  bool get enabled => _isWidgetEnabled(widget);

  void _handleMouseEnter(PointerEnterEvent event) => _handleHoverChange(true);
  void _handleMouseExit(PointerExitEvent event) => _handleHoverChange(false);
  void _handleHoverChange(bool hovering) {
    if (_hovering != hovering) {
      _hovering = hovering;
      updateHighlight(_HighlightType.hover, value: enabled && _hovering);
    }
  }

  bool? get _canRequestFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ??
        NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return enabled && widget.canRequestFocus;
      case NavigationMode.directional:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.debugCheckContext!(context));
    return Actions(
      actions: _actionMap,
      child: Focus(
        focusNode: widget.focusNode,
        canRequestFocus: _canRequestFocus,
        onFocusChange: _handleFocusUpdate,
        autofocus: widget.autofocus,
        child: MouseRegion(
          cursor: widget.mouseCursor,
          onEnter: enabled ? _handleMouseEnter : null,
          onExit: enabled ? _handleMouseExit : null,
          child: GestureDetector(
            onTapDown: enabled ? _handleTapDown : null,
            onTapUp: enabled ? _handleTapUp : null,
            onTap: enabled ? () => _handleTap(context) : null,
            onTapCancel: enabled ? _handleTapCancel : null,
            onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
            onLongPress: widget.onLongPress != null
                ? () => _handleLongPress(context)
                : null,
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: widget.excludeFromSemantics,
            child: Container(
              child: widget.child,
              decoration: BoxDecoration(
                color: _highlightColor,
                border: widget.customBorder as BoxBorder?,
                borderRadius: widget.borderRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single fixed-height row that typically contains some text as well as
/// a leading or trailing icon.
///
/// See [ListTile] for more details.
class CupertinoListTile extends StatelessWidget {
  /// Creates a list tile.
  const CupertinoListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.dense,
    this.contentPadding,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.mouseCursor,
    this.selected = false,
    this.border,
    this.pressColor = CupertinoColors.systemFill,
    this.focusColor,
    this.hoverColor,
    this.focusNode,
    this.autofocus = false,
  })  : assert(!isThreeLine || subtitle != null),
        super(key: key);

  /// See [ListTile.leading].
  final Widget? leading;

  /// See [ListTile.title].
  final Widget? title;

  /// See [ListTile.subtitle].
  final Widget? subtitle;

  /// See [ListTile.trailing].
  final Widget? trailing;

  /// See [ListTile.isThreeLine].
  final bool isThreeLine;

  /// See [ListTile.dense].
  final bool? dense;

  /// See [ListTile.contentPadding].
  final EdgeInsetsGeometry? contentPadding;

  /// See [ListTile.enabled].
  final bool enabled;

  /// See [ListTile.onTap].
  final GestureTapCallback? onTap;

  /// See [ListTile.onLongPress].
  final GestureLongPressCallback? onLongPress;

  /// See [ListTile.mouseCursor].
  final MouseCursor? mouseCursor;

  /// See [ListTile.selected].
  final bool selected;

  /// The border of the list tile.
  final ShapeBorder? border;

  /// The color for the tile's background when it is pressed.
  final Color pressColor;

  /// See [ListTile.focusColor].
  final Color? focusColor;

  /// See [ListTile.hoverColor].
  final Color? hoverColor;

  /// See [ListTile.focusNode].
  final FocusNode? focusNode;

  /// See [ListTile.autofocus].
  final bool autofocus;

  Color? _iconColor(
      BuildContext context, CupertinoThemeData theme, ListTileTheme tileTheme) {
    if (!enabled)
      return CupertinoDynamicColor.resolve(
          CupertinoColors.placeholderText, context);

    if (selected && tileTheme.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme.iconColor != null) return tileTheme.iconColor;

    if (selected) return theme.primaryColor;

    return null;
  }

  Color? _textColor(BuildContext context, CupertinoThemeData theme,
      ListTileTheme tileTheme, Color? defaultColor) {
    if (!enabled)
      return CupertinoDynamicColor.resolve(
          CupertinoColors.placeholderText, context);

    if (selected && tileTheme.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme.textColor != null) return tileTheme.textColor;

    if (selected) return theme.primaryColor;

    return defaultColor;
  }

  bool _isDenseLayout(ListTileTheme tileTheme) {
    return dense ?? tileTheme.dense;
  }

  TextStyle _titleTextStyle(
      BuildContext context, CupertinoThemeData theme, ListTileTheme tileTheme) {
    TextStyle style = theme.textTheme.textStyle;
    final Color? color = _textColor(context, theme, tileTheme, style.color);
    return _isDenseLayout(tileTheme)
        ? style.copyWith(fontSize: 13.0, color: color)
        : style.copyWith(color: color);
  }

  TextStyle _subtitleTextStyle(
      BuildContext context, CupertinoThemeData theme, ListTileTheme tileTheme) {
    final TextStyle style = theme.textTheme.tabLabelTextStyle;
    final Color? color =
        _textColor(context, theme, tileTheme, theme.textTheme.textStyle.color);
    return _isDenseLayout(tileTheme)
        ? style.copyWith(color: color, fontSize: 12.0)
        : style.copyWith(color: color);
  }

  @override
  Widget build(BuildContext context) {
    final CupertinoThemeData theme = CupertinoTheme.of(context);
    final ListTileTheme tileTheme = ListTileTheme.of(context);

    late IconThemeData iconThemeData;
    if (leading != null || trailing != null)
      iconThemeData =
          IconThemeData(color: _iconColor(context, theme, tileTheme));

    Widget? leadingIcon;
    if (leading != null) {
      leadingIcon = IconTheme.merge(
        data: iconThemeData,
        child: leading!,
      );
    }

    final TextStyle titleStyle = _titleTextStyle(context, theme, tileTheme);
    final Widget titleText = DefaultTextStyle(
      style: titleStyle,
      child: title ?? const SizedBox(),
    );

    Widget? subtitleText;
    TextStyle? subtitleStyle;
    if (subtitle != null) {
      subtitleStyle = _subtitleTextStyle(context, theme, tileTheme);
      subtitleText = DefaultTextStyle(
        style: subtitleStyle,
        child: subtitle!,
      );
    }

    Widget trailingIcon;
    if (trailing != null) {
      trailingIcon = IconTheme.merge(
        data: iconThemeData,
        child: trailing!,
      );
    } else {
      trailingIcon = Icon(CupertinoIcons.right_chevron,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.separator, context));
    }

    const EdgeInsets _defaultContentPadding =
        EdgeInsets.symmetric(horizontal: 16.0);
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsets resolvedContentPadding =
        contentPadding?.resolve(textDirection) ??
            tileTheme.contentPadding?.resolve(textDirection) ??
            _defaultContentPadding;

    final MouseCursor effectiveMouseCursor =
        MaterialStateProperty.resolveAs<MouseCursor>(
      mouseCursor ?? MaterialStateMouseCursor.clickable,
      <MaterialState>{
        if (!enabled) MaterialState.disabled,
        if (selected) MaterialState.selected,
      },
    );

    Widget? separator;
    if (border == null) {
      separator = Container(
        height: 1,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.separator, context),
            ),
          ),
        ),
      );
    }

    return ListTileBackground(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      mouseCursor: effectiveMouseCursor,
      canRequestFocus: enabled,
      focusNode: focusNode,
      pressColor: CupertinoDynamicColor.resolve(pressColor, context),
      focusColor: CupertinoDynamicColor.maybeResolve(focusColor, context),
      hoverColor: CupertinoDynamicColor.maybeResolve(hoverColor, context),
      autofocus: autofocus,
      customBorder: border,
      child: Semantics(
        selected: selected,
        enabled: enabled,
        child: SafeArea(
          top: false,
          bottom: false,
          minimum: resolvedContentPadding,
          child: _ListTile(
            separator: separator,
            leading: leadingIcon,
            title: titleText,
            subtitle: subtitleText,
            trailing: trailingIcon,
            isDense: _isDenseLayout(tileTheme),
            isThreeLine: isThreeLine,
            textDirection: textDirection,
            titleBaselineType:
                titleStyle.textBaseline ?? TextBaseline.alphabetic,
            subtitleBaselineType:
                subtitleStyle?.textBaseline ?? TextBaseline.alphabetic,
            padding: resolvedContentPadding,
          ),
        ),
      ),
    );
  }
}

// Identifies the children of a _ListTileElement.
enum _ListTileSlot {
  separator,
  leading,
  title,
  subtitle,
  trailing,
}

class _ListTile extends RenderObjectWidget {
  const _ListTile({
    Key? key,
    this.separator,
    this.leading,
    required this.title,
    this.subtitle,
    this.subtitleBaselineType,
    this.trailing,
    required this.isThreeLine,
    required this.isDense,
    required this.textDirection,
    required this.titleBaselineType,
    required this.padding,
  }) : super(key: key);

  final Widget? separator;
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool isThreeLine;
  final bool isDense;
  final TextDirection textDirection;
  final TextBaseline titleBaselineType;
  final TextBaseline? subtitleBaselineType;
  final EdgeInsets padding;

  @override
  _ListTileElement createElement() => _ListTileElement(this);

  @override
  _RenderListTile createRenderObject(BuildContext context) {
    return _RenderListTile(
      padding: padding,
      isThreeLine: isThreeLine,
      isDense: isDense,
      textDirection: textDirection,
      titleBaselineType: titleBaselineType,
      subtitleBaselineType: subtitleBaselineType,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderListTile renderObject) {
    renderObject
      ..isThreeLine = isThreeLine
      ..isDense = isDense
      ..textDirection = textDirection
      ..titleBaselineType = titleBaselineType
      ..subtitleBaselineType = subtitleBaselineType;
  }
}

class _ListTileElement extends RenderObjectElement {
  _ListTileElement(_ListTile widget) : super(widget);

  final Map<_ListTileSlot, Element> slotToChild = <_ListTileSlot, Element>{};
  final Map<Element, _ListTileSlot> childToSlot = <Element, _ListTileSlot>{};

  @override
  _ListTile get widget => super.widget as _ListTile;

  @override
  _RenderListTile get renderObject => super.renderObject as _RenderListTile;

  @override
  void visitChildren(ElementVisitor visitor) {
    slotToChild.values.forEach(visitor);
  }

  @override
  void forgetChild(Element child) {
    assert(slotToChild.values.contains(child));
    assert(childToSlot.keys.contains(child));
    final _ListTileSlot? slot = childToSlot[child];
    childToSlot.remove(child);
    slotToChild.remove(slot);
    super.forgetChild(child);
  }

  void _mountChild(Widget? widget, _ListTileSlot slot) {
    final Element? oldChild = slotToChild[slot];
    final Element? newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      slotToChild.remove(slot);
      childToSlot.remove(oldChild);
    }
    if (newChild != null) {
      slotToChild[slot] = newChild;
      childToSlot[newChild] = slot;
    }
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _mountChild(widget.separator, _ListTileSlot.separator);
    _mountChild(widget.leading, _ListTileSlot.leading);
    _mountChild(widget.title, _ListTileSlot.title);
    _mountChild(widget.subtitle, _ListTileSlot.subtitle);
    _mountChild(widget.trailing, _ListTileSlot.trailing);
  }

  void _updateChild(Widget? widget, _ListTileSlot slot) {
    final Element? oldChild = slotToChild[slot];
    final Element? newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      childToSlot.remove(oldChild);
      slotToChild.remove(slot);
    }
    if (newChild != null) {
      slotToChild[slot] = newChild;
      childToSlot[newChild] = slot;
    }
  }

  @override
  void update(_ListTile newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _updateChild(widget.separator, _ListTileSlot.separator);
    _updateChild(widget.leading, _ListTileSlot.leading);
    _updateChild(widget.title, _ListTileSlot.title);
    _updateChild(widget.subtitle, _ListTileSlot.subtitle);
    _updateChild(widget.trailing, _ListTileSlot.trailing);
  }

  void _updateRenderObject(RenderBox? child, _ListTileSlot? slot) {
    switch (slot) {
      case _ListTileSlot.separator:
        renderObject.separator = child;
        break;
      case _ListTileSlot.leading:
        renderObject.leading = child;
        break;
      case _ListTileSlot.title:
        renderObject.title = child;
        break;
      case _ListTileSlot.subtitle:
        renderObject.subtitle = child;
        break;
      case _ListTileSlot.trailing:
        renderObject.trailing = child;
        break;
      case null:
        break;
    }
  }

  @override
  void insertRenderObjectChild(RenderObject child, dynamic slotValue) {
    assert(child is RenderBox);
    assert(slotValue is _ListTileSlot);
    final _ListTileSlot? slot = slotValue as _ListTileSlot?;
    _updateRenderObject(child as RenderBox, slot);
    assert(renderObject.childToSlot.keys.contains(child));
    assert(renderObject.slotToChild.keys.contains(slot));
  }

  @override
  void removeRenderObjectChild(RenderObject child, dynamic slot) {
    assert(child is RenderBox);
    assert(renderObject.childToSlot.keys.contains(child));
    _updateRenderObject(null, renderObject.childToSlot[child as RenderBox]);
    assert(!renderObject.childToSlot.keys.contains(child));
    assert(!renderObject.slotToChild.keys.contains(slot));
  }
}

class _RenderListTile extends RenderBox {
  _RenderListTile({
    required EdgeInsets padding,
    required bool isDense,
    required bool isThreeLine,
    required TextDirection textDirection,
    required TextBaseline titleBaselineType,
    TextBaseline? subtitleBaselineType,
  })  : _padding = padding,
        _isDense = isDense,
        _isThreeLine = isThreeLine,
        _textDirection = textDirection,
        _titleBaselineType = titleBaselineType,
        _subtitleBaselineType = subtitleBaselineType;

  static const double _minLeadingWidth = 40.0;
  // The horizontal gap between the titles and the leading/trailing widgets
  double get _horizontalTitleGap => 16.0;
  // The minimum padding on the top and bottom of the title and subtitle widgets.
  static const double _minVerticalPadding = 4.0;

  final Map<_ListTileSlot, RenderBox> slotToChild =
      <_ListTileSlot, RenderBox>{};
  final Map<RenderBox, _ListTileSlot> childToSlot =
      <RenderBox, _ListTileSlot>{};

  RenderBox? _updateChild(
      RenderBox? oldChild, RenderBox? newChild, _ListTileSlot slot) {
    if (oldChild != null) {
      dropChild(oldChild);
      childToSlot.remove(oldChild);
      slotToChild.remove(slot);
    }
    if (newChild != null) {
      childToSlot[newChild] = slot;
      slotToChild[slot] = newChild;
      adoptChild(newChild);
    }
    return newChild;
  }

  RenderBox? _separator;
  RenderBox? get separator => _separator;
  set separator(RenderBox? value) {
    _separator = _updateChild(_separator, value, _ListTileSlot.separator);
  }

  RenderBox? _leading;
  RenderBox? get leading => _leading;
  set leading(RenderBox? value) {
    _leading = _updateChild(_leading, value, _ListTileSlot.leading);
  }

  RenderBox? _title;
  RenderBox? get title => _title;
  set title(RenderBox? value) {
    _title = _updateChild(_title, value, _ListTileSlot.title);
  }

  RenderBox? _subtitle;
  RenderBox? get subtitle => _subtitle;
  set subtitle(RenderBox? value) {
    _subtitle = _updateChild(_subtitle, value, _ListTileSlot.subtitle);
  }

  RenderBox? _trailing;
  RenderBox? get trailing => _trailing;
  set trailing(RenderBox? value) {
    _trailing = _updateChild(_trailing, value, _ListTileSlot.trailing);
  }

  // The returned list is ordered for hit testing.
  Iterable<RenderBox> get _children sync* {
    if (separator != null) yield separator!;
    if (leading != null) yield leading!;
    if (title != null) yield title!;
    if (subtitle != null) yield subtitle!;
    if (trailing != null) yield trailing!;
  }

  EdgeInsets get padding => _padding;
  EdgeInsets _padding;
  set padding(EdgeInsets value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  bool get isDense => _isDense;
  bool _isDense;
  set isDense(bool value) {
    if (_isDense == value) return;
    _isDense = value;
    markNeedsLayout();
  }

  bool get isThreeLine => _isThreeLine;
  bool _isThreeLine;
  set isThreeLine(bool value) {
    if (_isThreeLine == value) return;
    _isThreeLine = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  TextBaseline get titleBaselineType => _titleBaselineType;
  TextBaseline _titleBaselineType;
  set titleBaselineType(TextBaseline value) {
    if (_titleBaselineType == value) return;
    _titleBaselineType = value;
    markNeedsLayout();
  }

  TextBaseline? get subtitleBaselineType => _subtitleBaselineType;
  TextBaseline? _subtitleBaselineType;
  set subtitleBaselineType(TextBaseline? value) {
    if (_subtitleBaselineType == value) return;
    _subtitleBaselineType = value;
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (final RenderBox child in _children) child.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    for (final RenderBox child in _children) child.detach();
  }

  @override
  void redepthChildren() {
    _children.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    _children.forEach(visitor);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> value = <DiagnosticsNode>[];
    void add(RenderBox? child, String name) {
      if (child != null) value.add(child.toDiagnosticsNode(name: name));
    }

    add(separator, 'separator');
    add(leading, 'leading');
    add(title, 'title');
    add(subtitle, 'subtitle');
    add(trailing, 'trailing');
    return value;
  }

  @override
  bool get sizedByParent => false;

  static double _minWidth(RenderBox? box, double height) {
    return box == null ? 0.0 : box.getMinIntrinsicWidth(height);
  }

  static double _maxWidth(RenderBox? box, double height) {
    return box == null ? 0.0 : box.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final double leadingWidth = leading != null
        ? math.max(leading!.getMinIntrinsicWidth(height), _minLeadingWidth) +
            _horizontalTitleGap
        : 0.0;
    return leadingWidth +
        math.max(_minWidth(title, height), _minWidth(subtitle, height)) +
        _maxWidth(trailing, height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final double leadingWidth = leading != null
        ? math.max(leading!.getMaxIntrinsicWidth(height), _minLeadingWidth) +
            _horizontalTitleGap
        : 0.0;
    return leadingWidth +
        math.max(_maxWidth(title, height), _maxWidth(subtitle, height)) +
        _maxWidth(trailing, height);
  }

  double get _defaultTileHeight {
    final bool hasSubtitle = subtitle != null;
    final bool isTwoLine = !isThreeLine && hasSubtitle;
    final bool isOneLine = !isThreeLine && !hasSubtitle;

    if (isOneLine) return (isDense ? 48.0 : 56.0);
    if (isTwoLine) return (isDense ? 64.0 : 72.0);
    return (isDense ? 76.0 : 88.0);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(
      _defaultTileHeight,
      title!.getMinIntrinsicHeight(width) +
          (subtitle?.getMinIntrinsicHeight(width) ?? 0.0),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    assert(title != null);
    final BoxParentData parentData = title!.parentData as BoxParentData;
    return parentData.offset.dy + title!.getDistanceToActualBaseline(baseline)!;
  }

  static double? _boxBaseline(RenderBox box, TextBaseline baseline) {
    return box.getDistanceToBaseline(baseline);
  }

  static Size _layoutBox(RenderBox? box, BoxConstraints constraints) {
    if (box == null) return Size.zero;
    box.layout(constraints, parentUsesSize: true);
    return box.size;
  }

  static void _positionBox(RenderBox box, Offset offset) {
    final BoxParentData parentData = box.parentData as BoxParentData;
    parentData.offset = offset;
  }

  // All of the dimensions below were taken from the Material Design spec:
  // https://material.io/design/components/lists.html#specs
  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final bool hasSeparator = separator != null;
    final bool hasLeading = leading != null;
    final bool hasSubtitle = subtitle != null;
    final bool hasTrailing = trailing != null;
    final bool isTwoLine = !isThreeLine && hasSubtitle;
    final bool isOneLine = !isThreeLine && !hasSubtitle;

    final BoxConstraints maxIconHeightConstraint = BoxConstraints(
      // One-line trailing and leading widget heights do not follow
      // Material specifications, but this sizing is required to adhere
      // to accessibility requirements for smallest tappable widget.
      // Two- and three-line trailing widget heights are constrained
      // properly according to the Material spec.
      maxHeight: (isDense ? 48.0 : 56.0),
    );
    final BoxConstraints looseConstraints = constraints.loosen();
    final BoxConstraints iconConstraints =
        looseConstraints.enforce(maxIconHeightConstraint);

    final double tileWidth = looseConstraints.maxWidth;
    final Size leadingSize = _layoutBox(leading, iconConstraints);
    final Size trailingSize = _layoutBox(trailing, iconConstraints);
    assert(tileWidth != leadingSize.width,
        'Leading widget consumes entire tile width. Please use a sized widget.');
    assert(tileWidth != trailingSize.width,
        'Trailing widget consumes entire tile width. Please use a sized widget.');

    final double titleStart = hasLeading
        ? math.max(_minLeadingWidth, leadingSize.width) + _horizontalTitleGap
        : 0.0;
    final double adjustedTrailingWidth = hasTrailing
        ? math.max(trailingSize.width + _horizontalTitleGap, 32.0)
        : 0.0;
    final BoxConstraints textConstraints = looseConstraints.tighten(
      width: tileWidth - titleStart - adjustedTrailingWidth,
    );
    final Size titleSize = _layoutBox(title, textConstraints);
    final Size subtitleSize = _layoutBox(subtitle, textConstraints);

    final BoxConstraints separatorConstraints = constraints.enforce(
      BoxConstraints(
        minWidth: tileWidth -
            titleStart +
            (textDirection == TextDirection.ltr
                ? _padding.horizontal
                : _padding.horizontal),
        maxHeight: 1,
      ),
    );
    // ignore: unused_local_variable
    final Size separatorSize = _layoutBox(separator, separatorConstraints);

    late double titleBaseline;
    late double subtitleBaseline;
    if (isTwoLine) {
      titleBaseline = isDense ? 28.0 : 32.0;
      subtitleBaseline = isDense ? 48.0 : 52.0;
    } else if (isThreeLine) {
      titleBaseline = isDense ? 22.0 : 28.0;
      subtitleBaseline = isDense ? 42.0 : 48.0;
    } else {
      assert(isOneLine);
    }

    final double defaultTileHeight = _defaultTileHeight;

    double tileHeight;
    double titleY;
    late double subtitleY;
    if (!hasSubtitle) {
      tileHeight = math.max(
          defaultTileHeight, titleSize.height + 2.0 * _minVerticalPadding);
      titleY = (tileHeight - titleSize.height) / 2.0;
    } else {
      assert(subtitleBaselineType != null);
      titleY = titleBaseline - _boxBaseline(title!, titleBaselineType)!;
      subtitleY =
          subtitleBaseline - _boxBaseline(subtitle!, subtitleBaselineType!)!;
      tileHeight = defaultTileHeight;

      // If the title and subtitle overlap, move the title upwards by half
      // the overlap and the subtitle down by the same amount, and adjust
      // tileHeight so that both titles fit.
      final double titleOverlap = titleY + titleSize.height - subtitleY;
      if (titleOverlap > 0.0) {
        titleY -= titleOverlap / 2.0;
        subtitleY += titleOverlap / 2.0;
      }

      // If the title or subtitle overflow tileHeight then punt: title
      // and subtitle are arranged in a column, tileHeight = column height plus
      // _minVerticalPadding on top and bottom.
      if (titleY < _minVerticalPadding ||
          (subtitleY + subtitleSize.height + _minVerticalPadding) >
              tileHeight) {
        tileHeight =
            titleSize.height + subtitleSize.height + 2.0 * _minVerticalPadding;
        titleY = _minVerticalPadding;
        subtitleY = titleSize.height + _minVerticalPadding;
      }
    }

    // This attempts to implement the redlines for the vertical position of the
    // leading and trailing icons on the spec page:
    //   https://material.io/design/components/lists.html#specs
    // The interpretation for these redlines is as follows:
    //  - For large tiles (> 72dp), both leading and trailing controls should be
    //    a fixed distance from top. As per guidelines this is set to 16dp.
    //  - For smaller tiles, trailing should always be centered. Leading can be
    //    centered or closer to the top. It should never be further than 16dp
    //    to the top.
    double leadingY;
    double trailingY;
    if (tileHeight > 72.0) {
      leadingY = 16.0;
      trailingY = 16.0;
    } else {
      leadingY = math.min((tileHeight - leadingSize.height) / 2.0, 16.0);
      trailingY = (tileHeight - trailingSize.height) / 2.0;
    }
    final separatorY = tileHeight + _padding.bottom;

    switch (textDirection) {
      case TextDirection.rtl:
        {
          if (hasSeparator) _positionBox(separator!, Offset(0.0, separatorY));
          if (hasLeading)
            _positionBox(
                leading!, Offset(tileWidth - leadingSize.width, leadingY));
          _positionBox(title!, Offset(adjustedTrailingWidth, titleY));
          if (hasSubtitle)
            _positionBox(subtitle!, Offset(adjustedTrailingWidth, subtitleY));
          if (hasTrailing) _positionBox(trailing!, Offset(0.0, trailingY));
          break;
        }
      case TextDirection.ltr:
        {
          if (hasSeparator)
            _positionBox(separator!, Offset(titleStart, separatorY));
          if (hasLeading) _positionBox(leading!, Offset(0.0, leadingY));
          _positionBox(title!, Offset(titleStart, titleY));
          if (hasSubtitle)
            _positionBox(subtitle!, Offset(titleStart, subtitleY));
          if (hasTrailing)
            _positionBox(
                trailing!, Offset(tileWidth - trailingSize.width, trailingY));
          break;
        }
    }

    size = constraints.constrain(Size(tileWidth, tileHeight));
    assert(size.width == constraints.constrainWidth(tileWidth));
    assert(size.height == constraints.constrainHeight(tileHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void doPaint(RenderBox? child) {
      if (child != null) {
        final BoxParentData parentData = child.parentData as BoxParentData;
        context.paintChild(child, parentData.offset + offset);
      }
    }

    doPaint(separator);
    doPaint(leading);
    doPaint(title);
    doPaint(subtitle);
    doPaint(trailing);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final RenderBox child in _children) {
      final BoxParentData parentData = child.parentData as BoxParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - parentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) return true;
    }
    return false;
  }
}