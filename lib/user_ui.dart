import 'dart:convert';
import 'dart:ffi';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:fl_test/main.dart';
import 'package:fl_test/main_map.dart';
import "package:flutter/material.dart";
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
//import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import "map_man.dart";
import "map_search.dart";
import "netwrk.dart";
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:location/location.dart';
//import 'package:hypertrack_plugin/data_types/location.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/hypertrack.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

  late String usernames;
  late String user_digits;
  late String user_type;
  String map_url = "";
  late double uscreenHeight = 1;
  late double uscreenWidth = 1;
  late var uscreenRatio;
  int rider_index = 0;
  late var type = 0;
  late MapView user_map;
  Map post_coords = {};
  late HyperTrack hypertrackSdk;
  bool hypertrack_status = false;
  late LatLng c_pos;
  MsgBox msgbox = MsgBox();
  late var active_drivers = [];
  late var active_order;
  //late var dectype;
  late var order_data;

  late var order_meta={};


  late var rider_order_data;
  late Function settype;
late FirebaseMessaging messaging;
List<String> drivers_list = List<String>.empty();
late final SharedPreferences prefs;
List active_orders = [];
bool isusershowloading = false;
late Function usershowLoader;
late Function viewSet;
late BuildContext user_main_ctx;

void _showAlert(BuildContext context,String alert_msg) {
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: Text("Error"),
        content:
            Text("System says $alert_msg"),
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

  Future<bool> userpopAlert(BuildContext bctx,String msg) async
{
  bool retry_stat = false;
  await showPlatformDialog(
  context: bctx,
  builder: (bctx) => BasicDialogAlert(
    title: Text("Hello World"),
    content:
      Container(height:screenHeight*0.2,
        child:Column(children:[Text("Wevuge Says: $msg"),LoadingAnimationWidget.newtonCradle(
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
      /*BasicDialogAction(
        title: Text("RETRY"),
        onPressed: () {
          retry_stat=true;
          Navigator.pop(bctx);
        },
      )*/
    ],
  ),
);

return retry_stat;
}

Future<void> initFB() async
{
    print("started init");
    messaging = FirebaseMessaging.instance;
    print("init firebase");
NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
);

/*
FirebaseMessaging.onMessage.listen((RemoteMessage rsm) 
{ 
  var sms = rsm.data;
  print("fb received message is $sms");
});
*/
 


}

@pragma('vm:entry-point')
Future<void> fbh(RemoteMessage message) async 
{
  FlutterRingtonePlayer.stop();
  final SharedPreferences xprefs = await SharedPreferences.getInstance();
  /*await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
*/
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
         print('Got a message whilst in the background!');

            FlutterRingtonePlayer.play(
						android: AndroidSounds.notification,
						ios: IosSounds.glass,
						looping: false, // Android only - API >= 28
						volume: 0.1, // Android only - API >= 28
						asAlarm: false, // Android only - all APIs
			);

           
            var fb_data = message.data;
            print('back Message data: ${message.data}');
            
            String cmd = fb_data["cmd"];
          
          
            print("cmd value is $cmd");
          switch(cmd)
          {
            case "order_cmd":
            await xprefs.reload();
            List<String> bgdrivers = xprefs.getStringList("drivers") as List<String>;

            bgdrivers.add(fb_data["message"]);
            await xprefs.remove("drivers");
            await xprefs.setStringList("drivers", bgdrivers);
            await xprefs.setString("fb_cmd","order_add");
            /*
            List<String> xbgdrivers = xprefs.getStringList("drivers") as List<String>;
            for (String xdriver_content in xbgdrivers)
            {
                print("got driver drivers_list $xdriver_content");
            }
            */
            /*var order_json = jsonDecode(fb_data["message"]);
            //viewSet(3);
            active_orders.add(order_json);
            order_count = order_count+1;
            String ordid = order_json['order_id'];
            print("order_name: $ordid");
            var order_details = order_json["order_details"];
            double lator = order_details["customer_coords"][0];
            print("order latitude $lator");
            */
            if (message.notification != null)
            {
                      print('Message also contained a notification: ${message.notification}');
            }
            //eventsman.fire(Lateman("me"));
            //showView = true;
            /*
            String xpmsg = xprefs.getString("msg") as String;
            
            print("get main background message $xpmsg"); 
            */

            //print("show view set to to $showView");
            //fireup("yes");
            print("Handling a background message: ${message.messageId}");
            
       
            print("back message finished");
          break;

          case "order_del":
            await xprefs.reload();
            //List<String> bgdrivers = xprefs.getString("drivers") as List<String>;
            String fb_cmd = "order_del";
            //await xprefs.remove("drivers");
            await xprefs.setString("order_payload",fb_data["message"]);
            await xprefs.setString("fb_cmd", fb_cmd);
           

            print("order_del finished");
          break;
          }

          bool read_status = false;
          
         
            await xprefs.reload();
            read_status = xprefs.getBool("read_status") as bool;
            while(read_status==false)
            {
              await xprefs.reload();
              read_status = xprefs.getBool("read_status") as bool;
              print("read state is: $read_status");
              if(read_status==true)
              {
                print("read status updated");
                break;
              }
            }
             xprefs.setBool("read_status",false);
            FlutterRingtonePlayer.stop();
            
            
}

class User extends StatefulWidget
{
  User(String ausernames,String auser_digits,String auser_type,auscreenWidth,auscreenHeight,HyperTrack ht,LatLng current_pos)//LocationData current_pos)
  {
      c_pos = LatLng(current_pos.latitude as double,current_pos.longitude as double);
      
      print("current user position is: $c_pos and type is: $type");
      
      //hypertrackSdk = ht;
      map_url = "amap_url";
      usernames = ausernames;
      user_digits = auser_digits;
      user_type = auser_type;
      uscreenHeight = auscreenHeight;
      uscreenWidth = auscreenWidth;
      uscreenRatio = auscreenHeight/auscreenWidth;

      hypertrackSdk.sync();
      hypertrackSdk.setAvailability(true);
      hypertrackSdk.startTracking();
      
      hypertrackSdk.sync();

      //hypertrackSdk.setName("user_$user_digits");
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async
      {
            //FlutterRingtonePlayer.playNotification();
            FlutterRingtonePlayer.play(
						android: AndroidSounds.notification,
						ios: IosSounds.glass,
						looping: false, // Android only - API >= 28
						volume: 0.1, // Android only - API >= 28
						asAlarm: false, // Android only - all APIs
			);
            print('Got a message whilst in the foreground!');
            var fb_data = message.data;
            print('fore Message data: ${message.data}');
            
            String cmd = fb_data["cmd"];
            print("cmd value is $cmd");

          switch(cmd)
          {
            case "order_cmd":
            var order_json = jsonDecode(fb_data["message"]);
            rider_order_data = order_json;
            print("foreground message: $order_json");
            //viewSet(3);
            //active_orders.add(order_json);
            active_order = order_json;
            //order_count = order_count+1;
            String ordid = order_json['order_id'];
            print("order_name: $ordid");
            //var order_details = order_json["order_details"];
           // print("user order details received: $order_details");
            //double lator = order_details["customer_coords"][0];
            //print("order latitude $lator");

  
           // double lator = order_details["customer_coords"][0];
            //print("order latitude $lator");
            viewSet(5);
            if (message.notification != null)
            {
                      print('Message also contained a notification: ${message.notification}');
            }

            break;

            case "order_del":
                //await prefs.remove("drivers");
                order_meta = jsonDecode(fb_data["message"]);
                active_order = {};
                active_orders=[];
                viewSet(0);
              break;

          }

          FlutterRingtonePlayer.stop();
      }
      );

      FirebaseMessaging.onBackgroundMessage(fbh);

       

  }
      
  
/*
  @override
  void initState() async
  {
    super.initState();
    
  }
  */

  @override
  User_view createState()
  {
    return User_view();
  }
}

class User_view extends State<User>  with WidgetsBindingObserver
{
  
  int type = 0;
  
  int getType()
  {
    return type;
  }

  int incType()
  {
    int itype = type;
    setState(() 
    {
      if(type<6)
      {
        type = type +1;
      }
      
    });
    print("i type is : $type");
    return itype;
  }

  void setType(int atyp)
  {
    //int itype = type;
    setState(() 
    {
      //if(type<6)
      //{
        type = atyp;
      //}
      
    });
    print("i type is : $type");
    //return atyp;
  }

  void decType()
  {
    setState(() 
    {
      if(type >= 0)
      {
        type = type - 1;
      }
      
    });
  }

  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    user_map = MapView(getType,c_pos);
    print("started user_ui");
    settype = setType;
    viewSet = setType;
   
    //initHyperTrack();
    /*
    hypertrackSdk.startTracking();
    hypertrackSdk.setAvailability(true);
    hypertrackSdk.setName("user_$user_digits");
    */
    /*
    final initHyper = initHyperTrack;
    Future<void> initMe() async
    {
      //await initHyperTrack();
      await initHyper;
    }

    initMe();

    print("hyper track finished");

    
    while(( hypertrack_status == false))
    {

    }
    print("hyper track wait broken");
    hypertrackSdk.startTracking();
    */
    
  }

    @override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  if(state == AppLifecycleState.resumed){
    //print("app is back to the foreground $showView");
    /*
    if(showView == true)
    {
      viewSet(3);
      showView = false;
      print("\nview set");
    }
    */
    ///await prefs.setString("fb_cmd","order_add");
    await prefs.reload();
    String fbcmd_type = prefs.getString("fb_cmd") as String;

    switch (fbcmd_type)
    {
      case "order_add":
    List<String> xdrivers_list = prefs.getStringList("drivers") as List<String>;
    if (xdrivers_list.length>0)
    {
      //FlutterRingtonePlayer.stop();
      await prefs.setBool("read_status",true);
      print("some back data here");
    }
    else
    {
      print("no back data");
    }
    //if(xdrivers_list.length>0)
    //{
      for (String xdriver_content in xdrivers_list)
      {
        print("got driver drivers_list $xdriver_content");

            var order_json = jsonDecode(xdriver_content);
            
            //active_orders.add(order_json);
            //order_count = order_count+1;
            active_order = order_json;
            String ordid = order_json['order_id'];
            print("order_name: $ordid");
            print("user order $order_json");
           // var order_details = order_json["order_details"];
           // print("user order details received: $order_details");
           // double lator = order_details["customer_coords"][0];
            //print("order latitude $lator");
            viewSet(5);
            //xdrivers_list.removeAt(0);
            await prefs.remove("drivers");
            await prefs.setStringList("drivers",drivers_list);
            await prefs.setString("fb_cmd","");
      }
      print("list iteration finished");

      break;
      case "order_del":
        String order_payload_str = prefs.getString("order_payload") as String;
        var order_dta_json = jsonDecode(order_payload_str);

        order_meta = order_dta_json;

        await prefs.setBool("read_status",true);
        print("some order deleted");
        //await prefs.remove("drivers");
        await prefs.setStringList("drivers",drivers_list);
        //active_order = {};
        active_orders=[];
        viewSet(6);
        await prefs.setString("fb_cmd","");
      break;
    }

    
      
   // }
   // else
   // {
   //   print("drivers list empty");
   // }
  }
}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
}

  Future<void> initHyperTrack() async
  {
    
    if(hypertrackSdk!=null)
    {
      print("hyper track loading okay");
      hypertrackSdk.sync();
      hypertrackSdk.startTracking();
      hypertrackSdk.setAvailability(true);
      hypertrack_status = true;
      print("\ntracking started");
    }
    else
    {
      print("error loading hyper track");
    }
  }
  @override
  Widget build(BuildContext context)
  {
    user_main_ctx = context;
    return MaterialApp
            (
              title: usernames,
              home: Scaffold
              (
                appBar: AppBar(toolbarHeight: uscreenHeight*0.04,title: Text("Hello $usernames\t$user_digits",style: TextStyle(color: Colors.yellow,fontSize: uscreenRatio*9,fontWeight: FontWeight.bold),),backgroundColor: Color.fromARGB(249, 4, 48, 116)),
                body: Container(
                color: Colors.black,
                child:Stack
                (
                  children: 
                  [
                    /*Container
                    (
                      //decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                      child: Text("\nNAMES: $usernames\nTEL.NO: $user_digits", style: TextStyle(color: Colors.white, fontSize: (uscreenRatio*10),fontWeight: FontWeight.w900))
                    ),*/
                    
                   /* Container(
                      height: uscreenHeight*0.9,
                      width: uscreenWidth*0.9,
                      child: OpenStreetMapSearchAndPick(
                            center: LatLong(0.3222496209212994,32.56208181381226),
                           // buttonColor: Colors.blue,
                           /// buttonText: 'get pos',
                            
                            onPicked: (pickedData){print("thus");})
                    ),*/
                    Container
                    (
                      height: uscreenHeight*0.9,
                      width: uscreenWidth,
                      child: type==3?MainMap(order_data["order"]["track_point"]):(type==5 || type==6)?MainMap(active_order["track_point"]):user_map,//MapView(getType)//MapScreen()//
                    ),
                    Column(
                    children: [Container
                    (
                      alignment: Alignment.center,
                      color: Color.fromARGB(249, 4, 48, 116),
                     // margin: EdgeInsets.only(top: uscreenHeight*0.003),
                     child:Center(
                      child:Row(
                      children:[ Container
                      (margin:EdgeInsets.only(left: screenWidth*0.2),child:Text("ORDER RIDE",style: TextStyle(color: Color.fromARGB(255, 245, 229, 10),fontSize: uscreenRatio*9,fontWeight: FontWeight.bold))),UserLoadingVW()])
                    ))
                    ,
                    Container
                    (
                       color: Color.fromARGB(249, 4, 48, 116),
                       //margin: EdgeInsets.only(top: uscreenHeight*0.01),
                       child: Row(
                       
                       children: [
                                  type==2?Order_vw(decType,incType):type==1?ChooseDest(decType,incType):type==3?RiderDetails_vw_walk():type==4?RiderDetails():type==5?RiderDetails_x():type==6?OrderData_vw():ChoosePick(incType),
                                  ]
                    ))
                  ])

                  ],
                )
               )
              )
            );
  }
}


