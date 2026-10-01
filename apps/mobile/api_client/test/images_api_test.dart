import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for ImagesApi
void main() {
  final instance = CampusApi().getImagesApi();

  group(ImagesApi, () {
    // Get Image
    //
    //Future<JsonObject> getImageApiV1ImagesImageIdGet(String imageId) async
    test('test getImageApiV1ImagesImageIdGet', () async {
      // TODO
    });

    // Upload Image
    //
    //Future<ImageUploadResponse> uploadImageApiV1ImagesPost(ImageUploadRequest imageUploadRequest) async
    test('test uploadImageApiV1ImagesPost', () async {
      // TODO
    });

  });
}
