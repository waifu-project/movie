import 'package:collection/collection.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './src/utils.dart';

import 'html_parser.dart';
import 'src/interactable_element.dart';
import 'src/layout_element.dart';
import 'src/replaced_element.dart';
import 'src/styled_element.dart';
import 'style.dart';

typedef CustomRenderMatcher = bool Function(RenderContext context);

CustomRenderMatcher tagMatcher(String tag) => (context) {
      return context.tree.element?.localName == tag;
    };

CustomRenderMatcher blockElementMatcher() => (context) {
      return context.tree.style.display == Display.BLOCK &&
          (context.tree.children.isNotEmpty ||
              context.tree.element?.localName == "hr");
    };

CustomRenderMatcher listElementMatcher() => (context) {
      return context.tree.style.display == Display.LIST_ITEM;
    };

CustomRenderMatcher replacedElementMatcher() => (context) {
      return context.tree is ReplacedElement;
    };

CustomRenderMatcher dataUriMatcher(
        {String? encoding = 'base64', String? mime}) =>
    (context) {
      if (context.tree.element?.attributes == null ||
          _src(context.tree.element!.attributes.cast()) == null) {
        return false;
      }
      final dataUri = _dataUriFormat
          .firstMatch(_src(context.tree.element!.attributes.cast())!);
      return dataUri != null &&
          dataUri.namedGroup('mime') != "image/svg+xml" &&
          (mime == null || dataUri.namedGroup('mime') == mime) &&
          (encoding == null || dataUri.namedGroup('encoding') == ';$encoding');
    };

CustomRenderMatcher networkSourceMatcher({
  List<String> schemas = const ["https", "http"],
  List<String>? domains,
  String? extension,
}) =>
    (context) {
      if (context.tree.element?.attributes.cast() == null ||
          _src(context.tree.element!.attributes.cast()) == null) {
        return false;
      }
      try {
        final src = Uri.parse(_src(context.tree.element!.attributes.cast())!);
        return schemas.contains(src.scheme) &&
            (domains == null || domains.contains(src.host)) &&
            (extension == null || src.path.endsWith(".$extension"));
      } catch (e) {
        return false;
      }
    };

CustomRenderMatcher assetUriMatcher() => (context) =>
    context.tree.element?.attributes.cast() != null &&
    _src(context.tree.element!.attributes.cast()) != null &&
    _src(context.tree.element!.attributes.cast())!.startsWith("asset:") &&
    !_src(context.tree.element!.attributes.cast())!.endsWith(".svg");

CustomRenderMatcher textContentElementMatcher() => (context) {
      return context.tree is TextContentElement;
    };

CustomRenderMatcher interactableElementMatcher() => (context) {
      return context.tree is InteractableElement;
    };

CustomRenderMatcher layoutElementMatcher() => (context) {
      return context.tree is LayoutElement;
    };

CustomRenderMatcher verticalAlignMatcher() => (context) {
      return context.tree.style.verticalAlign != null &&
          context.tree.style.verticalAlign != VerticalAlign.BASELINE;
    };

CustomRenderMatcher fallbackMatcher() => (context) {
      return true;
    };

class CustomRender {
  final InlineSpan Function(RenderContext, List<InlineSpan> Function())?
      inlineSpan;
  final Widget Function(RenderContext, List<InlineSpan> Function())? widget;

  CustomRender.inlineSpan({
    required this.inlineSpan,
  }) : widget = null;

  CustomRender.widget({
    required this.widget,
  }) : inlineSpan = null;
}

class SelectableCustomRender extends CustomRender {
  final TextSpan Function(RenderContext, List<TextSpan> Function()) textSpan;

  SelectableCustomRender.fromTextSpan({
    required this.textSpan,
  }) : super.inlineSpan(inlineSpan: null);
}

