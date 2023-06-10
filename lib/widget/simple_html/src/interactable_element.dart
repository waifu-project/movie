// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import '../style.dart';
import 'styled_element.dart';

/// An [InteractableElement] is a [StyledElement] that takes user gestures (e.g. tap).
class InteractableElement extends StyledElement {
  String? href;

  InteractableElement({
    required String name,
    required List<StyledElement> children,
    required Style style,
    required this.href,
    required dom.Node node,
    required String elementId,
  }) : super(name: name, children: children, style: style, node: node as dom.Element?, elementId: elementId);
}

/// A [Gesture] indicates the type of interaction by a user.
enum Gesture {
  TAP,
}

StyledElement parseInteractableElement(
    dom.Element element, List<StyledElement> children) {
  switch (element.localName) {
    case "a":
      if (element.attributes.containsKey('href')) {
        return InteractableElement(
            name: element.localName!,
            children: children,
            href: element.attributes['href'],
            style: Style(
              color: Colors.blue,
              textDecoration: TextDecoration.underline,
            ),
            node: element,
            elementId: element.id
        );
      }
      // When <a> tag have no href, it must be non clickable and without decoration.
      return StyledElement(
        name: element.localName!,
        children: children,
        style: Style(),
        node: element,
        elementId: element.id,
      );
    /// will never be called, just to suppress missing return warning
    default:
      return InteractableElement(
        name: element.localName!,
        children: children,
        node: element,
        href: '',
        style: Style(),
        elementId: "[[No ID]]"
      );
  }
}
