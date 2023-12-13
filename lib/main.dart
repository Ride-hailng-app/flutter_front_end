import 'package:fl_test/main_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

//import 'package:flutter/services.dart';
import "user_ui.dart";
import "netwrk.dart";
import "rider_ui.dart";
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
//import 'package:location/location.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/hypertrack.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

//late LocationData loco_pos;
late var screenSize;
late String fak_token;
late FirebaseApp fapp;
late var screenWidth; 
late var screenHeight;
//late HyperTrack hypertrackSdk;
late var dev_id;
late Position main_pos;
var position_ok = false;
late LatLng latpos;
late Function showLoader;
bool isshowloading = false;

late BuildContext main_ctx;
//active_main_contex;
late Location location;// = Location();
// = Position(latitude:0.3588043, longitude:32.5626172, accuracy:64.31999969482422, timestamp:1693458155874, altitude:1211.306640625, speed:0.0, isFromMockProvider=false, heading: "heading");//, speed: speed, speedAccuracy: speedAccuracy);
//bool active_form = true;

late Future<dynamic> showAlert;
late Function togState;

Future<bool> popAlert(BuildContext bctx,String msg) async
{
  bool retry_stat = false;
  await showPlatformDialog(
  context: bctx,
  builder: (bctx) => BasicDialogAlert(
    title: Text("Hello World"),
    content:
      Container(height:screenHeight*0.1,
        child:Column(children:[
          Container(
            height:screenHeight*0.05,
            child:Text("Wevuge Says: $msg")),LoadingAnimationWidget.horizontalRotatingDots(
      color: Colors.black,
      size: (screenHeight/screenWidth)*(20),
    )])
  ),
    actions: <Widget>[
      BasicDialogAction(
        title: Text("OK"),
        onPressed: () {
          Navigator.pop(bctx);
        },
      ),
      BasicDialogAction(
        title: Text("RETRY"),
        onPressed: () {
          retry_stat=true;
          Navigator.pop(bctx);
        },
      )
    ],
  ),
);

return retry_stat;
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.

  Position? pos = await Geolocator.getLastKnownPosition();

  if (pos==null)
  {
    print("no last known position");
    popAlert(main_ctx,"getting location data");
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  }
  print("last known position is $pos");
  popAlert(main_ctx,"Successfully obtained location data");
  //main_pos = pos as Position;
  position_ok = true;
  return pos as Position;
  
  
}

/*
Future<LocationData> detPos() async
{
  //location = Location();
  
  location.enableBackgroundMode(enable: true);
  bool _serviceEnabled;
PermissionStatus _permissionGranted;
LocationData _locationData;

_serviceEnabled = await location.serviceEnabled();
if (!_serviceEnabled) {
  _serviceEnabled = await location.requestService();
  if (!_serviceEnabled) {
    return Future.error('Location services are not enabled');
  }
}

_permissionGranted = await location.hasPermission();
if (_permissionGranted == PermissionStatus.denied) {
  _permissionGranted = await location.requestPermission();
  if (_permissionGranted != PermissionStatus.granted) {
    return Future.error('Location permissions are denied');
  }
}
 print("\ntrying to get the position");
 location.changeSettings(accuracy: LocationAccuracy.powerSave);
 print("\n location settings changed");
_locationData = await location.getLocation();//accuracy: LocationAccuracy.best);
return _locationData;
}
*/
void userOk() async
  {
    dynamic json_data = await getData();

  if(json_data.length>0)
  {

  int user_stat = json_data["status"];
  switch(user_stat)
  {
    case 201:
      position_ok=true;
      togState();
    break;

    case 200:
     position_ok=true;
     togState();
    break;

    default:
     position_ok=true;
     togState();
  }
  }
  else
  {
    print("no endpoint again");
    position_ok=false;
    //runApp(const MainApp());
  }
  }

