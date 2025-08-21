class SharingService {
  // TODO: Replace with your actual domain
  static const String _domain = 'https://locacharge.app';

  static String createShareLinkForMerchant(String merchantId) {
    return '$_domain/merchants/$merchantId';
  }
}
