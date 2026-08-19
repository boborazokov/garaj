import 'package:flutter/material.dart';

class SellerProfile extends StatelessWidget {
  final String id;
  const SellerProfile({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seller Profile")),
      body: Center(
        child: Text("Seller ID: $id"), 
      ),
    );
  }
}