class UserLoadingVW extends StatefulWidget
{
  UserLoadingAnime createState()
  {
    return UserLoadingAnime();
  }

}

class UserLoadingAnime extends State<UserLoadingVW>
{

    void setShowLoading(bool load_state)
    {
      setState((){isusershowloading=load_state;});
    }
  @override
  Widget build(BuildContext context)
  {
    usershowLoader = setShowLoading;
    if(isusershowloading==true)
    {
       return Container(
      margin: EdgeInsets.only(left: (screenWidth*0.3)),
      width: screenWidth*0.01,
      child:LoadingAnimationWidget.beat(
      color: Colors.white,
      size: (screenHeight/screenWidth)*(10),
    ));
    }
    return Container(color:Color.fromARGB(249, 4, 48, 116));
   
   
  }
  //return Container();
}

class ChooseDest extends StatelessWidget
{
  late VoidCallback decType;
  late dynamic incType;
  ChooseDest(this.decType,this.incType)
  {

  }

  @override
  Widget build(BuildContext context)
  {

    return Row
    (
      children: 
      [
        Text("Please Choose Your Destination Below: ",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Container
        (
          margin: EdgeInsets.only(right: uscreenWidth*(0.008)),
          child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),onPressed: (decType), child: Text("PREVIOUS"))
        ),
        Container
        (
            child: ElevatedButton
            (
              style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),
              onPressed:()
              {
                int itype = incType();
                print("\n\ndest itype is $itype");
                LatLng lastmark = user_map.getLastMark(itype);
                post_coords[itype] = lastmark;
                print("\n\ndest mark ${lastmark.toString()}");
              }, 
              child: Text("NEXT")
            )
        )
      ],
    );
  }
}

