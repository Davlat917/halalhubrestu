import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/feedback/global_feedback_dialog.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/maps_places_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/bloc/update_restaurant_cubit.dart';
import 'package:halalhub_restaurant/features/restaurant/services/restaurant_map_service.dart';
import 'package:uuid/uuid.dart';

class _MapSearchItem {
  const _MapSearchItem({required this.description, required this.placeId});

  final String description;
  final String placeId;
}

class LocationUpdateSection extends StatefulWidget {
  const LocationUpdateSection({
    super.key,
    required this.mapService,
    required this.placesRepo,
  });

  final RestaurantMapService mapService;
  final MapsPlacesRepo placesRepo;

  @override
  State<LocationUpdateSection> createState() => _LocationUpdateSectionState();
}

class _LocationUpdateSectionState extends State<LocationUpdateSection> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  late final VoidCallback _searchListener = _onSearchTextChanged;

  final _uuid = const Uuid();
  late String _sessionToken;
  Timer? _debounce;

  bool _suppressSearchListener = false;
  bool _searchLoading = false;
  bool _detailsLoading = false;
  List<_MapSearchItem> _searchResults = const [];

  @override
  void initState() {
    super.initState();
    _sessionToken = _uuid.v4();
    _searchController.addListener(_searchListener);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_searchListener);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (_suppressSearchListener) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 480), () {
      if (!mounted) return;
      unawaited(_runSearch(fromDebounce: true));
    });
  }

  void _setSearchText(String text) {
    _suppressSearchListener = true;
    _searchController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _suppressSearchListener = false;
  }

  Future<void> _changeZoom(double delta) async {
    if (!_controller.isCompleted) return;
    final map = await _controller.future;
    final currentZoom = await map.getZoomLevel();
    final nextZoom = (currentZoom + delta).clamp(2.0, 20.0);
    await map.animateCamera(CameraUpdate.zoomTo(nextZoom));
  }

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
    if (_controller.isCompleted) {
      final map = await _controller.future;
      await map.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16)));
    }
  }

  Future<void> _runSearch({bool fromDebounce = false}) async {
    final q = _searchController.text.trim();
    if (q.length < 2) {
      if (mounted) {
        setState(() {
          _searchResults = const [];
          _searchLoading = false;
        });
      }
      return;
    }

    if (!fromDebounce) {
      FocusScope.of(context).unfocus();
    }

    setState(() {
      _searchLoading = true;
      _searchResults = const [];
    });

    try {
      final address = await widget.placesRepo.getAddress(
        uuid: _sessionToken,
        query: q,
      );
      if (!mounted) return;

      final status = address.status;
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        setState(() => _searchLoading = false);
        showGlobalFailureFeedback(
          context,
          message: TranslationKeys.updateMapSearchFailed.tr(context: context),
        );
        return;
      }

      if (address.predictions.isEmpty) {
        setState(() {
          _searchResults = const [];
          _searchLoading = false;
        });
        showGlobalFailureFeedback(
          context,
          message: TranslationKeys.updateMapSearchNoResults.tr(context: context),
        );
        return;
      }

      final items = address.predictions
          .where((p) => p.placeId.isNotEmpty && p.description.isNotEmpty)
          .map((p) => _MapSearchItem(description: p.description, placeId: p.placeId))
          .toList();

      if (items.isEmpty) {
        setState(() {
          _searchResults = const [];
          _searchLoading = false;
        });
        showGlobalFailureFeedback(
          context,
          message: TranslationKeys.updateMapSearchNoResults.tr(context: context),
        );
        return;
      }

      setState(() {
        _searchResults = items;
        _searchLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _searchLoading = false);
      final msg = e is NetworkException
          ? e.message
          : e is UnexpectedException
              ? e.message
              : TranslationKeys.updateMapSearchFailed.tr(context: context);
      showGlobalFailureFeedback(context, message: msg);
    }
  }

  Future<void> _selectSearchResult(_MapSearchItem item) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _detailsLoading = true;
      _searchResults = const [];
    });

    try {
      final loc = await widget.placesRepo.getPlaceLocation(
        placeId: item.placeId,
        sessionToken: _sessionToken,
      );
      if (!mounted) return;

      _sessionToken = _uuid.v4();
      final latLng = LatLng(loc.lat, loc.lng);
      _setSearchText(item.description);

      setState(() => _detailsLoading = false);

      if (!mounted) return;
      context.read<UpdateRestaurantCubit>().setLocation(latLng);

      if (_controller.isCompleted) {
        final map = await _controller.future;
        await map.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 16)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _detailsLoading = false);
      final msg = e is NetworkException
          ? e.message
          : e is UnexpectedException
              ? e.message
              : TranslationKeys.updateMapSearchFailed.tr(context: context);
      showGlobalFailureFeedback(context, message: msg);
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 1,
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  _debounce?.cancel();
                  unawaited(_runSearch(fromDebounce: false));
                },
                decoration: InputDecoration(
                  hintText: TranslationKeys.updateMapSearchHint.tr(context: context),
                  prefixIcon: const Icon(Icons.search, size: 22),
                  suffixIcon: _searchLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            _debounce?.cancel();
                            unawaited(_runSearch(fromDebounce: false));
                          },
                          tooltip: TranslationKeys.commonSearch.tr(context: context),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),
            ),
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _searchResults.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = _searchResults[i];
                      return ListTile(
                        dense: true,
                        enabled: !_detailsLoading,
                        leading: const Icon(Icons.place_outlined, color: StaticColors.primary),
                        title: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: _detailsLoading ? null : () => unawaited(_selectSearchResult(item)),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              height: mapHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: StaticColors.cE2E2E2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: state.selectedLatLng != null ? CameraPosition(target: state.selectedLatLng!, zoom: 14) : widget.mapService.initialCamera(),
                    onMapCreated: (controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      }
                    },
                    onTap: (pos) {
                      setState(() => _searchResults = const []);
                      context.read<UpdateRestaurantCubit>().setLocation(pos);
                    },
                    markers: widget.mapService.markersFor(state.selectedLatLng),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                  ),
                  if (_detailsLoading)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x33000000),
                        child: Center(
                          child: CircularProgressIndicator(color: StaticColors.primary),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MapControlButton(
                          icon: Icons.add,
                          onTap: () => _changeZoom(1),
                        ),
                        const SizedBox(height: 8),
                        _MapControlButton(
                          icon: Icons.remove,
                          onTap: () => _changeZoom(-1),
                        ),
                        const SizedBox(height: 8),
                        _MapControlButton(
                          icon: Icons.my_location_rounded,
                          onTap: _goToCurrentLocation,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }
}