CustomRender blockElementRender({Style? style, List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(inlineSpan: (context, buildChildren) {
      if (context.parser.selectable) {
        return TextSpan(
          style: context.style.generateTextStyle(),
          children: (children as List<TextSpan>?) ??
              context.tree.children
                  .expandIndexed((i, childTree) => [
                        if (childTree.style.display == Display.BLOCK &&
                            i > 0 &&
                            context.tree.children[i - 1] is ReplacedElement)
                          const TextSpan(text: "\n"),
                        context.parser.parseTree(context, childTree),
                        if (i != context.tree.children.length - 1 &&
                            childTree.style.display == Display.BLOCK &&
                            childTree.element?.localName != "html" &&
                            childTree.element?.localName != "body")
                          const TextSpan(text: "\n"),
                      ])
                  .toList(),
        );
      }
      return WidgetSpan(
          child: ContainerSpan(
        parseKey: context.key,
        newContext: context,
        style: style ?? context.tree.style,
        shrinkWrap: context.parser.shrinkWrap,
        children: children ??
            context.tree.children
                .expandIndexed((i, childTree) => [
                      if (context.parser.shrinkWrap &&
                          childTree.style.display == Display.BLOCK &&
                          i > 0 &&
                          context.tree.children[i - 1] is ReplacedElement)
                        const TextSpan(text: "\n"),
                      context.parser.parseTree(context, childTree),
                      if (i != context.tree.children.length - 1 &&
                          childTree.style.display == Display.BLOCK &&
                          childTree.element?.localName != "html" &&
                          childTree.element?.localName != "body")
                        const TextSpan(text: "\n"),
                    ])
                .toList(),
      ));
    });

CustomRender listElementRender(
        {Style? style, Widget? child, List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => WidgetSpan(
              child: ContainerSpan(
                parseKey: context.key,
                newContext: context,
                style: style ?? context.tree.style,
                shrinkWrap: context.parser.shrinkWrap,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  textDirection:
                      style?.direction ?? context.tree.style.direction,
                  children: [
                    (style?.listStylePosition ??
                                context.tree.style.listStylePosition) ==
                            ListStylePosition.OUTSIDE
                        ? Padding(
                            padding: style?.padding?.nonNegative ??
                                context.tree.style.padding?.nonNegative ??
                                EdgeInsets.only(
                                    left: (style?.direction ??
                                                context.tree.style.direction) !=
                                            TextDirection.rtl
                                        ? 10.0
                                        : 0.0,
                                    right: (style?.direction ??
                                                context.tree.style.direction) ==
                                            TextDirection.rtl
                                        ? 10.0
                                        : 0.0),
                            child: style?.markerContent ??
                                context.style.markerContent)
                        : const SizedBox(height: 0, width: 0),
                    const Text("\u0020",
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.w400)),
                    Expanded(
                        child: Padding(
                            padding: (style?.listStylePosition ??
                                        context.tree.style.listStylePosition) ==
                                    ListStylePosition.INSIDE
                                ? EdgeInsets.only(
                                    left: (style?.direction ??
                                                context.tree.style.direction) !=
                                            TextDirection.rtl
                                        ? 10.0
                                        : 0.0,
                                    right: (style?.direction ??
                                                context.tree.style.direction) ==
                                            TextDirection.rtl
                                        ? 10.0
                                        : 0.0)
                                : EdgeInsets.zero,
                            child: StyledText(
                              textSpan: TextSpan(
                                children: _getListElementChildren(
                                    style?.listStylePosition ??
                                        context.tree.style.listStylePosition,
                                    buildChildren)
                                  ..insertAll(
                                      0,
                                      context.tree.style.listStylePosition ==
                                              ListStylePosition.INSIDE
                                          ? [
                                              WidgetSpan(
                                                  alignment:
                                                      PlaceholderAlignment
                                                          .middle,
                                                  child: style?.markerContent ??
                                                      context.style
                                                          .markerContent ??
                                                      const SizedBox(
                                                          height: 0, width: 0))
                                            ]
                                          : []),
                                style: style?.generateTextStyle() ??
                                    context.style.generateTextStyle(),
                              ),
                              style: style ?? context.style,
                              renderContext: context,
                            )))
                  ],
                ),
              ),
            ));

CustomRender replacedElementRender(
        {PlaceholderAlignment? alignment,
        TextBaseline? baseline,
        Widget? child}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => WidgetSpan(
              alignment:
                  alignment ?? (context.tree as ReplacedElement).alignment,
              baseline: baseline ?? TextBaseline.alphabetic,
              child:
                  child ?? (context.tree as ReplacedElement).toWidget(context)!,
            ));

CustomRender textContentElementRender({String? text}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => TextSpan(
              style: context.style.generateTextStyle(),
              text: (text ?? (context.tree as TextContentElement).text)
                  ?.transformed(context.tree.style.textTransform),
            ));

CustomRender base64ImageRender() =>
    CustomRender.widget(widget: (context, buildChildren) {
      final decodedImage = base64.decode(
          _src(context.tree.element!.attributes.cast())!
              .split("base64,")[1]
              .trim());
      precacheImage(
        MemoryImage(decodedImage),
        context.buildContext,
        onError: (exception, StackTrace? stackTrace) {
          context.parser.onImageError?.call(exception, stackTrace);
        },
      );
      final widget = Image.memory(
        decodedImage,
        frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            return Text(_alt(context.tree.element!.attributes.cast()) ?? "",
                style: context.style.generateTextStyle());
          }
          return child;
        },
      );
      return Builder(
          key: context.key,
          builder: (buildContext) {
            return GestureDetector(
              child: widget,
              onTap: () {
                if (MultipleTapGestureDetector.of(buildContext) != null) {
                  MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
                }
                context.parser.onImageTap?.call(
                    _src(context.tree.element!.attributes.cast())!
                        .split("base64,")[1]
                        .trim(),
                    context,
                    context.tree.element!.attributes.cast(),
                    context.tree.element);
              },
            );
          });
    });

