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
  bool isLoading = false;
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

  List<Product> products = [];
  void getProductsFromJson(dynamic data) {
    products.clear();
    for (var item in data) {
      products.add(
        Product(
          id: item["product_id"],
          name: item["name"],
          qty: item["quantity"],
          price: (item["price"] as num).toInt(),
          createdAt: createdAt,
        ),
      );
    }
  }

  Future<void> _processImage(XFile image) async {
    setState(() => isLoading = true);
    try {
      final ext = image.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
      final bytes = await image.readAsBytes();
      final record = await dataBaseOperations.uploadPhoto(bytes, mime: mime);
      if (record == null) return;
      if (record["recognized_items"] == null) {
        Get.snackbar("Ошибка", "Неожиданный ответ сервера: $record");
        return;
      }

      setState(() {
        isPhotoLoaded = true;
        getProductsFromJson(record["recognized_items"]);
        cart = Cart(
          id: 1,
          products: products,
          totalPrice: (record["total"] as num).toInt(),
          createdAt: createdAt,
        );
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _clearCart() {
    setState(() {
      products.clear();
      isPhotoLoaded = false;
      _image = null;
      cart = Cart(
        id: 1,
        products: [],
        totalPrice: 0,
        createdAt: DateTime.now(),
      );
      cardNumber.clear();
      cvv.clear();
      date.clear();
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
                            _clearCart();
                            await getImageFromGallery();
                            if (_image != null) await _processImage(_image!);
                          },
                          icon: const Icon(Icons.image),
                        ),
                        IconButton(
                          onPressed: () async {
                            _clearCart();
                            await getImageFromCamera();
                            if (_image != null) await _processImage(_image!);
                          },
                          icon: const Icon(Icons.photo_camera),
                        ),
                      ],
                    ),
                    isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 12),
                                Text(
                                  "Распознаём товары, подождите...",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : isPhotoLoaded
                        ? PhotoAssetWidget(image: _image!)
                        : const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("Не выбрано новое фото"),
                          ),
                    const SizedBox(height: 12),
                    cart.products.isEmpty
                        ? const SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Список товаров ──────────────────────────
                              const Text(
                                "Распознанные товары",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    ...cart.products.map(
                                      (p) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                p.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "x${p.qty}",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              "${(p.price * p.qty).toStringAsFixed(0)} ₸",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // ── Итого ──────────────────────────────
                                    const Divider(height: 1),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Итого",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            "${cart.totalPrice.toStringAsFixed(0)} ₸",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // ── Поля карты ─────────────────────────────
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

                              MyButtonWidget(
                                textButton: "Оплатить",
                                fn: () async {
                                  Get.defaultDialog(
                                    title: 'Внимание',
                                    radius: 12,
                                    textCancel: "Нет",
                                    textConfirm: "Да",
                                    middleText:
                                        "Вы действительно хотите оплатить?",
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
