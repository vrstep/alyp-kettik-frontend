import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/thankyou.dart';
import '../controllers/dto.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isPhotoLoaded = false;
  DataBaseOperations dataBaseOperations = Get.find();
  var cart = Cart(
    id: 1,
    products: [],
    totalPrice: 1000,
    createdAt: DateTime.now(),
  );
  TextEditingController cardNumber = TextEditingController();
  TextEditingController cvv = TextEditingController();
  TextEditingController date = TextEditingController();
  DateTime createdAt = DateTime.now();
  XFile? _image;
  final ImagePicker picker = ImagePicker();

  Future getImageFromGallery() async {
    final pickedfile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedfile != null) {
        _image = pickedfile;
      }
    });
  }

  Future getImageFromCamera() async {
    final pickedfile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedfile != null) {
        _image = pickedfile;
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Оплати без кассира")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Фотография ваших продуктов",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await getImageFromGallery();
                            if (_image != null) {
                              isPhotoLoaded = true;
                              final bytes = await _image!.readAsBytes();
                              final record = await dataBaseOperations
                                  .uploadPhoto(bytes);
                              setState(() {
                                cart = Cart(
                                  id: record.id,
                                  products: record.products,
                                  totalPrice: record.totalPrice,
                                  createdAt: createdAt,
                                );
                              });
                            } else {
                              Get.snackbar("Сообщение", "Ничего не выбрано");
                            }
                          },
                          icon: const Icon(Icons.image),
                        ),
                        IconButton(
                          onPressed: () async {
                            await getImageFromCamera();
                            if (_image != null) {
                              isPhotoLoaded = true;
                              final bytes = await _image!.readAsBytes();
                              final record = await dataBaseOperations
                                  .uploadPhoto(bytes);
                              setState(() {
                                cart = Cart(
                                  id: record.id,
                                  products: record.products,
                                  totalPrice: record.totalPrice,
                                  createdAt: createdAt,
                                );
                              });
                            } else {
                              Get.snackbar("Сообщение", "Ничего не выбрано");
                            }
                          },
                          icon: const Icon(Icons.photo_camera),
                        ),
                      ],
                    ),
                    isPhotoLoaded == true
                        ? PhotoAssetWidget(image: _image!)
                        : const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("Не выбрано новое фото"),
                          ),
                    const SizedBox(height: 12),
                    cart.products.isEmpty
                        ? const SizedBox()
                        : Column(
                            children: [
                             


                              MyInputWidget(
                                inputName: "Номер карты",
                                textEditingController: cardNumber,
                              ),
                              MyInputWidget(
                                inputName: "Дата карты",
                                textEditingController: date,
                              ),
                              MyInputWidget(
                                inputName: "CVV",
                                textEditingController: cvv,
                              ),
                            ],
                          ),
                    MyButtonWidget(
                      textButton: "Оплатить",
                      fn: () async {
                        Get.defaultDialog(
                          title: 'Внимание',
                          radius: 12,
                          textCancel: "Нет",
                          textConfirm: "Да",
                          middleText: "Вы действительно хотите оплатить?",
                          onConfirm: () async {
                            Get.to(() => const ThankyouPage());
                          },
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.blue,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