class ChoosePick extends StatelessWidget
{
  late VoidCallback decType;
  late dynamic incType;

  ChoosePick(this.incType)
  {

  }

  @override
  Widget build(BuildContext context)
  {

    return Row
    (
      children: 
      [
        Text("Please Choose Your Pickup Below: ",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Container
        (
            child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),
            onPressed:()
            {
              int itype = incType();
              print("\n\nitype is $itype");
              LatLng lastmark = user_map.getLastMark(itype);
              post_coords[itype] = lastmark;
              print("\n\nlast mark is ${lastmark.toString()}");
            },
             child: Text("NEXT"))
        )
      ],
    );
  }
}

class Order_vw extends StatelessWidget
{
  late VoidCallback decType;
  late VoidCallback incType;

  void findWalker() async
  {
    usershowLoader(true);
    //post_coords[0];
    
    
    var user_dta = 
    {
      "latitude":post_coords[0].latitude,
      "longitude":post_coords[0].longitude,
      "to_latitude":post_coords[1].latitude,
      "to_longitude":post_coords[1].longitude,
      "user_price":"0",
      "user_tel":user_digits,
      "dev_id":dev_id
    };

    var reply_data = await postData("lookwalker",user_dta);

    if(reply_data.length>0)
    {
    usershowLoader(false);
    int status_code = reply_data["status"];
    
    
    switch(status_code)
    {
      case 200:
          order_data = reply_data;
          print("print data $order_data");
          incType();
          
      break;

      case 400:
          String msg = reply_data["message"];
          userpopAlert(user_main_ctx,msg);
         // msgbox.setMsg(msg);
      break;

      case 401:

      break;
    }
    print("\n\nreply data ${reply_data.toString}");
    }
    else
    {
      print("error in user connection");
      userpopAlert(user_main_ctx,"connection error");
    }
    
  }

