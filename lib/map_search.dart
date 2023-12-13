import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//void main() {
//  runApp(MyApp());
//}
/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}
*/

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  List<dynamic> _queryData = [];
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(0.32, 32.6),
              zoom: 13.0,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SearchWidget(
              controller: _searchController,
              onSearch: _performSearch,
              searchResults: _searchResults,
            ),
          ),
        ],
    //  ),
    );
  }

  void _performSearch(String query) async {
   print("\n\nresults starting");
  final apiUrl = 'https://nominatim.openstreetmap.org/search?format=json&q=$query';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    List<String> results = (data.map((place) => place['display_name']).toList()).cast<String>();
    print(results.toString());
    setState(() {
      _searchResults = results;
    });
  } else {
    print('Error fetching search results');
  }
}
}

class SearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final List<String> searchResults;

  SearchWidget({required this.controller, required this.onSearch, required this.searchResults});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  bool _isExpanded = false;
  //late List<String> _searchResults;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 500,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!_isExpanded)
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _expandSearchBar,
          ),
        if (_isExpanded)
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Container(color:Colors.white,
              child: TextField(
              controller: widget.controller,
              onSubmitted: widget.onSearch,
              style: TextStyle(color:Colors.black)
            )),
          ),
        if (_isExpanded && widget.searchResults.isNotEmpty)
          Expanded(
            child: Container(color:Colors.white,
            child: ListView.builder(
              itemCount: widget.searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.searchResults[index]),
                  // Add onTap functionality to handle the selected place
                );
              },
            ),
      )),
      ],
    ));
  }

  void _expandSearchBar() {
    setState(() {
      _isExpanded = true;
    });
  }

  
}

