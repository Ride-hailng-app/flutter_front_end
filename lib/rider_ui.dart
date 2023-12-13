import 'dart:convert';
import 'package:fl_test/main.dart';
import "package:flutter/material.dart";
import 'package:latlong2/latlong.dart';
//import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import "rider_map.dart";
//import "map_search.dart";
import "netwrk.dart";
import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/hypertrack.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

 late String usernames;
 
  late String user_digits;
  late String user_type;
  late double uscreenHeight = 1;
  late double uscreenWidth;
  late var uscreenRatio;
  late var type = 0;
  late MapView user_map;
  Map post_coords = {};
  late HyperTrack xhypertrackSdk;
  bool hypertrack_status = false;
  MsgBox msgbox = MsgBox();
  late LatLng c_pos;

  late var active_order;

late FirebaseMessaging messaging;



class Rider extends StatefulWidget
{
  Rider(String ausernames,String auser_digits,String auser_type,auscreenWidth,auscreenHeight,HyperTrack ht,LatLng current_pos)//LocationData current_pos)
  {
      c_pos = LatLng(current_pos.latitude as double,current_pos.longitude as double);
      
      print("current position is: $c_pos");
      xhypertrackSdk = ht;
      usernames = ausernames;
      user_digits = auser_digits;
      user_type = auser_type;
      uscreenHeight = auscreenHeight;
      uscreenWidth = auscreenWidth;
      uscreenRatio = auscreenHeight/auscreenWidth;
  }
  
/*
  @override
  void initState() async
  {
    super.initState();
    
  }
  */

  @override
  Rider_view createState()
  {
    return Rider_view();
  }
}