  void findRider() async
  {
    //post_coords[0];
    usershowLoader(true);
    hypertrackSdk.startTracking();
    var user_dta = 
    {
      "latitude":post_coords[0].latitude,
      "longitude":post_coords[0].longitude,
      "to_latitude":post_coords[1].latitude,
      "to_longitude":post_coords[1].longitude,
      "user_price":"0",
      "dev_id":dev_id
    };

    var reply_data = await postData("lookrider",user_dta);

    if(reply_data.length>0)
    {
      usershowLoader(false);
    int status_code = reply_data["status"];
    
    //print("gotten riders: $")
    switch(status_code)
    {
      case 200:
          rider_index = 0;
          print("active rider $reply_data");
          active_drivers = reply_data["message"];
          order_data = active_drivers[rider_index]["details"];
          print("using order $order_data");
          settype(4);
          //incType();
      break;

      case 400:
          String msg = reply_data["message"];
          userpopAlert(user_main_ctx,msg);
          //msgbox.setMsg(msg);
      break;

      case 401:

      break;

    }
    print("\n\nreply data ${reply_data.toString}");
    }
    else
    {
      print("error connection in useer");
      userpopAlert(user_main_ctx,"user connection error");
    }
    
  }

  Order_vw(this.decType,this.incType)
  {

  }

