export 'styled_element.dart';
export 'interactable_element.dart';
export 'replaced_element.dart';

const STYLED_ELEMENTS = [
  "abbr",
  "acronym",
  "address",
  "b",
  "bdi",
  "bdo",
  "big",
  "cite",
  "code",
  "data",
  "del",
  "dfn",
  "em",
  "font",
  "i",
  "ins",
  "kbd",
  "mark",
  "q",
  "rt",
  "s",
  "samp",
  "small",
  "span",
  "strike",
  "strong",
  "sub",
  "sup",
  "time",
  "tt",
  "u",
  "var",
  "wbr",

  //BLOCK ELEMENTS
  "article",
  "aside",
  "blockquote",
  "body",
  "center",
  "dd",
  "div",
  "dl",
  "dt",
  "figcaption",
  "figure",
  "footer",
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "header",
  "hr",
  "html",
  "li",
  "main",
  "nav",
  "noscript",
  "ol",
  "p",
  "pre",
  "section",
  "summary",
  "ul",
];

const BLOCK_ELEMENTS = [
  "article",
  "aside",
  "blockquote",
  "body",
  "center",
  "dd",
  "div",
  "dl",
  "dt",
  "figcaption",
  "figure",
  "footer",
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "header",
  "hr",
  "html",
  "li",
  "main",
  "nav",
  "noscript",
  "ol",
  "p",
  "pre",
  "section",
  "summary",
  "ul",
];

const INTERACTABLE_ELEMENTS = [
  "a",
];

const REPLACED_ELEMENTS = [
  "br",
  "template",
  "rp",
  "rt",
  "ruby",
];

const LAYOUT_ELEMENTS = [
  "details",
  "tr",
  "tbody",
  "tfoot",
  "thead",
];

const TABLE_CELL_ELEMENTS = ["th", "td"];

const TABLE_DEFINITION_ELEMENTS = ["col", "colgroup"];

const EXTERNAL_ELEMENTS = ["audio", "iframe", "img", "math", "svg", "table", "video"];

const SELECTABLE_ELEMENTS = [
  "br",
  "a",
  "article",
  "aside",
  "blockquote",
  "body",
  "center",
  "dd",
  "div",
  "dl",
  "dt",
  "figcaption",
  "figure",
  "footer",
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "header",
  "hr",
  "html",
  "main",
  "nav",
  "noscript",
  "p",
  "pre",
  "section",
  "summary",
  "abbr",
  "acronym",
  "address",
  "b",
  "bdi",
  "bdo",
  "big",
  "cite",
  "code",
  "data",
  "del",
  "dfn",
  "em",
  "font",
  "i",
  "ins",
  "kbd",
  "mark",
  "q",
  "s",
  "samp",
  "small",
  "span",
  "strike",
  "strong",
  "time",
  "tt",
  "u",
  "var",
  "wbr",
];

/**
  Here is a list of elements with planned support:
    a         - i [x]
    abbr      - s [x]
    acronym   - s [x]
    address   - s [x]
    audio     - c [x]
    article   - b [x]
    aside     - b [x]
    b         - s [x]
    bdi       - s [x]
    bdo       - s [x]
    big       - s [x]
    blockquote- b [x]
    body      - b [x]
    br        - b [x]
    button    - i [ ]
    caption   - b [ ]
    center    - b [x]
    cite      - s [x]
    code      - s [x]
    data      - s [x]
    dd        - b [x]
    del       - s [x]
    dfn       - s [x]
    div       - b [x]
    dl        - b [x]
    dt        - b [x]
    em        - s [x]
    figcaption- b [x]
    figure    - b [x]
    font      - s [x]
    footer    - b [x]
    h1        - b [x]
    h2        - b [x]
    h3        - b [x]
    h4        - b [x]
    h5        - b [x]
    h6        - b [x]
    head      - e [x]
    header    - b [x]
    hr        - b [x]
    html      - b [x]
    i         - s [x]
    img       - c [x]
    ins       - s [x]
    kbd       - s [x]
    li        - b [x]
    main      - b [x]
    mark      - s [x]
    nav       - b [x]
    noscript  - b [x]
    ol        - b [x] post
    p         - b [x]
    pre       - b [x]
    q         - s [x] post
    rp        - s [x]
    rt        - s [x]
    ruby      - s [x]
    s         - s [x]
    samp      - s [x]
    section   - b [x]
    small     - s [x]
    source    -   [-] child of content
    span      - s [x]
    strike    - s [x]
    strong    - s [x]
    sub       - s [x]
    sup       - s [x]
    svg       - c [x]
    table     - b [x]
    tbody     - b [x]
    td        - s [ ]
    template  - e [x]
    tfoot     - b [x]
    th        - s [ ]
    thead     - b [x]
    time      - s [x]
    tr        - ? [ ]
    track     -   [-] child of content
    tt        - s [x]
    u         - s [x]
    ul        - b [x] post
    var       - s [x]
    video     - c [x]
    wbr       - s [x]
 */
