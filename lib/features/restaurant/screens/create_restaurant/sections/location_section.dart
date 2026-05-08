import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/features/restaurant/services/restaurant_map_service.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/restaurant_common_widgets.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key, required this.availableWidth, required this.isTablet, required this.locationConfirmed, required this.selectedLatLng, required this.mapService, required this.onMapCreated, required this.onMapTap, required this.zoomIn, required this.zoomOut, required this.myLocationTap, required this.continueButton});

  final double availableWidth;
  final bool isTablet;
  final bool locationConfirmed;
  final LatLng? selectedLatLng;
  final RestaurantMapService mapService;
  final void Function(GoogleMapController controller) onMapCreated;
  final void Function(LatLng position) onMapTap;
  final VoidCallback zoomIn;
  final VoidCallback zoomOut;
  final VoidCallback myLocationTap;
  final Widget continueButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: isTablet ? context.wOf(240, availableWidth) : context.wOf(250, availableWidth),
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              clipBehavior: Clip.antiAlias,
              child: GoogleMap(
                initialCameraPosition: mapService.initialCamera(),
                onMapCreated: onMapCreated,
                markers: mapService.markersFor(selectedLatLng),
                onTap: onMapTap,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()), //
                },
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MapZoomButton(icon: Icons.add, onTap: zoomIn),
                      SizedBox(height: context.wOf(8, availableWidth)),
                      MapZoomButton(icon: Icons.remove, onTap: zoomOut),
                      SizedBox(height: context.wOf(20, availableWidth)),
                      MapZoomButton(icon: Icons.my_location_rounded, onTap: myLocationTap),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.wOf(20, availableWidth)),
        continueButton,
      ],
    );
  }
}
