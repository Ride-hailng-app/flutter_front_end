import 'package:fl_test/user_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
///import 'package:geocode/geocode.dart';
///import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

/*void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Example',
      home: MapPage(),
    );
  }
}
*/
late LatLng center_coords;
List<Widget> items = [];
class MapView extends StatefulWidget
{
  late var getMark;
  late MapPage vwpage;
  MapView(this.getMark,LatLng coords_me)
  {
    center_coords = coords_me;
  }

  LatLng getLastMark(int ind)
  {
    return vwpage.getLastMark(ind);
  }
  @override
  MapPage createState()
  {
    vwpage = MapPage(getMark);
    return vwpage;
  }

}
class MapPage extends State<MapView>
{
   late MapController _mapController;
    final TextEditingController _searchController = TextEditingController();
    List<String> _locations = [];
    List<dynamic> queryData = [];
   List<Marker> mmarkers = [];
   List<LatLng> paths = [];
   late var pickup = null;
   late var dest = null;
   late var driver = null ;
   late Function getMType;
   int marker_type = 0;
   //late LatLng center_coords;// = LatLng(0.3222496209212994,32.56208181381226);
    List<String> _searchResults = [];
   Map user_coords = {};
   MapPage(this.getMType)
   {
    
      
   }



  LatLng _currentLocation = LatLng(0, 0);
  /*
  void _searchLocation() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      GeoCode geoCode = GeoCode();
      List<Location> locations = await locationFromAddress("Gronausestraat 710, Enschede");

  try {
    Coordinates coordinates = await geoCode.forwardGeocoding(
        address: query);

    print("getting the ${locations[0].toString()} Latitude: ${coordinates.latitude}");
    items.add(Text("Item one",style: TextStyle(color:Colors.white)));
    print("getting $query Longitude: ${coordinates.longitude}");
  } catch (e) {
    print(e);
  }
    }
  } 
  */

  void _searchLocation() async {
    final query = _searchController.text;
  if (query.isEmpty) {
    setState(() {
      _locations.clear();
    });
    return;
  }

  final response = await http.get(Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=$query'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List<dynamic>;
    print("getting json location ${data.toString()}");
    final locations = data.map((item) => item['display_name'] as String).toList();
    print("getting location ${locations[0]}");
    setState(() {
      _locations = locations;
    });
  }
}


   @override
   void initState() {
    // TODO: implement initState
    super.initState();
    _mapController = MapController();
   //center_coords = LatLng(0.3222496209212994,32.56208181381226);
   //default map point
    user_coords[0]=center_coords;
    pickup = Marker(
                      width: 40.0,
                      height: 40.0,
                      point: center_coords,
                      builder: (ctx) => Container(
                            child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                        ),
                  );
            mmarkers.add(pickup);

  }

/*
  void setMarkerType(int mt)
  {
    setState(() 
    {
      marker_type = mt;
    });
  }
*/
  LatLng getLastMark(int ind)
  {
    return user_coords[ind];
  }

  void setCenter(LatLng apoint)
  {
    setState(()
    {
      center_coords = apoint;
    });
  }

