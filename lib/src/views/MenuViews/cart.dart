import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/cart_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../address_views/select_address.dart';
import '../commodity_detail/supplies.dart';


class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalPrice = 0.0; // Initialize the totalPrice variable here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('          Shopping Cart',
            style: GoogleFonts.alata(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(FontAwesomeIcons.trash, color: Colors.white),
            onPressed: () {
              // Access the CartModel and clear the cart
              Provider.of<CartModel>(context, listen: false).clearCart();
            },
          ),
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.bagShopping,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CategoryPage()));
            },
          ),
        ],
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          return cart.items.isEmpty
              ? const Center(
              child: Text('Your cart is empty',
                  style: TextStyle(fontSize: 18)))
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final entry = cart.items.entries.elementAt(index);
                    final product = entry.key;
                    final quantity = entry.value;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Image.network(
                          product.imageUrls[0],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(product.name,
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${AppLocalizations.of(context)!.quantity}: $quantity\n${AppLocalizations.of(context)!.price}: \₹${(product.price *
                                quantity).toStringAsFixed(2)}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.red),
                              onPressed: () {
                                cart.remove(product);
                              },
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                cart.add(product, 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              _buildSummarySection(cart),
              _buildCheckoutButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(CartModel cart) {
    double subtotal = cart.calculateSubtotal(); // Calculate the subtotal
    double taxRate = 0.08; // Example tax rate
    double tax = subtotal * taxRate;
    double total = subtotal + tax;

    // Update the totalPrice variable with the total value
    totalPrice = total;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSummaryRow(AppLocalizations.of(context)!.subTotal, subtotal),
          _buildSummaryRow(AppLocalizations.of(context)!.tax, tax),
          const Divider(),
          _buildSummaryRow(AppLocalizations.of(context)!.total, total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.lightGreen, Colors.green],
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: ElevatedButton(
          onPressed: () {
            // Passing the cart data to the SelectAddress page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SelectAddress(
                        cart: Provider.of<CartModel>(context, listen: false)),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Transparent background
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.proceedToCheckout,
            style: GoogleFonts.alata(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