void main() async {
  //location = Location();
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  //location.enableBackgroundMode(enable: true);
  fapp = await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  

  
  FlutterRingtonePlayer.stop();
  fak_token  = await FirebaseMessaging.instance.getToken() as String;
  print("firebase token is: $fak_token");

    prefs = await SharedPreferences.getInstance();

  prefs.setStringList("drivers", drivers_list);
  prefs.setBool("read_status",false);
  await initFB();
  /*
  5cl8F_qB-xPaldn9OsdP3PtUBJQYMdlOHu4dRkAtOCvZ7Y9zBb8XA3fguX47fGDiklGLH2EipWePDay6J6GLlg
  hypertrackSdk = await HyperTrack.initialize("n7HizHArPLQKNdZAFUwLrlID2CoZw1WSwsN5qKidiiFhGL5uZg3nRU_K7RdNswcGbcLcASsBj6LvwAH7_UZG9A",automaticallyRequestPermissions: true).onError((error, stackTrace) {
    throw Exception(error);
  });*/

  hypertrackSdk = await HyperTrack.initialize("5cl8F_qB-xPaldn9OsdP3PtUBJQYMdlOHu4dRkAtOCvZ7Y9zBb8XA3fguX47fGDiklGLH2EipWePDay6J6GLlg",automaticallyRequestPermissions: true).onError((error, stackTrace) {
    throw Exception(error);
  });
  dev_id = await hypertrackSdk.deviceId;
  hypertrackSdk.setAvailability(true);
  hypertrackSdk.startTracking();
  hypertrackSdk.sync();
  var hyper_locs = await hypertrackSdk.location;
  if (hyper_locs!= null)
  {

  }
  print("hyper location is $hyper_locs");
  print("\n\n\ndevice id is: $dev_id\n\n");
  //loco_pos = await detPos();
  //dev_id = Position(longitude: , latitude: latitude, timestamp: timestamp, accuracy: accuracy, altitude: altitude, heading: heading, speed: speed, speedAccuracy: speedAccuracy)
 // main_pos = await 
  runApp(MainAppX());
  main_pos = await _determinePosition();

  //if (position_ok==true)
  //{
  latpos = LatLng(main_pos.latitude,main_pos.longitude);

  print("\n position is: $main_pos");
  //}
 //FlutterRingtonePlayer.stop();
 while(true)
 {
  dynamic json_data = await getData();

  if(json_data.length>0)
  {

  
  int user_stat = json_data["status"];
  switch(user_stat)
  {
    case 201:
      //runApp(const MainApp());
      Navigator.push(main_ctx,MaterialPageRoute(builder: (mainctx)=>MainApp()));
    break;

    case 200:
     //runApp(const MainApp());
     Navigator.push(main_ctx,MaterialPageRoute(builder: (mainctx)=>MainApp()));
    break;

    default:
     //runApp(const MainApp());
     Navigator.push(main_ctx,MaterialPageRoute(builder: (mainctx)=>MainApp()));
  }
    break;
  }
  else
  {
    /*
    print("no endpoint");
    position_ok=false;
    runApp(const MainApp());
    */

    bool is_retry = await popAlert(main_ctx,"Connection Error");

    if(is_retry)
    {
      continue;
    }
    else
    {
      break;
    }
  }

 }
  
}

class MainAppX extends StatelessWidget {
  const MainAppX({super.key});
  
  @override
  Widget build(BuildContext context)
  {
   // main_ctx = context;
    screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    return MaterialApp(title: "Wevuuge User", 
      home: Scaffold(appBar: AppBar(
    title: Text('WEVUGE USER LOGIN'),backgroundColor: Color.fromARGB(249, 4, 48, 116)),
        body: InitApp()
      ),
    );
  }
}

class InitApp extends StatelessWidget {
  const InitApp({super.key});
  
  @override
  Widget build(BuildContext context)
  {
    
    main_ctx = context;
    //screenSize = MediaQuery.of(context).size;
    //screenWidth = screenSize.width;
    //screenHeight = screenSize.height;
    return Container
        (
          color: Color.fromARGB(249, 4, 48, 116),
          child: ListView(children:[
            Container(
              height:(screenHeight)*(0.2),
          child:Text("Hello, Initialising please wait for location and server.....",style:  TextStyle(color: Colors.white,fontSize:(screenHeight/screenWidth)*(10),fontWeight: FontWeight.bold))),
          
          LoadingAnimationWidget.newtonCradle(
      color: Colors.white,
      size: (screenHeight/screenWidth)*(70),
    ),
        ])
        );
  }
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context)
  {
    screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    main_ctx = context;

    /*
    if(position_ok==false)
    {

    
    showPlatformDialog(
  context: context,
  builder: (context) => BasicDialogAlert(
    title: Text("Connecting"),
    content:
        Text("getting location..please wait"),
    actions: <Widget>[
      BasicDialogAction(
        title: Text("OK"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ],
  ),
);
    }
    else
    {
      showPlatformDialog(
  context: context,
  builder: (context) => BasicDialogAlert(
    title: Text("Location"),
    content:
        Text("Location Okay"),
    actions: <Widget>[
      BasicDialogAction(
        title: Text("OK"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ],
  ),
);
    }
    */


    return MaterialApp(title: "Wevuuge User", 
      home: Scaffold(appBar: AppBar(
    title: Text('WEVUGE USER LOGIN'),backgroundColor: Color.fromARGB(249, 4, 48, 116)),
        body: Div_master(),
      ),
    );
  }
}

