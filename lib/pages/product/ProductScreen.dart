import 'package:flutter/material.dart';
import 'package:simple_product_lister/components/product/ProductCard.dart';
import 'package:simple_product_lister/models/product/Product.dart';
import 'package:simple_product_lister/services/networkService.dart';
import '../../services/apiService.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> listProduct = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getProducts();
  }

  Future<void> _getProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (!await NetworkService.hasInternet()) {
        throw Exception('NO_INTERNET');
      }

      ApiService apiService = ApiService();
      await apiService.init();

      final response = await apiService.request(
        endpoint: 'products',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'] ?? [];

        final products = data.map((e) => Product.fromJson(e)).toList();

        if (!mounted) return;
        setState(() {
          listProduct = products;
          isLoading = false;
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = _mapErrorMessage(e);
      });
      debugPrint('Error _getProducts: $e');
    }
  }

  String _mapErrorMessage(Object e) {
    final msg = e.toString();

    if (msg.contains('NO_INTERNET')) {
      return 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้\nกรุณาตรวจสอบเครือข่ายของคุณ';
    }

    return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _getProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่อีกครั้ง'),
              ),
            ],
          ),
        ),
      );
    }

    if (listProduct.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: listProduct.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          return ProductCard(product: listProduct[index]);
        },
      ),
    );
  }
}