  void setMarker(var tp,LatLng apoint)
  {
    marker_type = getMType();
    user_coords[marker_type]=apoint;
   setState(() 
   {
      center_coords = apoint;
      switch(marker_type)
      {
        case 0:

          if(pickup!=null)
          {
            mmarkers.remove(pickup);
          }
          pickup = Marker(
                      width: 40.0,
                      height: 40.0,
                      point: apoint,
                      builder: (ctx) => Container(
                            child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                        ),
                  );
            mmarkers.add(pickup);
        break;

        case 1:
            if(dest!=null)
          {
            mmarkers.remove(dest);
          }
          dest = Marker(
                      width: 40.0,
                      height: 40.0,
                      point: apoint,
                      builder: (ctx) => Container(
                            child: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                          ),
                        ),
                  );
            mmarkers.add(dest);
        break;

        case 2:
            if(dest!=null)
          {
            mmarkers.remove(driver);
          }
          driver = Marker(
                      width: 40.0,
                      height: 40.0,
                      point: apoint,
                      builder: (ctx) => Container(
                            child: Icon(
                            Icons.location_on,
                            color: Colors.green,
                          ),
                        ),
                  );
            mmarkers.add(driver);
        break;
      }
    
    }
    );

    
  }

  void isetMarker(LatLng apoint)
  {
    center_coords = apoint;
    marker_type = getMType();
    user_coords[marker_type]=apoint;
    _mapController.move(apoint,18);
   setState(()
   {
      print("\n\ncenter point is: ${apoint.toString()}");
     // center_coords = apoint;

      switch(marker_type)
      {
        case 0:

          if(pickup!=null)
          {
            mmarkers.remove(pickup);
          }
          pickup = Marker(
                      width: 40.0,
                      height: 40.0,
                      point: apoint,
                      builder: (ctx) => Container(
                            child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                        ),
                  );
            mmarkers.add(pickup);
        break;

        case 1:
            if(dest!=null)
          {
            mmarkers.remove(dest);
          }
          dest = Marker(
                      width: 40.0,
                      height: 40.0,
                      point: apoint,
                      builder: (ctx) => Container(
                            child: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                          ),
                        ),
                  );
            mmarkers.add(dest);
        break;

        case 2:
            if(dest!=null)
          {
            mmarkers.remove(driver);
          }
          driver = Marker(
                      width: 40.0,
                      height: 40.0,
                      point: apoint,
                      builder: (ctx) => Container(
                            child: Icon(
                            Icons.location_on,
                            color: Colors.green,
                          ),
                        ),
                  );
            mmarkers.add(driver);
        break;
      }
    
    }
    );

    
  }

  @override
  Widget build(BuildContext context) {
    return 
    Stack(
      children:
        [
        /*Positioned(
        top: 16,
        right: 16,
        child: Container(
        width: uscreenWidth*0.5,
        height: uscreenHeight*0.5,
        child: TextField(
          controller: _searchController,
          onSubmitted: (_) => _searchLocation(),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: 'Search location',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: (){_searchLocation();}//_searchAndDisplayLocation,
            ),
          ),
        ))
        ),*/
       
         // child: 
      //   Stack(
        //  children:[
        //Visibility(visible: true,child: Text("Hello",style: TextStyle(color:Colors.green))),
       // Expanded(
          //child: 
          FlutterMap(
            mapController: _mapController,
       /*onTilesLoaded: (tiles) {
            // Load the next set of tiles.
            _mapController.loadTiles(
              _mapController.visibleTileBounds,
              force: true,
            );
          },*/
      options: MapOptions(
        center: center_coords, // Initial map center (latitude, longitude)
        zoom: 18.0,
        onTap: setMarker // Initial zoom level
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'], // Subdomains for distributing requests
        ),
         MarkerLayerOptions(
         
          markers: mmarkers,
        ),
        PolylineLayerOptions(
          polylines: [
            Polyline(
              points: paths,
              color: const Color.fromARGB(255, 146, 202, 247), // Color of the path
              strokeWidth: 15.0, // Width of the path
            ),
          ],
        ),
        // Add other map layers or markers here if needed
     ],
      
    ),
    /*Positioned(
            top: 16,
            right: 16,
            child: SearchWidget(
              controller: _searchController,
              onSearch: _performSearch,
              searchResults: _searchResults,
              resultsTap: tappedBox,
            ),
          )*/
    ]
    //)
    );
  }

  void tappedBox(index)
  {
    var ind_tap = queryData[index];
    print("query data index is: ${ind_tap.toString()}");
    isetMarker(LatLng(double.parse(ind_tap["lat"]),double.parse(ind_tap["lon"])));
    print("marker set");
  }

  void _performSearch(String query) async 
  {
   print("\n\nresults starting");
  final apiUrl = 'https://nominatim.openstreetmap.org/search?format=json&q=$query';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    queryData = data;
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

class Locations extends StatefulWidget {
  @override
  LocationsState createState() => LocationsState();
}

class LocationsState extends State<Locations> {
   // List of items to display in the ListView

  @override
  Widget build(BuildContext context) {
    return Container(
          color: Colors.green,
          width: uscreenWidth,
          height: uscreenHeight*0.05,
          child: ListView(
      children: items
    ));
  }
}

class SearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final List<String> searchResults;
  final Function(void) resultsTap;

  SearchWidget({required this.controller, required this.onSearch, required this.searchResults, required this.resultsTap});

  @override
  _SearchWidgetState createState() => _SearchWidgetState(resultsTap);
}

class _SearchWidgetState extends State<SearchWidget> {
  bool _isExpanded = false;
  late Function(void) resultsTap;
  _SearchWidgetState(this.resultsTap)
  {

  }
  //late List<String> _searchResults;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: uscreenWidth*0.8,
      height: uscreenHeight*0.3,
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
            width: uscreenWidth*0.7,
            color: Colors.white,
          //child: Positioned(
            
          child: Row(
            
          children: [IconButton(
            icon: Icon(Icons.search),
            onPressed: _contractSearchBar,
          ),
          //Container(
            //width: uscreenWidth*0.35,
            //MediaQuery.of(context).size.width * 0.35,
           // child: 
            Container(//color:Colors.white,
              width: uscreenWidth*0.55,
              child: TextField(
              controller: widget.controller,
              onSubmitted: widget.onSearch,
              style: TextStyle(color:Colors.black),
              decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true)
            )),
        //  )
          ]
          
        )
        
        ),
        if (_isExpanded && widget.searchResults.isNotEmpty)
          Expanded(
            child: Container(color:Colors.white,
            child: ListView.builder(
              itemCount: widget.searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.searchResults[index]),
                  onTap: (){tapped(index);
                  resultsTap(index);},
                  // Add onTap functionality to handle the selected place
                );
              },
            ),
      )),
      ],
    ));
  }

  void tapped(index)
  {
    var datum = widget.searchResults[index];
    print("\n\n\ntapped data is ${datum.toString()}");
    _contractSearchBar();
    
  }
  void _expandSearchBar() {
    setState(() {
      _isExpanded = true;
    });
  }

  void _contractSearchBar() {
    setState(() {
      _isExpanded = false;
    });
  }

  
}
