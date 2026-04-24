sealed class VendorClipsEvent {
  const VendorClipsEvent();
}

final class VendorClipsRequested extends VendorClipsEvent {
  const VendorClipsRequested();
}

final class VendorClipsRefreshRequested extends VendorClipsEvent {
  const VendorClipsRefreshRequested();
}

final class VendorClipsLoadMoreRequested extends VendorClipsEvent {
  const VendorClipsLoadMoreRequested();
}
