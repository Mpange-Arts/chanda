
import 'dart:io';
import 'dart:math';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;
  File? selectedImage;
  XFile? imgXFile;

  CategoryProvider(this._dataProvider);

  AddCategory() async {
    try {
      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar('Error', 'Please Choose A image!');
        return;
      }
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image': 'no_data' //? image path will be added from server side
      };
      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);
      final response = await service.addItem(endpointUrl: 'categories', itemData: form);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Success', '${apiResponse.message}');
          log('category added' as num);
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to add category: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error', '${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('Error', 'An Error Occurred, $e');
      rethrow;
    }
  }

  void pickImage() async {
    final ImagePicker _picker = ImagePicker();
    imgXFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imgXFile != null) {
      selectedImage = File(imgXFile!.path);
    }
  }

  //TODO: should complete updateCategory
  //TODO: should complete submitCategory
  //TODO: should complete deleteCategory
  //TODO: should complete setDataForUpdateCategory
  //? to create form data for sending image with body
  Future<FormData> createFormData({required XFile? imgXFile, required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    final FormData form = FormData(formData);
    return form;
  }

  //? set data for update on editing
  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
  }
  
  void clearFields() {};