  @override
  Widget build(BuildContext context)
  {

    return Column
    (
      children: 
      [
        //Text("Order Details",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
       // Text("Order Distance: 5 km",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
       // Text("Order Price: 5000/=",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        //msgbox,
        Row(
            children: [
                      
                      Container
                              (
                                margin: EdgeInsets.only(right: uscreenWidth*(0.008)),
                                child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),onPressed: (decType), child: Text("CANCEL"))
                              ),
                      Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),
                                  onPressed:
                                  (){
                                    findRider();
                                    //incType();
                                    }, child: Text("FIND RIDER")
                                )
                              ),
                              Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromARGB(249, 4, 48, 116)),
                                  onPressed:
                                  (){
                                    findWalker();
                                    //incType();
                                    }, child: Text("WALK")
                                )
                              )
                      ])
              
      ],
    );
  }
}

class RiderDetails extends StatefulWidget
{
  
  RiderDetails_vw createState()
  {

    return RiderDetails_vw();
  }

}

class RiderDetails_vw extends State<RiderDetails>
//lessWidget
{
  int rider_count = 0;
  
  void cancelRide() async
  {
    //post_coords[0];
    usershowLoader(true);
    
    var user_dta = 
    {
      //"dev_handle":order_data["handle"],
      "order_id":  order_data["order_id"],
      "dev_id":dev_id
    };

    var reply_data = await postData("cancelOrder",user_dta);

    if(reply_data.length>0)
    {
      usershowLoader(false);
    int status_code = reply_data["status"];
    
    
    switch(status_code)
    {
      case 200:
         
        
          print("order canceled $reply_data");
          settype(0);
          
      break;

      case 400:
          String msg = reply_data["message"];
          userpopAlert(user_main_ctx,msg);
          //msgbox.setMsg(msg);
      break;

      case 401:

      break;
    }
    //print("\n\nreply data ${reply_data.toString}");
    }
    else
    {
      print("error user connection");
      userpopAlert(user_main_ctx,"user connection error");
    }
    
  }


  void approve() async
  {
    usershowLoader(true);
    //post_coords[0];
    String order_id = order_data["order_id"];
    print("using order id $order_id");
    var user_dta = 
    {
      //"dev_handle":order_data["order"]["handle"],
      "order_id":order_id,
      "dev_id":dev_id,
      "cursor": rider_index
    };

    var reply_data = await postData("approv_rider",user_dta);

    if(reply_data.length>0)
    {
      usershowLoader(false);
    int status_code = reply_data["status"];
    
    
    switch(status_code)
    {
      case 200:
         

          print("order canceled $reply_data");
          //settype(0);
          
      break;

      case 400:
          String msg = reply_data["message"];
          userpopAlert(user_main_ctx,msg);
         // msgbox.setMsg(msg);
      break;

      case 401:

      break;
    }
    //print("\n\nreply data ${reply_data.toString}");
    }
    else
    {
      print("error in user connection");
      userpopAlert(user_main_ctx,"user connection error");
    }
    
  }

  void incRider()
  {
  setState(()
  {
    rider_index = rider_index+1;
    print("rider index $rider_index");
    order_data = active_drivers[rider_index]["details"];
  });
  }

  @override
  Widget build(BuildContext context)
  {
    late var rider_name = active_drivers[rider_index]["details"]["name"];
    print("rider index reload $rider_index and $active_drivers");
    //"Mule kwa";
    late var rider_tel= active_drivers[rider_index]["details"]["contact"];
    //rider_index = 0;
    late var xrider_coords = active_drivers[rider_index]["details"]["geo_data"]["coordinates"];

    user_map.vwpage.addMarker(2,LatLng(xrider_coords[1],xrider_coords[0]));
    return Container(
      width: uscreenWidth*0.8,
      height: uscreenHeight*0.1,
      child: ListView
    (
      children: 
      [
        Text("Rider name: $rider_name",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Text("Rider Contact: $rider_tel",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Row( children:[                      Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromRGBO(250, 4, 4, 0.976)),
                                  onPressed:
                                  (){
                                    cancelRide();
                                    
                                    }, child: Text("CANCEL RIDE")
                                )
                              ),
                              Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromRGBO(4, 250, 70, 0.976)),
                                  onPressed:
                                  (){
                                    //cancelRide();
                                    approve();
                                    }, child: Text("ALLOW RIDER",style:TextStyle(color:Colors.black))
                                )
                              ),
                              Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromRGBO(211, 207, 234, 0.973)),
                                  onPressed:
                                  (){
                                     incRider();
                                    
                                    }, child: Text("NEXT RIDER",style:TextStyle(color:Colors.black))
                                )
                              )])

       // ElevatedButton(onPressed: null, child: Text("CANCEL ORDER"))
      ],
      
    )
    );
  }
}