class LoadingVW extends StatefulWidget
{
  LoadingAnime createState()
  {
    return LoadingAnime();
  }

}

class LoadingAnime extends State<LoadingVW>
{

    void setShowLoading(bool load_state)
    {
      setState((){isshowloading=load_state;});
    }
  @override
  Widget build(BuildContext context)
  {
    showLoader = setShowLoading;
    if(isshowloading==true)
    {
       return Container(
      margin: EdgeInsets.only(top: (screenHeight*0.03)),
      width: screenWidth*0.01,
      child:LoadingAnimationWidget.beat(
      color: Colors.white,
      size: (screenHeight/screenWidth)*(10),
    ));
    }
    return Container(color:Colors.black);
   
  }
  //return Container();
}

class Div_master extends StatelessWidget
{
  
  
  @override
  Widget build(BuildContext context)
  {
     
     

    return Container(
  width: (screenWidth),
  height: (screenHeight),
  color: Colors.black,
  child: ListView
        (
            children: [Head_div(),Login_master_div()],
        ),
);
  }
}

class Head_div extends StatelessWidget
{

  @override
  Widget build(BuildContext context)
  {
    return Container( width: (screenWidth),height: (50),color: Colors.black,
        child: Center(
          child: Text('HELLO WORLD, READY WEVUUGGE', style: TextStyle(color: Colors.white,fontSize:(screenHeight/screenWidth)*(12),fontWeight: FontWeight.bold)))
    );
  }
}

class Login_master_div extends StatefulWidget
{
  @override
  Login_master_state createState()
  {
    return Login_master_state();
  }
}

class Login_master_state extends State<Login_master_div>
{
  
   bool active_form = true;
   bool loca_state = false;
   void changeState()
   {
      setState(()
                        {
                        active_form = !active_form;
                        });
   }

   void changeLocState()
   {
      setState(()
                        {
                        //active_form = !active_form;
                        loca_state = position_ok;
                        });
   }
  /*
  @override
  Widget build(BuildContext context)
  {
    togState =changeLocState;

    return Center
          (
            child: Container
                  (
                      margin: EdgeInsets.only(top: screenHeight*0.04),
                      width: (screenWidth*0.8),
                      height: (screenHeight*0.6),
                      decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                      child: ListView(
                      children: [(active_form==true? Login_Reg_form(screenWidth*0.8,screenHeight*0.5,onPressed:()=>changeState()): Reg_login_form(screenWidth*0.8,screenHeight*0.5,onPressed: ()=>changeState())):(Row(children:[ Text('No location or connection to server', style: TextStyle(color: Colors.white,fontSize: (screenHeight/screenWidth)*(10))),ElevatedButton
                    (
                      
                      style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),
                      onPressed: ()
                      {*/
                        /*
                        var poste = 
                        {
                          "telephone":telno_ctrl.text,
                          "passcode":passcode_ctrl.text
                        };
                        dynamic json_dta = await postData("login",poste);
                        
                        int json_dta_stat = json_dta["status"];

                        if(json_dta_stat==200)
                        {
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>User("Aivan",(telno_ctrl.text),"customer",screenWidth,screenHeight)));
                        }
                        else
                        {
                          print(json_dta["message"]);
                        }
                        */
                        /*
                        userOk();
                      },
                      child: Text('RETRY')
                    )]))]
                  ))
          );
  }
  */

