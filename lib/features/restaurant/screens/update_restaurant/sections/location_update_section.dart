import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/feedback/global_feedback_dialog.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/restaurant_common_widgets.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/bloc/update_restaurant_cubit.dart';
import 'package:halalhub_restaurant/features/restaurant/services/restaurant_map_service.dart';

class LocationUpdateSection extends StatefulWidget {
  const LocationUpdateSection({super.key, required this.mapService});

  final RestaurantMapService mapService;

  @override
  State<LocationUpdateSection> createState() => _LocationUpdateSectionState();
}

class _LocationUpdateSectionState extends State<LocationUpdateSection> {
  final Completer<GoogleMapController> _controller = Completer();

  Future<void> _goToCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      showGlobalFailureFeedback(context, message: 'Location service is disabled.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      showGlobalFailureFeedback(context, message: 'Location permission is not granted.');
      return;
    }

    final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
    if (!mounted) return;

    final target = LatLng(position.latitude, position.longitude);
    context.read<UpdateRestaurantCubit>().setLocation(target);
    if (_controller.isCompleted) {
      final map = await _controller.future;
      await map.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return BlocBuilder<UpdateRestaurantCubit, UpdateRestaurantState>(
      buildWhen: (p, c) => p.selectedLatLng != c.selectedLatLng || p.locationConfirmed != c.locationConfirmed,
      builder: (context, state) {
        final mapHeight = context.wOf(280, w).clamp(220.0, 300.0);
        return Column(
          children: [
            Container(
              height: mapHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: StaticColors.cE2E2E2),
              ),
              clipBehavior: Clip.antiAlias,
              child: GoogleMap(
                initialCameraPosition: state.selectedLatLng != null ? CameraPosition(target: state.selectedLatLng!, zoom: 14) : widget.mapService.initialCamera(),
                onMapCreated: (controller) {
                  if (!_controller.isCompleted) {
                    _controller.complete(controller);
                  }
                },
                onTap: (pos) => context.read<UpdateRestaurantCubit>().setLocation(pos),
                markers: widget.mapService.markersFor(state.selectedLatLng),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
