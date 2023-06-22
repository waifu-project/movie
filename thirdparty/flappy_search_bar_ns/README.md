git commit hash: 568cc6fd1ab22f40ff34005a19a784ea7027f8f1

# flappy_search_bar_ns

A SearchBar widget handling most of search cases.

## Usage

To use this plugin, add flappy_search_bar_ns as a dependency in your pubspec.yaml file.

### Example

```
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SearchBar<Post>(
          searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
          headerPadding: EdgeInsets.symmetric(horizontal: 10),
          listPadding: EdgeInsets.symmetric(horizontal: 10),
          onSearch: _getALlPosts,
          searchBarController: _searchBarController,
          placeHolder: Text("placeholder"),
          cancellationWidget: Text("Cancel"),
          emptyWidget: Text("empty"),
          indexedScaledTileBuilder: (int index) => ScaledTile.count(1, index.isEven ? 2 : 1),
          header: Row(
            children: <Widget>[
              RaisedButton(
                child: Text("sort"),
                onPressed: () {
                  _searchBarController.sortList((Post a, Post b) {
                    return a.body.compareTo(b.body);
                  });
                },
              ),
              RaisedButton(
                child: Text("Desort"),
                onPressed: () {
                  _searchBarController.removeSort();
                },
              ),
              RaisedButton(
                child: Text("Replay"),
                onPressed: () {
                  isReplay = !isReplay;
                  _searchBarController.replayLastSearch();
                },
              ),
            ],
          ),
          onCancelled: () {
            print("Cancelled triggered");
          },
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          crossAxisCount: 2,
          onItemFound: (Post post, int index) {
            return Container(
              color: Colors.lightBlue,
              child: ListTile(
                title: Text(post.title),
                isThreeLine: true,
                subtitle: Text(post.body),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Detail()));
                },
              ),
            );
          },
        ),
      ),
    );
  }
```

### Try it

A sample app is available to let you try all the features ! :)

### Warning

If you want to use a SearchBarController in order to do some sorts or filters, PLEASE put your instance of SearchBarController in a StateFullWidget.

If not, it will not work properly.

If you don't use an instance of SearchBarController, you can keep everything in a StateLessWidget !

### Parameters

| Name  | Type | Usage | Required | Default Value |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| onSearch   | Future<List<T>> Function(String text) | Callback giving you the text to look for and asking for a Future  | yes  | - |
| onItemFound| Widget Function(T item, int index) | Callback letting you build the widget corresponding to each item| yes| - |
| suggestions  |  List<T> | Potential fist list of suggestions (when no request have been made)  | no| [] |
| searchBarController  |  SearchBarController | Enable you to sort and filter your list  | no | default controller |
| searchBarStyle  |  SearchBarStyle | Syle to customize SearchBar  | no | default values on bottom tab |
| buildSuggestions| Widget Function(T item, int index) | Callback called to let you build Suggestion item (if not provided, the suggestion will have the same layout as the basic item)  | no| null|
| minimumChars  |  int | Minimum number of chars to start querying  | no| 3 |
| onError  |  Function(Error error) | Callback called when an error occur runnning Future | no| null |
| debounceDuration  | Duration | Debounce's duration | no| Duration(milliseconds: 500) |
| loader  | Widget | Widget that appears when Future is running | no| CircularProgressIndicator() |
| emptyWidget  | Widget | Widget that appears when Future is returning an empty list | no| SizedBox.shrink() |
| icon  | Widget | Widget that appears on left of the SearchBar | no| Icon(Icons.search) |
| hintText  | String | Hint Text | no| "" |
| hintStyle  | TextStyle | Hint Text style| no| TextStyle(color: Color.fromRGBO(142, 142, 147, 1)) |
| iconActiveColor  | Color | Color of icon when active | no| Colors.black |
| textStyle  | TextStyle | TextStyle of searched text | no| TextStyle(color: Colors.black) |
| cancellationWidget  | Widget | Widget shown on right of the SearchBar | no| Text("Cancel") |
| onCancelled  | VoidCallback | Callback triggered on cancellation's button click | no| null |
| crossAxisCount  | int | Number of tiles on cross axis (Grid) | no| 2 |
| shrinkWrap  | bool | Wether list should be shrinked or not (take minimum space) | no| true |
| scrollDirection  | Axis | Set the scroll direction | no| Axis.vertical |
| mainAxisSpacing  | int | Set the spacing between each tiles on main axis | no| 10 |
| crossAxisSpacing  | int | Set the spacing between each tiles on cross axis | no| 10 |
| indexedScaledTileBuilder  | IndexedScaledTileBuilder | Builder letting you decide how much space each tile should take | no| (int index) => ScaledTile.count(1, index.isEven ? 2 : 1) |  
| searchBarPadding  | EdgeInsetsGeometry | Set a padding on the search bar | no| EdgeInsets.symmetric(horizontal: 10) |
| headerPadding  | EdgeInsetsGeometry | Set a padding on the header | no| EdgeInsets.symmetric(horizontal: 10) |
| listPadding  | EdgeInsetsGeometry | Set a padding on the list | no| EdgeInsets.symmetric(horizontal: 10) |
  
### SearchBar default SearchBarStyle

| Name  | Type | default Value |
| ------------- | ------------- | ------------- |
| backgroundColor  | Color  | Color.fromRGBO(142, 142, 147, .15)  |
| padding  | EdgeInsetsGeometry  | EdgeInsets.all(5.0)  |
| borderRadius  | BorderRadius  | BorderRadius.all(Radius.circular(5.0))})  |