  @override
  Widget build(BuildContext context)
  {
    return Center
          (
            child: Container
                  (
                      margin: EdgeInsets.only(top: screenHeight*0.04),
                      width: (screenWidth*0.8),
                      height: (screenHeight*0.7),
                      decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                      child: ListView(
                      children: [active_form==true? Login_Reg_form(screenWidth*0.8,screenHeight*0.5,onPressed:()=>changeState()): Reg_login_form(screenWidth*0.8,screenHeight*0.5,onPressed: ()=>changeState()),LoadingVW()]
                  ))
          );
  }
}

class Login_Reg_form extends StatefulWidget
{
  late var active_width;
  late var active_height;
  late var onPressed;
  Login_Reg_form(this.active_width,this.active_height,{required this.onPressed})
    {

    }
  
  @override
  Login_Reg_form_state createState()
  {
    return Login_Reg_form_state(active_width,active_height,onPressed:onPressed);
  }
}

class Login_Reg_form_state extends State<Login_Reg_form>//StatelessWidget
{
    late double active_width;
    late double active_height;
    final VoidCallback onPressed;

    TextEditingController telno_ctrl = TextEditingController();
    TextEditingController passcode_ctrl = TextEditingController();

    Login_Reg_form_state(var width,height,{required this.onPressed})
    {
        active_height = height;
        active_width  = width;
    }

    Future<void> getdata() async
    {
      showLoader(true);
      var poste = 
                        {
                          "telephone":telno_ctrl.text,
                          "passcode":passcode_ctrl.text,
                          "dev_id": dev_id,
                          "fb_id": fak_token
                        };
                        print("sending post data $poste");
                        dynamic json_dta = await postData("login",poste);
                        
                        if(json_dta!=Null)
                        {
                          showLoader(false);
                        int json_dta_stat = json_dta["status"];
                        //String unames = json_dta["user_names"];
                        /*
                        if(json_dta_stat==200)
                        {
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>User("user",(telno_ctrl.text),"customer",screenWidth,screenHeight,hypertrackSdk)));
                        }
                        else
                        {
                          print(json_dta["message"]);
                        }
                        */
                        String user_names = "User";//names_ctrl.text;
                        String telephone = telno_ctrl.text;
                        if(json_dta_stat==200)
                        {
                           String json_dta_redrl = json_dta["redirect"];
                           user_names = json_dta["app_man"];
                           String map_url = json_dta["map_man"];
                           print("\n\nredirect url is $json_dta_redrl and map url is $map_url\n\n");
                           if(json_dta_redrl=="customer")
                           {
                              //Navigator.push(context,MaterialPageRoute(builder: (context)=>User(user_names,(telephone),"customer",screenWidth,screenHeight,hypertrackSdk,main_pos)));
                              Navigator.push(context,MaterialPageRoute(builder: (context)=>User(user_names,(telephone),"customer",screenWidth,screenHeight,hypertrackSdk,latpos)));
                              //Navigator.push(context,MaterialPageRoute(builder:(context)=>MainMap(map_url)));
                           }
                           else if(json_dta_redrl=="rider")
                           {
                           //  Navigator.push(context,MaterialPageRoute(builder: (context)=>Rider(user_names,(telephone),"rider",screenWidth,screenHeight,hypertrackSdk,main_pos)));
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>Rider(user_names,(telephone),"rider",screenWidth,screenHeight,hypertrackSdk,latpos)));
                           }
                            
                        }
                        else
                        {
                          String server_msg = json_dta["message"];
                          print(server_msg);

                          popAlert(main_ctx,"user error: $server_msg");
                        }
                        }
                        else
                        {
                          print("connection error");
                          popAlert(main_ctx,"Connection error");
                        }
    }

    @override
    Widget build(BuildContext context)
    {
        return Column
                (
                  children: 
                  [
                    Container
                    (
                      width : active_width*(0.5),
                      height: active_height*(0.1),
                      color: Colors.black,
                      child:  Center(child: Text('Please Fill the form below!', style: TextStyle(color: Colors.white,fontSize: (screenHeight/screenWidth)*(10))))

                    ),
                    Container
                    (
                        
                        width:  active_width*0.8,
                        height: active_height*0.2,
                        child: TextField
                        (
                          keyboardType: TextInputType.number,
                          controller: telno_ctrl,
                          decoration: InputDecoration
                                                    (
                                                      labelText: "Please Enter Phone Number: ",
                                                      hintText: "Phone Number",
                                                      //border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                                                      prefixIcon: Icon(Icons.text_fields),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                    ),
                        )
                    ),
                    Container
                    (
                        margin: EdgeInsets.only(top: screenHeight*0.02),
                        width:  active_width*0.8,
                        height: active_height*0.2,
                        child: TextField
                        (
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          controller: passcode_ctrl,
                          decoration: InputDecoration
                                                    (
                                                      labelText: "Please Enter Password: ",
                                                      hintText: "Password",
                                                      
                                                      //border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                                                      prefixIcon: Icon(Icons.text_fields),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                    ),
                        )
                    ),
                    ElevatedButton
                    (
                      
                      style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),
                      onPressed: ()
                      {
                        /*
                        var poste = 
                        {
                          "telephone":telno_ctrl.text,
                          "passcode":passcode_ctrl.text
                        };
                        dynamic json_dta = await postData("login",poste);
                        
                        int json_dta_stat = json_dta["status"];

                        if(json_dta_stat==200)
                        {
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>User("Aivan",(telno_ctrl.text),"customer",screenWidth,screenHeight)));
                        }
                        else
                        {
                          print(json_dta["message"]);
                        }
                        */
                        getdata();
                      },
                      child: Text('LOGIN')
                    ),
                    Container
                    (
                      child:Text("Don't Have Account???\n Click Below To Create An Account:", style: TextStyle(color: Colors.white,fontSize: (active_height/active_width)*18))
                    ),

                    ElevatedButton
                    (
                      
                      style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),
                      onPressed: onPressed,
                      /*()
                      {

                      },
                      */
                      child: Text('CREATE ACCOUNT')
                    ),
                  ],
                );
    }
}

