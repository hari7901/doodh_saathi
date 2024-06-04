import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/products_model.dart';

class ProductSearchDelegate extends SearchDelegate<Product> {
  final List<Product> products;
  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Product> results = products
        .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          subtitle: Text('\$${results[index].price.toStringAsFixed(2)}'),
          onTap: () {
            // Implement action on tap if necessary
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Product> suggestions = products
        .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].name),
          subtitle: Text('\$${suggestions[index].price.toStringAsFixed(2)}'),
          onTap: () {
            // Implement action on tap if necessary
          },
        );
      },
    );
  }
}
