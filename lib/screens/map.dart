import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding_resolver/geocoding_resolver.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';


class MapSample extends StatefulWidget {
  String? idLocal;
  MapSample({this.idLocal});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  CollectionReference _locais = FirebaseFirestore.instance.collection("locais");
  GeoCoder geocoder = GeoCoder();
  Set<Marker> _marcadores = {};

  Future<void> _movimentarCamera() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
  }

  static CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 15,
  );

  _addMarcador(LatLng latLng) async {
    Address address = await geocoder.getAddressFromLatLng(latitude: latLng.latitude,
        longitude: latLng.longitude);
    String rua = address.addressDetails.road;
    Marker marcador = Marker(
        markerId: MarkerId("marcador-${latLng.latitude}=${latLng.longitude}"),
        position: latLng,
        infoWindow: InfoWindow(title: rua)
    );
    setState(() {
      _marcadores.add(marcador);
    });
    Map<String, dynamic> local = Map();
    local['titulo'] = rua;
    local['latitude'] = latLng.latitude;
    local['longitude'] = latLng.longitude;
    _locais.add(local);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _posicaoCamera,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _marcadores,
        onLongPress: _addMarcador,
      ),
    );
  }

  getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      return;
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      return;
    } else {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 15);
        _movimentarCamera();
      });
      print("latitude = ${position.latitude}");
      print("longitude = ${position.longitude}");

      // _addMarcador(LatLng(position.latitude, position.longitude));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.idLocal != null) {
      mostrarLocal(widget.idLocal);
    } else {
      getLocation();
    }
  }

  mostrarLocal(String? idLocal) async{
    DocumentSnapshot local = await _locais.doc(idLocal).get();
    String titulo = local.get("titulo");
    LatLng latLng = LatLng(local.get("latitude"), local.get("longitude"));
    setState(() {
      Marker marker = Marker(markerId:
      MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(title: titulo));
      _marcadores.add(marker);
      _posicaoCamera = CameraPosition(target: latLng, zoom: 15);
      _movimentarCamera();
    });
  }

}