class Reg_login_form extends StatefulWidget
{
  late double active_width;
    late double active_height;
    final VoidCallback onPressed;
   // var selectedValue = "mice";
    Reg_login_form(this.active_width,this.active_height,{required this.onPressed})
    {
        //active_height = height;
        //active_width  = width;
    }
  @override
  Reg_login_form_vw createState()
  {
    return Reg_login_form_vw(active_width,active_height,onPressed: onPressed);
  }
}

class Reg_login_form_vw extends State<Reg_login_form>//lessWidget
{
    late double active_width;
    late double active_height;
    final VoidCallback onPressed;
    var selectedValue = "customer";
    TextEditingController names_ctrl = TextEditingController();
   
    TextEditingController telno_ctrl = TextEditingController();
    TextEditingController passcode_ctrl = TextEditingController();


    Reg_login_form_vw(var width,height,{required this.onPressed})
    {
        active_height = height;
        active_width  = width;
    }

    void toggleChange(value)
    {
      setState(() {
        selectedValue = value;
      });
    }



    Future<void> getdata() async
    {
      showLoader(true);
      print("posting data");
      var poste = 
                        {
                          "name":names_ctrl.text,
                          "telephone":telno_ctrl.text,
                          "passcode":passcode_ctrl.text,
                          "user_type":selectedValue,
                          "dev_id": dev_id,
                          "fb_id": fak_token
                        };
                        dynamic json_dta = await postData("register",poste);
                        
                        if(json_dta!=Null)
                        {
                          showLoader(false);
                        int json_dta_stat = json_dta["status"];
                        
                        String user_names = names_ctrl.text;
                        String telephone = telno_ctrl.text;
                        if(json_dta_stat==200)
                        {
                          //showLoader(false);
                           String json_dta_redrl = json_dta["redirect"];
                           print("redirect url is $json_dta_redrl");
                           if(selectedValue=="customer")
                           {
                             // Navigator.push(context,MaterialPageRoute(builder: (context)=>User(user_names,(telephone),"customer",screenWidth,screenHeight,hypertrackSdk,main_pos)));
                               Navigator.push(context,MaterialPageRoute(builder: (context)=>User(user_names,(telephone),"customer",screenWidth,screenHeight,hypertrackSdk,latpos)));
                           }
                           else if(selectedValue=="rider")
                           {
                             //Navigator.push(context,MaterialPageRoute(builder: (context)=>Rider(user_names,(telephone),"rider",screenWidth,screenHeight,hypertrackSdk,main_pos)));
                             Navigator.push(context,MaterialPageRoute(builder: (context)=>Rider(user_names,(telephone),"rider",screenWidth,screenHeight,hypertrackSdk,latpos)));
                           }
                            
                        }
                        else
                        {
                          String user_msg = json_dta["message"];
                          print("server says: $user_msg");
                          popAlert(main_ctx,"User error $user_msg");
                        }
                        }
                        else
                        {
                          print("user connection error");
                          popAlert(main_ctx,"Connection error");
                        }
    }

