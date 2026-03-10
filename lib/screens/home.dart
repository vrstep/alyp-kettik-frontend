import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../screens/thankyou.dart';
import '../controllers/dto.dart';
import '../models/models.dart';
import '../utils/formatter.dart';
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
  http.Client? _httpClient;
  final _formKey = GlobalKey<FormState>();

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
    _httpClient = http.Client();
    setState(() => isLoading = true);
    try {
      final ext = image.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
      final bytes = await image.readAsBytes();

      final record = await dataBaseOperations.uploadPhoto(
        bytes,
        _httpClient!,
        mime: mime,
      );
      if (record == null) return; // отмена или ошибка

      if (record["recognized_items"] == null) {
        Get.snackbar("Ошибка", "Неожиданный ответ: $record");
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
      _httpClient?.close();
      _httpClient = null;
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

  void _cancelRecognition() {
    _httpClient?.close(); // обрывает HTTP запрос
    _httpClient = null;
    setState(() {
      isLoading = false;
      isPhotoLoaded = false;
      _image = null;
    });
    Get.snackbar("Отменено", "Распознавание прервано");
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
                      mainAxisSize: MainAxisSize.min,
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
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 12),
                                const Text(
                                  "Распознаём товары, подождите...",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: _cancelRecognition,
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    "Отменить",
                                    style: TextStyle(color: Colors.red),
                                  ),
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
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Номер карты: 16 цифр, автоформат XXXX XXXX XXXX XXXX
                                    TextFormField(
                                      controller: cardNumber,
                                      decoration: const InputDecoration(
                                        labelText: "Номер карты",
                                        hintText: "0000 0000 0000 0000",
                                        prefixIcon: Icon(Icons.credit_card),
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      maxLength: 19, // 16 цифр + 3 пробела
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        CardNumberFormatter(),
                                      ],
                                      validator: (v) {
                                        final digits =
                                            v?.replaceAll(' ', '') ?? '';
                                        if (digits.length != 16) {
                                          return 'Введите 16 цифр';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Дата карты: MM/YY
                                    TextFormField(
                                      controller: date,
                                      decoration: const InputDecoration(
                                        labelText: "Дата карты",
                                        hintText: "MM/YY",
                                        prefixIcon: Icon(Icons.calendar_today),
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        ExpiryDateFormatter(),
                                      ],
                                      validator: (v) {
                                        if (v == null || v.length != 5) {
                                          return 'Формат MM/YY';
                                        }
                                        final parts = v.split('/');
                                        final month =
                                            int.tryParse(parts[0]) ?? 0;
                                        final year =
                                            int.tryParse(parts[1]) ?? 0;
                                        if (month < 1 || month > 12) {
                                          return 'Неверный месяц';
                                        }
                                        final now = DateTime.now();
                                        final expiry = DateTime(
                                          2000 + year,
                                          month + 1,
                                        );
                                        if (expiry.isBefore(now)) {
                                          return 'Карта просрочена';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // CVV: 3 цифры
                                    TextFormField(
                                      controller: cvv,
                                      decoration: const InputDecoration(
                                        labelText: "CVV",
                                        hintText: "000",
                                        prefixIcon: Icon(Icons.lock_outline),
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      maxLength: 3,
                                      obscureText: true,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (v) {
                                        if ((v?.length ?? 0) != 3) {
                                          return 'CVV — 3 цифры';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              MyButtonWidget(
                                textButton: "Оплатить",
                                fn: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return; // стоп если ошибки
                                  }
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
