import 'package:flutter/material.dart';
import 'package:hey_smile/core/constants.dart';
import 'package:hey_smile/features/shop/domain/product.dart';
import 'package:hey_smile/features/shop/presentation/widgets/product_card.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,

      body: Padding(
        padding: const EdgeInsets.all(UiConstants.defaultPadding),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: UiConstants.defaultPadding,
            mainAxisSpacing: UiConstants.defaultPadding,
          ),
          itemCount: _sampleProducts.length,
          itemBuilder: (context, index) {
            final product = _sampleProducts[index];
            return ProductCard(product: product);
          },
        ),
      ),
    );
  }
}

// Sample Products
final List<Product> _sampleProducts = [
  Product(
    title: 'HAIR CARE AND PROTECTION 12 MONTH KIT',
    price: 500.00,
    rating: 5,
    imageUrl:
        'https://cdn-kdlpl.nitrocdn.com/ynmxOtTHILDzwEmfrEfewGmkrrbUSGFv/assets/images/optimized/rev-a1f785b/shop.smilehairclinic.com/wp-content/uploads/2023/07/12-MONTH-HAIR-CARE-AND-PROTECTION-KIT-300x300.jpg',
    usageFrequency: '3 günde bir alınır',
  ),
  Product(
    title: 'HAIR CARE AND PROTECTION 6 MONTH KIT',
    price: 300.00,
    rating: 5,
    imageUrl:
        'https://cdn-kdlpl.nitrocdn.com/ynmxOtTHILDzwEmfrEfewGmkrrbUSGFv/assets/images/optimized/rev-a1f785b/shop.smilehairclinic.com/wp-content/uploads/2023/07/0o913wej-300x300.png',
    usageFrequency: '2 günde bir alınır',
  ),
  Product(
    title: 'HAIR CARE AND PROTECTION 3 MONTH KIT',
    price: 175.00,
    rating: 5,
    imageUrl:
        'https://cdn-kdlpl.nitrocdn.com/ynmxOtTHILDzwEmfrEfewGmkrrbUSGFv/assets/images/optimized/rev-a1f785b/shop.smilehairclinic.com/wp-content/uploads/2023/07/3Aylik_Trans-2.png',
    usageFrequency: 'Günde bir alınır',
  ),
  Product(
    title: 'REPAIR MESO SERUM SET',
    price: 250.00,
    rating: 4.67,
    imageUrl:
        'https://cdn-kdlpl.nitrocdn.com/ynmxOtTHILDzwEmfrEfewGmkrrbUSGFv/assets/images/optimized/rev-a1f785b/shop.smilehairclinic.com/wp-content/uploads/2023/07/REPAIR-MESO-SERUM-600x600.jpg',
    usageFrequency: 'Haftada 2 kez alınır',
  ),
  Product(
    title: 'HAIR CARE SHAMPOO SET',
    price: 75.00,
    rating: 5,
    imageUrl:
        'https://cdn-kdlpl.nitrocdn.com/ynmxOtTHILDzwEmfrEfewGmkrrbUSGFv/assets/images/optimized/rev-a1f785b/shop.smilehairclinic.com/wp-content/uploads/2023/07/hairCareShampooSet_trans-1-600x600.png',
    usageFrequency: '3 günde bir alınır',
  ),
  Product(
    title: 'MULTIVITAMIN FORTE',
    price: 35.00,
    rating: 4.67,
    imageUrl:
        'https://cdn-kdlpl.nitrocdn.com/ynmxOtTHILDzwEmfrEfewGmkrrbUSGFv/assets/images/optimized/rev-a1f785b/shop.smilehairclinic.com/wp-content/uploads/2023/07/multivitaminForte_trns-2.png',
    usageFrequency: 'Günde bir alınır',
  ),
  Product(
    title: 'HAIR CARE AND PROTECTION 12 MONTH KIT',
    price: 500.00,
    rating: 5,
    imageUrl:
        'https://cdn-kdlpl.nitrocdn.com/ynmxOtTHILDzwEmfrEfewGmkrrbUSGFv/assets/images/optimized/rev-a1f785b/shop.smilehairclinic.com/wp-content/uploads/2023/07/12-MONTH-HAIR-CARE-AND-PROTECTION-KIT-300x300.jpg',
    usageFrequency: '3 günde bir alınır',
  ),
  Product(
    title: 'AFTER HAIR TRANSPLANTATION WASH KIT',
    price: 40.00,
    rating: 4.67,
    imageUrl:
        'https://cdn-kdlpl.nitrocdn.com/ynmxOtTHILDzwEmfrEfewGmkrrbUSGFv/assets/images/optimized/rev-a1f785b/shop.smilehairclinic.com/wp-content/uploads/2023/07/afterHair_trans-2-600x600.png',
    usageFrequency: 'Haftada 3 kez alınır',
  ),
];
