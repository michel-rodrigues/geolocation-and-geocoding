import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(GeolocationDemo());

class GeolocationDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geolocator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Geolocator and Google Maps Demo')),
        body: GeolocatorStreamDemo(),
      ),
    );
  }
}

class GeolocatorStreamDemo extends StatefulWidget {

  @override
  _GeolocatorStreamDemoState createState() => _GeolocatorStreamDemoState();
}

class _GeolocatorStreamDemoState extends State<GeolocatorStreamDemo> {
  GoogleMapController mapController;
  Position currentPosition;

  @override
  void initState() {

    super.initState();

    getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
      .then((position) => currentPosition = position)
      .catchError((_) => getLastKnownPosition().then((position) => currentPosition = position));

    getPositionStream(desiredAccuracy: LocationAccuracy.high).listen((Position position) {
      mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            bearing: 270.0,
            tilt: 30.0,
            zoom: 17.0,
          ),
        ),
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child:
          GoogleMap(
            mapType: MapType.hybrid,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                currentPosition?.latitude ?? 0,
                currentPosition?.longitude ?? 0)
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: StreamBuilder(
            stream: getPositionStream(desiredAccuracy: LocationAccuracy.high),
            builder: (context, snapshot) {
              return Center(
                child: snapshot.hasData
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Location: ${snapshot.data.latitude}, ${snapshot.data.longitude}'),
                      Text('Timestamp: ${snapshot.data.timestamp}'),
                    ],
                  )
                  : CircularProgressIndicator(),
              );
            }
          ),
        ),
      ],
    );
  }

}