class OrderData_vw extends StatelessWidget
//lessWidget
{
  //var order_meta = {};
  OrderData_vw()
  {
    print("order_meta data is $order_meta");
  }

  @override
  Widget build(BuildContext context)
  {
    late var rider_name = active_drivers[rider_index]["details"]["name"];
   
    late var distance_covered = order_meta["distance"];
    //"Mule kwa";
    late var duration= order_meta["duration"];
    //rider_index = 0;
    var price = order_meta["price"];
    return Container(
      width: uscreenWidth*0.8,
      height: uscreenHeight*0.2,
      child: ListView
    (
      children: 
      [
        Text("\t\t\t Hello World, This is your Ride Summary",style: TextStyle(color: Color.fromARGB(255, 0, 246, 82),fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Text("Rider name: $rider_name",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Text("Ride Price: $price",style: TextStyle(color: Color.fromARGB(255, 193, 255, 47),fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Text("Ride Distance: $distance_covered \nRide duration: $duration",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Row( children:[                    
                              Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromRGBO(211, 207, 234, 0.973)),
                                  onPressed:
                                  (){
                                     
                                    viewSet(0);
                                    }, child: Text("OKAY",style:TextStyle(color:Colors.black))
                                )
                              )])

       // ElevatedButton(onPressed: null, child: Text("CANCEL ORDER"))
      ],
      
    )
    );
  }
}


class RiderDetails_x extends StatefulWidget
{
  
  RiderDetails_ride createState()
  {

    return RiderDetails_ride();
  }

}

class RiderDetails_ride extends State<RiderDetails_x>
//lessWidget
{
  int rider_count = 0;
  
  void cancelRide() async
  {
    usershowLoader(true);
    //post_coords[0];
    
    var user_dta = 
    {
      //"dev_handle":order_data["handle"],
      "order_id":  order_data["order_id"],
      "dev_id":dev_id
    };

    var reply_data = await postData("cancelOrder",user_dta);

    if(reply_data.length>0)
    {
      usershowLoader(false);
    int status_code = reply_data["status"];
    
    
    switch(status_code)
    {
      case 200:
         
        
          print("order canceled $reply_data");
          settype(0);
          
      break;

      case 400:
          String msg = reply_data["message"];
          //msgbox.setMsg(msg);
          userpopAlert(user_main_ctx,msg);
      break;

      case 401:

      break;
    }
    //print("\n\nreply data ${reply_data.toString}");
    }
    else
    {
      print("user connection error");
      userpopAlert(user_main_ctx,"usr connection error");
    }
    
  }


  void approve() async
  {
    usershowLoader(true);
    //post_coords[0];
    String order_id = order_data["order_id"];
    print("using order id $order_id");
   var user_dta = 
    {
      "order_id":order_data["order_id"],
      "dev_id":dev_id,
      "cursor": 0,
      "order_cmd":200
    };

    var reply_data = await postData("orders",user_dta);

    if(reply_data.length>0)
    {
    usershowLoader(false);
    int status_code = reply_data["status"];
    
    
    switch(status_code)
    {
      case 200:
         

          print("order canceled $reply_data");
          //settype(0);
          
      break;

      case 400:
          String msg = reply_data["message"];
          //msgbox.setMsg(msg);
          userpopAlert(user_main_ctx,msg);
      break;

      case 401:

      break;
    }
    //print("\n\nreply data ${reply_data.toString}");
    }
    else
    {
      print("connection user error");
      userpopAlert(user_main_ctx,"user connection error");
    }
    
  }

  void incRider()
  {
  setState(()
  {
    rider_index = rider_index+1;
    print("rider index $rider_index");
  });
  }

  @override
  Widget build(BuildContext context)
  {
    late var rider_name = active_drivers[rider_index]["details"]["name"];
    print("rider index reload $rider_index and $active_drivers");
    //"Mule kwa";
    late var rider_tel= active_drivers[rider_index]["details"]["contact"];
    //rider_index = 0;
    late var xrider_coords = active_drivers[rider_index]["details"]["geo_data"]["coordinates"];

    user_map.vwpage.addMarker(2,LatLng(xrider_coords[1],xrider_coords[0]));
    return Container(
      width: uscreenWidth*0.8,
      height: uscreenHeight*0.1,
      child: ListView
    (
      children: 
      [
        Text("Rider name: $rider_name",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Text("Rider Contact: $rider_tel",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Row( children:[                     /* Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromRGBO(250, 4, 4, 0.976)),
                                  onPressed:
                                  (){
                                    cancelRide();
                                    
                                    }, child: Text("CANCEL RIDE")
                                )
                              ),*/
                              Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromRGBO(4, 250, 70, 0.976)),
                                  onPressed:
                                  (){
                                    //cancelRide();
                                    approve();
                                    }, child: Text("COMPLETE RIDER",style:TextStyle(color:Colors.black))
                                )
                              )/*,
                              Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromRGBO(211, 207, 234, 0.973)),
                                  onPressed:
                                  (){
                                     incRider();
                                    
                                    }, child: Text("NEXT RIDER",style:TextStyle(color:Colors.black))
                                )
                              )*/
                              ])

       // ElevatedButton(onPressed: null, child: Text("CANCEL ORDER"))
      ],
      
    )
    );
  }
}


class RiderDetails_vw_walk extends StatelessWidget
{

  void cancelRide() async
  {
    usershowLoader(true);
    //post_coords[0];
    
    var user_dta = 
    {
      "dev_handle":order_data["order"]["handle"],
      "dev_id":dev_id
    };

    var reply_data = await postData("cancelOrder",user_dta);

    if(reply_data.length>0)
    {
    usershowLoader(false);
    int status_code = reply_data["status"];
    
    
    switch(status_code)
    {
      case 200:
         
        
          print("order canceled $reply_data");
          settype(0);
          
      break;

      case 400:
          String msg = reply_data["message"];
          //msgbox.setMsg(msg);
          userpopAlert(user_main_ctx,msg);
      break;

      case 401:

      break;
    }
    //print("\n\nreply data ${reply_data.toString}");
    }
    else
    {
      print("connection user error");
      userpopAlert(user_main_ctx,"user connection error");
    }
    
  }
  @override
  Widget build(BuildContext context)
  {
    late var rider_name = "Mule kwa";
    late var rider_tel=0;
    late LatLng rider_coords;
    return Container(
      width: uscreenWidth*0.8,
      height: uscreenHeight*0.1,
      child: ListView
    (
      children: 
      [
        Text("Rider name: $rider_name",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Text("Rider Contact: $rider_tel",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Row( children:[                      Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromRGBO(250, 4, 4, 0.976)),
                                  onPressed:
                                  (){
                                    cancelRide();
                                    
                                    }, child: Text("CANCEL RIDE")
                                )
                              ),
                              Container
                              (
                                child: ElevatedButton
                                (
                                  style: ElevatedButton.styleFrom(primary: Color.fromRGBO(4, 250, 70, 0.976)),
                                  onPressed:
                                  (){
                                    cancelRide();
                                    
                                    }, child: Text("COMPLETE RIDE",style:TextStyle(color:Colors.black))
                                )
                              )])

       // ElevatedButton(onPressed: null, child: Text("CANCEL ORDER"))
      ],
      
    )
    );
  }
}


class MsgBox extends StatefulWidget
{
  late MsgView msgvw = MsgView();
  @override
  void initState()
  {
    //msgvw = MsgView();
  }

  void setMsg(msg)
  {
    msgvw.setMsg(msg);
  }

  @override
  MsgView createState()
  {
    return msgvw;
  }
}

class MsgView extends State<MsgBox>
{
 String msg_data = "";
  void setMsg(msg)
  {
    setState(() {
      msg_data = msg;
    });
  }
  @override
  Widget build(BuildContext bc)
  {
    return Container
    (
      width:uscreenWidth,
      color: Colors.green,
      child: Text(msg_data,style: TextStyle(color:Colors.white))
    );
  }
}