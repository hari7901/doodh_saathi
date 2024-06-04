import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/products_model.dart';
import '../../services/product_info_service.dart';
import 'supply_detail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SupplyPage extends StatefulWidget {
  final String category;

  SupplyPage({required this.category});

  @override
  State<SupplyPage> createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<SupplyPage> {
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : Text(
          AppLocalizations.of(context)!.supplies,
          style: GoogleFonts.alata(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        leading:_isSearching
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
            });
          },
        )
            : IconButton(
          icon: Icon(FontAwesomeIcons.leftLong, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: _buildActions(),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.teal, // Lighter color
                Colors.lightGreen, // Darker color
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[700]!, // Lighter green color
              Colors.white, // Darker green color
            ],
          ),
        ),
        child: FutureBuilder<List<Product>>(
          future: NamesService.fetchProductsByCategory(widget.category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error loading products"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No products found"));
            }

            List<Product> filteredProducts = _searchQuery.isEmpty
                ? snapshot.data!
                : snapshot.data!.where((product) =>
                product.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

            return ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index){
                return buildProductItem(context, filteredProducts[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search products...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: Icon(Icons.clear,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => _stopSearching(),
        ),
      ];
    }

    return [
      IconButton(
        icon: Icon(FontAwesomeIcons.magnifyingGlass,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => setState(() => _isSearching = true),
      ),
    ];
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
  }


  void updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void clearSearchQuery() {
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  void navigateToProductDetail(String productId) async {
    Product detailedProduct = await NamesService.fetchProductById(productId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplyDetail(product: detailedProduct),
      ),
    );
  }

  Widget buildProductItem(BuildContext context, Product product) {

    return InkWell(
      onTap: () => navigateToProductDetail(product.id),
      child: Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                child: Image.network(
                  product.imageUrls.isNotEmpty ? product.imageUrls[0] : 'android/assets/cow.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/placeholder.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildProductName(product.name),
                    buildProductPrice(product.price),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductName(String name) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[800],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }


  Widget buildProductPrice(double price) {
    double originalPrice = price; // Placeholder for the original price
    double discountedPrice = price * 0.8; // Placeholder for discounted price (20% off)

    return Padding(
      padding: EdgeInsets.all(10),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '\₹${originalPrice.toStringAsFixed(2)}  ',
              style: GoogleFonts.alata(
                fontSize: 12,
                color: Colors.green,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            TextSpan(
              text: ' \₹${discountedPrice.toStringAsFixed(2)}',
              style: GoogleFonts.alata(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildAddToCartButton() {
    return Container(
      width: double.infinity,
      height: 50, // Specify the height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.teal, // Start color of the gradient
            Colors.green // End color of the gradient
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: TextButton(
        onPressed: () {
          // TODO: Implement add to cart functionality
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white, shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Use min to prevent the row from expanding to the full width of the button
          children: [
            Icon(FontAwesomeIcons.cartShopping, color: Colors.white,
            size: 16,
            ),
            SizedBox(width: 7,),// Icon
            Text(
              'Add to Cart',
              style: GoogleFonts.alata(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

}

