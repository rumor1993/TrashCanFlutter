import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<NaverMapController> _controller = Completer();
  List<Marker> _markers = [];

  addMarker() {
    OverlayImage.fromAssetImage(
      assetName: 'assets/place-marker.png',
    ).then((image) {
      setState(() {
        _markers.add(Marker(
            markerId: 'id',
            position: LatLng(37.581915, 127.0810617),
            captionText: "커스텀 아이콘",
            captionColor: Colors.indigo,
            captionTextSize: 20.0,
            icon: image,
            alpha: 0.8,
            captionOffset: 30,
            anchor: AnchorPoint(0.5, 1),
            width: 45,
            height: 45,
            infoWindow: '인포 윈도우'));
      });
    });
  }

  getData(url) async {
    var response = await http.get( Uri.parse(url) );
    var result = jsonDecode(utf8.decode(response.bodyBytes));

    print(result[0]["id"]);
    print(result[0]["region"]);
    print(result[0]["address"]);
    print(result[0]["location"]);

    result.forEach((item) => {
      OverlayImage.fromAssetImage(
       assetName: 'assets/icons8-trash-50.png',
      ).then((image) {
        _markers.add(Marker(
            markerId: 'id',
            position: LatLng(37.581915, 127.0810617),
            captionText: "커스텀 아이콘",
            captionColor: Colors.indigo,
            captionTextSize: 20.0,
            icon: image,
            alpha: 0.8,
            captionOffset: 30,
            anchor: AnchorPoint(0.5, 1),
            width: 20,
            height: 20,
            infoWindow: '현위치'));
      })
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData("http://172.30.1.43:8080/trash?region=중랑구");
    addMarker();
  }

  getLocation() async {
    // var _locationData = await Location().getLocation();
    // print(_locationData);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text('쓰레기통 찾기'),
        ),
        body: NaverMap(
          onMapCreated: _onMapCreated,
          markers: _markers,
          initLocationTrackingMode: LocationTrackingMode.Follow,
          locationButtonEnable: true,
          onCameraIdle: _onCameraIdle,
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (tapNumber){
            setState(() {
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: '지',
                activeIcon: Icon(Icons.map_outlined)
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: '설정',
                activeIcon: Icon(Icons.settings_outlined)
            ),
          ],
        ),
      ),
    );
  }


  void _onCameraIdle() {
    print('카메라 움직임 멈춤');
  }

  /// 지도 생성 완료시
  void _onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }

}