class Rider_view extends State<Rider>
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
      if(type<3)
      {
        type = type +1;
      }
      
    });

    return itype;
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
    user_map = MapView(getType,c_pos);
    print("started user_ui");
    //initHyperTrack();
    
    //xhypertrackSdk.startTracking();
    //xhypertrackSdk.setAvailability(false);
    //xhypertrackSdk.setName(usernames+"_"+user_digits);
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
    xhypertrackSdk.startTracking();
    */
    
  }


  Future<void> initHyperTrack() async
  {
    
    if(xhypertrackSdk!=null)
    {
      print("hyper track loading okay");
      //xhypertrackSdk.sync();
      xhypertrackSdk.startTracking();
      xhypertrackSdk.setAvailability(true);
      hypertrack_status = true;
      print("tracking started");
    }
    else
    {
      print("error loading hyper track");
    }
  }
  @override
  Widget build(BuildContext context)
  {print("screen is $uscreenWidth * $uscreenHeight");
    return MaterialApp
            (
              title: usernames,
              home: Scaffold
              (
                appBar: AppBar(title: Text("Hello $usernames\n$user_digits",style:TextStyle(fontSize: uscreenRatio*8)),backgroundColor: Color.fromARGB(249, 4, 48, 116),toolbarHeight: uscreenHeight*0.05),
                body: Container(
                color: Colors.black,
                child:Stack
                (
                children:[
                
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
                      height: uscreenHeight,
                      width: uscreenWidth,
                      child: user_map,//MapView(getType)//MapScreen()//
                    ),
                    Column
                (
                  children: 
                  [
                    /*Container
                    (
                      //decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                      child: Text("\nNAMES: $usernames\nTEL.NO: $user_digits", style: TextStyle(color: Colors.white, fontSize: (uscreenRatio*10),fontWeight: FontWeight.w900))
                    ),*/
                    Container
                    (
                      color: Color.fromARGB(249, 4, 48, 116),
                      //margin: EdgeInsets.only(top: uscreenHeight*0.01),
                      child: Center(child: Text("Find Customer",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*9,fontWeight: FontWeight.bold)))
                    ),
                    Container
                    (
                        color: Color.fromARGB(249, 4, 48, 116),
                       //margin: EdgeInsets.only(top: uscreenHeight*0.01),
                       child: Row(
                       
                       children: [
                                  type==2?Order_vw(decType,incType):type==1?ScanView(decType,incType):type==3?RiderDetails_vw():ChoosePick(incType)
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

class ScanView extends StatefulWidget
{

  late VoidCallback decType;
  late dynamic incType;
  ScanView(this.decType,this.incType)
  {

  }
  Scan_view createState()
  {
    return Scan_view(decType,incType);
  }
}

class Scan_view extends State<ScanView>
{
  void cancelScan() async
  {
    //post_coords[0];
   
    //xhypertrackSdk.setAvailability(true);
    //xhypertrackSdk.startTracking();
    //Result loc = await xhypertrackSdk.location;
   
    print("driver in action");
    
    //print("location is $loc");
    var user_dta = 
    {
      "latitude":post_coords[0].latitude,
      "longitude":post_coords[0].longitude,
      "to_latitude": 0,//post_coords[1].latitude,
      "to_longitude":0,//post_coords[1].longitude,
      "user_price":"0",
      "dev_id":dev_id
    };

    var reply_data = await postData("cancel_scan",user_dta);
    int status_code = reply_data["status"];
    
    
    switch(status_code)
    {
      case 200:
         // incType();
      break;

      case 400:
          String msg = reply_data["message"];
          msgbox.setMsg(msg);
      break;

      case 401:

      break;
    }
    print("\n\nreply data ${reply_data.toString}");
    
    
  }

  late VoidCallback decType;
  late dynamic incType;
  Scan_view(this.decType,this.incType)
  {

  }
  @override
  Widget build(BuildContext context)
  {
    return
      Column
      (
        children: 
        [
          Text(
            "Scanning please wait......",
            style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)
          ),
          ElevatedButton(style: ElevatedButton.styleFrom(primary: Color.fromARGB(248, 254, 6, 6)),
            onPressed:()
            {
              /*
              int itype = incType();
              print("\n\nitype is $itype");
              LatLng lastmark = user_map.getLastMark(itype);
              post_coords[itype] = lastmark;
              print("\n\nlast mark is ${lastmark.toString()}");
              */
              cancelScan();
              decType();
            },
             child: Text("CANCEL"))
        ],
      );
  }
}
//11rNJqLL5wDrRyhmbIH2TVQeJiEObLx398EKHoB7aq_e-RMtOGsc6Q
//001FA236-3678-480E-A6BE-E5DFB54F71EE
class ChoosePick extends StatelessWidget
{
  late VoidCallback decType;
  late dynamic incType;

  ChoosePick(this.incType)
  {

  }


  void findCustomer() async
  {
    //post_coords[0];
   
    xhypertrackSdk.setAvailability(true);
    xhypertrackSdk.startTracking();
    //Result loc = await xhypertrackSdk.location;
   
    print("driver in action");
    
    //print("location is $loc");
    var user_dta = 
    {
      "latitude":post_coords[0].latitude,
      "longitude":post_coords[0].longitude,
      "to_latitude": 0,//post_coords[1].latitude,
      "to_longitude":0,//post_coords[1].longitude,
      "user_price":"0"
    };

    var reply_data = await postData("lookrider",user_dta);
    int status_code = reply_data["status"];
    
    
    switch(status_code)
    {
      case 200:
         // incType();
      break;

      case 400:
          String msg = reply_data["message"];
          msgbox.setMsg(msg);
      break;

      case 401:

      break;
    }
    print("\n\nreply data ${reply_data.toString}");
    
    
  }

  @override
  Widget build(BuildContext context)
  {

    return Row
    (
      children: 
      [
        Text("Please Choose Your Stage Below : ",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*8,fontWeight: FontWeight.bold)),
        Container
        (
            child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Color.fromARGB(248, 0, 0, 0)),
            onPressed:()
            {
              int itype = incType();
              print("\n\nitype is $itype");
              LatLng lastmark = user_map.getLastMark(itype);
              post_coords[itype] = lastmark;
              print("\n\nlast mark is ${lastmark.toString()}");
              findCustomer();
            },
             child: Text("SCAN"))
        )
      ],
    );
  }
}

class Order_vw extends StatelessWidget
{
  late VoidCallback decType;
  late VoidCallback incType;

  void findRider() async
  {
    //post_coords[0];
    
    xhypertrackSdk.startTracking();
    xhypertrackSdk.setAvailability(true);
    //print("driver listening");
    
    var user_dta = 
    {
      "latitude":post_coords[0].latitude,
      "longitude":post_coords[0].longitude,
      "to_latitude":post_coords[1].latitude,
      "to_longitude":post_coords[1].longitude,
      "user_price":"0"
    };

    var reply_data = await postData("lookrider",user_dta);
    int status_code = reply_data["status"];
    
    
    switch(status_code)
    {
      case 200:
          incType();
      break;

      case 400:
          String msg = reply_data["message"];
          msgbox.setMsg(msg);
      break;

      case 401:

      break;
    }
    print("\n\nreply data ${reply_data.toString}");
    
    
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
        Text("Order Distance: 5 km",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Text("Order Price: 5000/=",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        msgbox,
        Row(
            children: [
                      
                      Container
                              (
                                margin: EdgeInsets.only(right: uscreenWidth*(0.008)),
                                child: ElevatedButton(style: ElevatedButton.styleFrom(primary: Color.fromARGB(248, 255, 5, 5)),onPressed: (decType), child: Text("CANCEL"))
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
                              )
                      ])
              
      ],
    );
  }
}

class RiderDetails_vw extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    late var rider_name = "Mulekwa";
    late var rider_tel=0;
    late LatLng rider_coords;
    return Container(
      width: uscreenWidth*0.8,
      height: uscreenHeight*0.06,
      child: ListView
    (
      children: 
      [
        Text("Rider name: $rider_name",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        Text("Rider Contact: $rider_tel",style: TextStyle(color: Colors.white,fontSize: uscreenRatio*10,fontWeight: FontWeight.bold)),
        ElevatedButton(onPressed: null, child: Text("CANCEL ORDER"))
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