    @override
    Widget build(BuildContext context)
    {
        return Column
                (
                  children: 
                  [
                    Container
                    (
                      width : active_width*(0.9),
                      height: active_height*(0.1),
                      color: Colors.black,
                      child:  Center(child: Text('Please Fill Registration Form Below!', style: TextStyle(color: Colors.white,fontSize: (screenHeight/screenWidth)*(10))))

                    ),
                    Container
                    (
                        margin: EdgeInsets.only(top: screenHeight*0.02),
                        width:  active_width*0.8,
                        
                        child: TextField
                        (
                          controller: names_ctrl,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration
                                                    (
                                                      labelText: "Please Enter Your Names: ",
                                                      hintText: "Full Names",
                                                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                                                      prefixIcon: Icon(Icons.text_fields),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                    ),
                        )
                    ),
                    Container
                    (
                        margin: EdgeInsets.only(top: screenHeight*0.02),
                        width:  active_width*0.8,
                        child: TextField
                        (
                          keyboardType: TextInputType.number,
                          controller: telno_ctrl,
                          decoration: InputDecoration
                                                    (
                                                      labelText: "Please Enter Phone Number: ",
                                                      hintText: "Phone Number",
                                                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                                                      prefixIcon: Icon(Icons.text_fields),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                    ),
                        )
                    ),
                    Container
                    (
                    width: active_width,
                    height: active_height*0.05,
                    child: Center(
                    child:Text("please choose user type below",style: TextStyle(color: Colors.white))
                    )
                    ),
                    Container
                    (
                    width: active_width,
                    height: active_height*0.08,
                    //color: Colors.white,
                    child:
                    Row(
                    children:[
                    Container
                    (
                     margin: EdgeInsets.only(left: active_width*0.06),
                     width: active_width*0.4,
                     //height: active_height*0.1,
                    child: RadioListTile<String>
                    (
                      title: Text('Rider',style:TextStyle(color: Colors.white)),
                      value: 'rider',
                      groupValue: selectedValue,
                      //selected: false,
                      onChanged: (value)
                      {
                      //selectedValue = value!;
                      toggleChange(value);
                      //print("changed $selectedValue");
                      },
                      
                      activeColor: Colors.blue, // Set the color when active (selected)
                      tileColor: Colors.red,
                      fillColor: MaterialStateColor.resolveWith((states) => Colors.white)
                    )
                    ),
                    Container
                    (
                    width: active_width*0.5,
                    //height: active_height*0.1,
                    //color: Colors.white,
                    child:RadioListTile<String>
                    (
                      title: Text('Customer',style:TextStyle(color: Colors.white)),
                      value: 'customer',
                      groupValue: selectedValue,
                      //selected: false,
                      onChanged: (value) 
                      {
                      //selectedValue = value;
                      toggleChange(value);
                      //print("changed value $selectedValue");
                      },
                       activeColor: Colors.blue, // Set the color when active (selected)
                       tileColor: Colors.red,
                       fillColor: MaterialStateColor.resolveWith((states) => Colors.white)
                       
                    )
                    )
                    ]
                    )
                    ),
                    Container
                    (
                        margin: EdgeInsets.only(top: screenHeight*0.03),
                        width:  active_width*0.8,
                        child: TextField
                        (
                          controller: passcode_ctrl,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration
                                                    (
                                                      labelText: "Please Enter Password: ",
                                                      hintText: "Password",
                                                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                                                      prefixIcon: Icon(Icons.text_fields),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                    ),
                        )
                    )
                 ,
                    ElevatedButton
                    (
                      
                      style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),
                      onPressed:()
                      {
                       getdata();
                      },
                      child: Text('REGISTER !')
                    ),
                    Container
                    (
                      child:Text("Have an account??? Click below to Login:", style: TextStyle(color: Colors.white,fontSize: (active_height/active_width)*18))
                    ),

                    ElevatedButton
                    (
                      
                      style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),
                      onPressed: onPressed,
                      /*()
                      {
                          
                      },*/
                    
                      child: Text('LOGIN !')
                    ),
                  ],
                );
    }
}