CustomRender assetImageRender({
  double? width,
  double? height,
}) =>
    CustomRender.widget(widget: (context, buildChildren) {
      final assetPath = _src(context.tree.element!.attributes.cast())!
          .replaceFirst('asset:', '');
      final widget = Image.asset(
        assetPath,
        width: width ?? _width(context.tree.element!.attributes.cast()),
        height: height ?? _height(context.tree.element!.attributes.cast()),
        frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            return Text(_alt(context.tree.element!.attributes.cast()) ?? "",
                style: context.style.generateTextStyle());
          }
          return child;
        },
      );
      return Builder(
          key: context.key,
          builder: (buildContext) {
            return GestureDetector(
              child: widget,
              onTap: () {
                if (MultipleTapGestureDetector.of(buildContext) != null) {
                  MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
                }
                context.parser.onImageTap?.call(
                    assetPath,
                    context,
                    context.tree.element!.attributes.cast(),
                    context.tree.element);
              },
            );
          });
    });

CustomRender networkImageRender({
  Map<String, String>? headers,
  String Function(String?)? mapUrl,
  double? width,
  double? height,
  Widget Function(String?)? altWidget,
  Widget Function()? loadingWidget,
}) =>
    CustomRender.widget(widget: (context, buildChildren) {
      final src = mapUrl?.call(_src(context.tree.element!.attributes.cast())) ??
          _src(context.tree.element!.attributes.cast())!;
      Completer<Size> completer = Completer();
      if (context.parser.cachedImageSizes[src] != null) {
        completer.complete(context.parser.cachedImageSizes[src]);
      } else {
        Image image = Image.network(src, frameBuilder: (ctx, child, frame, _) {
          if (frame == null) {
            if (!completer.isCompleted) {
              completer.completeError("error");
            }
            return child;
          } else {
            return child;
          }
        });

        ImageStreamListener? listener;
        listener =
            ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
          var myImage = imageInfo.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          if (!completer.isCompleted) {
            context.parser.cachedImageSizes[src] = size;
            completer.complete(size);
            image.image
                .resolve(const ImageConfiguration())
                .removeListener(listener!);
          }
        }, onError: (object, stacktrace) {
          if (!completer.isCompleted) {
            completer.completeError(object);
            image.image
                .resolve(const ImageConfiguration())
                .removeListener(listener!);
          }
        });

        image.image.resolve(const ImageConfiguration()).addListener(listener);
      }
      final attributes =
          context.tree.element!.attributes.cast<String, String>();
      final widget = FutureBuilder<Size>(
        future: completer.future,
        initialData: context.parser.cachedImageSizes[src],
        builder: (BuildContext buildContext, AsyncSnapshot<Size> snapshot) {
          if (snapshot.hasData) {
            return Container(
              constraints: BoxConstraints(
                  maxWidth: width ?? _width(attributes) ?? snapshot.data!.width,
                  maxHeight:
                      (width ?? _width(attributes) ?? snapshot.data!.width) /
                          _aspectRatio(attributes, snapshot)),
              child: AspectRatio(
                aspectRatio: _aspectRatio(attributes, snapshot),
                child: Image.network(
                  src,
                  headers: headers,
                  width: width ?? _width(attributes) ?? snapshot.data!.width,
                  height: height ?? _height(attributes),
                  frameBuilder: (ctx, child, frame, _) {
                    if (frame == null) {
                      return altWidget?.call(_alt(attributes)) ??
                          Text(_alt(attributes) ?? "",
                              style: context.style.generateTextStyle());
                    }
                    return child;
                  },
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return altWidget
                    ?.call(_alt(context.tree.element!.attributes.cast())) ??
                Text(_alt(context.tree.element!.attributes.cast()) ?? "",
                    style: context.style.generateTextStyle());
          } else {
            return loadingWidget?.call() ?? const CircularProgressIndicator();
          }
        },
      );
      return Builder(
          key: context.key,
          builder: (buildContext) {
            return GestureDetector(
              child: widget,
              onTap: () {
                if (MultipleTapGestureDetector.of(buildContext) != null) {
                  MultipleTapGestureDetector.of(buildContext)!.onTap?.call();
                }
                context.parser.onImageTap?.call(
                    src,
                    context,
                    context.tree.element!.attributes.cast(),
                    context.tree.element);
              },
            );
          });
    });

CustomRender interactableElementRender({List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => TextSpan(
              children: children ??
                  (context.tree as InteractableElement)
                      .children
                      .map((tree) => context.parser.parseTree(context, tree))
                      .map((childSpan) {
                    return _getInteractableChildren(
                        context,
                        context.tree as InteractableElement,
                        childSpan,
                        context.style
                            .generateTextStyle()
                            .merge(childSpan.style));
                  }).toList(),
            ));

CustomRender layoutElementRender({Widget? child}) => CustomRender.inlineSpan(
    inlineSpan: (context, buildChildren) => WidgetSpan(
          child: child ?? (context.tree as LayoutElement).toWidget(context)!,
        ));

CustomRender verticalAlignRender(
        {double? verticalOffset, Style? style, List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => WidgetSpan(
              child: Transform.translate(
                key: context.key,
                offset: Offset(
                    0, verticalOffset ?? _getVerticalOffset(context.tree)),
                child: StyledText(
                  textSpan: TextSpan(
                    style: style?.generateTextStyle() ??
                        context.style.generateTextStyle(),
                    children: children ?? buildChildren.call(),
                  ),
                  style: context.style,
                  renderContext: context,
                ),
              ),
            ));

CustomRender fallbackRender({Style? style, List<InlineSpan>? children}) =>
    CustomRender.inlineSpan(
        inlineSpan: (context, buildChildren) => TextSpan(
              style: style?.generateTextStyle() ??
                  context.style.generateTextStyle(),
              children: context.tree.children
                  .expand((tree) => [
                        context.parser.parseTree(context, tree),
                        if (tree.style.display == Display.BLOCK &&
                            tree.element?.parent?.localName != "th" &&
                            tree.element?.parent?.localName != "td" &&
                            tree.element?.localName != "html" &&
                            tree.element?.localName != "body")
                          const TextSpan(text: "\n"),
                      ])
                  .toList(),
            ));

final Map<CustomRenderMatcher, CustomRender> defaultRenders = {
  blockElementMatcher(): blockElementRender(),
  listElementMatcher(): listElementRender(),
  textContentElementMatcher(): textContentElementRender(),
  dataUriMatcher(): base64ImageRender(),
  assetUriMatcher(): assetImageRender(),
  networkSourceMatcher(): networkImageRender(),
  replacedElementMatcher(): replacedElementRender(),
  interactableElementMatcher(): interactableElementRender(),
  layoutElementMatcher(): layoutElementRender(),
  verticalAlignMatcher(): verticalAlignRender(),
  fallbackMatcher(): fallbackRender(),
};

List<InlineSpan> _getListElementChildren(
    ListStylePosition? position, Function() buildChildren) {
  List<InlineSpan> children = buildChildren.call();
  if (position == ListStylePosition.INSIDE) {
    const tabSpan = WidgetSpan(
      child: Text("\t",
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.w400)),
    );
    children.insert(0, tabSpan);
  }
  return children;
}

InlineSpan _getInteractableChildren(RenderContext context,
    InteractableElement tree, InlineSpan childSpan, TextStyle childStyle) {
  if (childSpan is TextSpan) {
    return TextSpan(
      text: childSpan.text,
      children: childSpan.children
          ?.map((e) => _getInteractableChildren(
              context, tree, e, childStyle.merge(childSpan.style)))
          .toList(),
      style: context.style.generateTextStyle().merge(childSpan.style == null
          ? childStyle
          : childStyle.merge(childSpan.style)),
      semanticsLabel: childSpan.semanticsLabel,
      recognizer: TapGestureRecognizer()
        ..onTap = context.parser.internalOnAnchorTap != null
            ? () => context.parser.internalOnAnchorTap!(
                tree.href, context, tree.attributes, tree.element)
            : null,
    );
  } else {
    return WidgetSpan(
      child: MultipleTapGestureDetector(
        onTap: context.parser.internalOnAnchorTap != null
            ? () => context.parser.internalOnAnchorTap!(
                tree.href, context, tree.attributes, tree.element)
            : null,
        child: GestureDetector(
          key: context.key,
          onTap: context.parser.internalOnAnchorTap != null
              ? () => context.parser.internalOnAnchorTap!(
                  tree.href, context, tree.attributes, tree.element)
              : null,
          child: (childSpan as WidgetSpan).child,
        ),
      ),
    );
  }
}

final _dataUriFormat = RegExp(
    "^(?<scheme>data):(?<mime>image/[\\w+-.]+)(?<encoding>;base64)?,(?<data>.*)");

double _getVerticalOffset(StyledElement tree) {
  switch (tree.style.verticalAlign) {
    case VerticalAlign.SUB:
      return tree.style.fontSize!.size! / 2.5;
    case VerticalAlign.SUPER:
      return tree.style.fontSize!.size! / -2.5;
    default:
      return 0;
  }
}

String? _src(Map<String, String> attributes) {
  return attributes["src"];
}

String? _alt(Map<String, String> attributes) {
  return attributes["alt"];
}

double? _height(Map<String, String> attributes) {
  final heightString = attributes["height"];
  return heightString == null
      ? heightString as double?
      : double.tryParse(heightString);
}

double? _width(Map<String, String> attributes) {
  final widthString = attributes["width"];
  return widthString == null
      ? widthString as double?
      : double.tryParse(widthString);
}

double _aspectRatio(
    Map<String, String> attributes, AsyncSnapshot<Size> calculated) {
  final heightString = attributes["height"];
  final widthString = attributes["width"];
  if (heightString != null && widthString != null) {
    final height = double.tryParse(heightString);
    final width = double.tryParse(widthString);
    return height == null || width == null
        ? calculated.data!.aspectRatio
        : width / height;
  }
  return calculated.data!.aspectRatio;
}

extension ClampedEdgeInsets on EdgeInsetsGeometry {
  EdgeInsetsGeometry get nonNegative =>
      clamp(EdgeInsets.zero, const EdgeInsets.all(double.infinity));
}
