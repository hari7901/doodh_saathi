import 'package:dots_indicator/dots_indicator.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/cart_model.dart';
import '../../models/products_model.dart';
import '../MenuViews/cart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SupplyDetail extends StatefulWidget {
  final Product product;

  SupplyDetail({super.key, required this.product});

  @override
  State<SupplyDetail> createState() => _SupplyDetailState();
}

class _SupplyDetailState extends State<SupplyDetail> {
  int _currentImageIndex = 0;
  int _selectedQuantity = 1;
// To track the state of the collapsible section


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "    ${widget.product.name}",
          style: GoogleFonts.alata(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.leftLong, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[600]!,
              Colors.green
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(),
              _buildProductTitle(),
              _buildPriceSection(),
              _buildDescription(),
              _buildQuantitySelector(),
              _buildActionButtons(context),
              // Optionally add more sections here (e.g., customer reviews, Q&A)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300.0,
            enlargeCenterPage: true,
            autoPlay: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: widget.product.imageUrls.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10,),
        DotsIndicator(
          dotsCount: widget.product.imageUrls.length,
          position: _currentImageIndex.toDouble().round(),
          decorator: DotsDecorator(
            activeColor: Colors.white,
            color: Colors.black,
            size: const Size.square(9.0),
            // Size for inactive dots
            activeSize: const Size(18.0, 9.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductTitle() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Text(
              widget.product.name,
              style: GoogleFonts.alata(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
          ),
        ),
        const Divider(color: Colors.black,)
      ],
    );
  }

  Widget _buildPriceSection() {
    double originalPrice = widget.product
        .price; // Placeholder for the original price
    double discountedPrice = widget.product.price *
        0.8; // Placeholder for discounted price (20% off)

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: "${AppLocalizations.of(context)!.price}:",
                style: GoogleFonts.alata(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '\₹${originalPrice.toStringAsFixed(2)}  ',
                style: GoogleFonts.alata(
                  fontSize: 16,
                  color: Colors.white,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              TextSpan(
                text: ' \₹${discountedPrice.toStringAsFixed(2)}',
                style: GoogleFonts.alata(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ExpandablePanel(
            theme: const ExpandableThemeData(
              iconColor: Colors.white,
              tapHeaderToExpand: true,
              hasIcon: true,
            ),
            header: Center(
              child: Text(
                AppLocalizations.of(context)!.aboutThisItem,
                style: GoogleFonts.alata(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            collapsed: Container(), // Empty container for collapsed state
            expanded: Text(
              widget.product.description,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        const Divider(color: Colors.black,)
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _addToCart(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8), // Less rounded corners
                ),
              ),
              child: Text(AppLocalizations.of(context)!.addToCart,
                style: GoogleFonts.alata(
                  color: Colors.white,
                  fontSize: 18
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => GoToCart(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8), // Less rounded corners
                ),
              ),
              child: Text(AppLocalizations.of(context)!.buyNow,
                style: GoogleFonts.alata(
                  color: Colors.white,
                  fontSize: 18
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    // Access the cart model
    var cart = Provider.of<CartModel>(context, listen: false);

    // Add the product to the cart the number of times specified by _selectedQuantity
    for (int i = 0; i < _selectedQuantity; i++) {
      cart.add(widget.product,1);
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addedToCart,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          content: Text(AppLocalizations.of(context)!.itemAddedSuccessfully,
            style: TextStyle(color: Colors.black87),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: <Widget>[
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.ok),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to the checkout page
                // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage()));
              },
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.proceedToCheckout),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CartPage()
                  )
                ); // Close the dialog
                // Navigate to the checkout page
                // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage()));
              },
            ),
          ],
        );
      },
    );
  }

  void GoToCart(BuildContext context) {
    // Access the cart model
    var cart = Provider.of<CartModel>(context, listen: false);

    // Add the product to the cart the number of times specified by _selectedQuantity
    for (int i = 0; i < _selectedQuantity; i++) {
      cart.add(widget.product,1);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CartPage()
      )
    );
  }


  Widget _buildQuantitySelector() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${AppLocalizations.of(context)!.quantity}(50 Kg):",
            style: TextStyle(
              fontSize: 20
              ,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10), // Space between the text and selector
          GestureDetector(
            onTap: () => _showQuantityPicker(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedQuantity.toString(),
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 32,
            onSelectedItemChanged: (int value) {
              setState(() {
                _selectedQuantity = value + 1; // Since the picker index starts at 0
              });
            },
            children: List<Widget>.generate(1000, (int index) {
              return Center(
                child: Text(
                  (index + 1).toString(),
                  style: TextStyle(color: Colors.black),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}