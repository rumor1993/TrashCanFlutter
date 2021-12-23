import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
        _markers.add(Marker(
            markerId: 'id',
            position: LatLng(37.5985707, 127.095467),
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
  }

  getData(url) async {
    var response = await http.get( Uri.parse(url) );
    var result = jsonDecode(utf8.decode(response.bodyBytes));
    var location;
    var x;
    var y;

    print(result[0]["id"]);
    print(result[0]["region"]);
    print(result[0]["address"]);
    print(result[0]["location"]);

    result.forEach((item) async => {
      location = await getGeocode(item['location']),
      y = double.parse(location[0]),
      x = double.parse(location[1]),

      OverlayImage.fromAssetImage(
       assetName: 'assets/icons8-trash-50.png',
      ).then((image) {
      setState(() {
        // var result2 = await getGeocode(result[0]["location"]);
        print("x: ${x} y: ${y}");
        // var x = double.parse(result2[0]);
        // var y = double.parse(result2[1]);

        _markers.add(Marker(
        markerId: 'id',
        position: LatLng(y, x),
        captionText: "커스텀 아이콘",
        captionColor: Colors.indigo,
        captionTextSize: 20.0,
        icon: image,
        alpha: 0.8,
        captionOffset: 30,
        anchor: AnchorPoint(0.5, 1),
        width: 30,
        height: 30,
        infoWindow: '현위치'));
        });
      print("_markers ${_markers.length}");
      })
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // addMarker();
    getData("http://127.0.0.1:8080/trash?region=중랑구");

  }

  getGeocode(address) async {
    var url =
    Uri.https('naveropenapi.apigw.ntruss.com', '/map-geocode/v2/geocode',
        {'query': address});

    Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-NCP-APIGW-API-KEY-ID': 'rnbocqpd3n',
    'X-NCP-APIGW-API-KEY': 'QYEGHpV6Ozckj9LP8yvrS0KDb0WVBMnXvAhuqUu4'
    };


    var response = await http.get(url,
      headers: headers);
    if (response.statusCode == 200) {
      var result = jsonDecode(utf8.decode(response.bodyBytes));
      // print("responseBody: ${utf8.decode(response.bodyBytes)}");

      print("responseBody ## ${result["addresses"][0]["x"]}");
      print("responseBody ## ${result["addresses"][0]["y"]}");
      return [result["addresses"][0]["y"],result["addresses"][0]["x"]];
    }
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
              print(_markers.length);
                _markers = _markers;
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


