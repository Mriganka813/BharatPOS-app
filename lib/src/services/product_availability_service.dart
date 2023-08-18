import 'api_v1.dart';

class ProductAvailabilityService {
  isProductAvailable(String productId, String status) async {
    final response =
        await ApiV1Service.getRequest('/inventory/$productId/$status');
    print(response.data);
  }
}
