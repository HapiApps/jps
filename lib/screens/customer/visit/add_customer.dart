import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_model/customer_provider.dart';

class AddCustomerPopup extends StatefulWidget {
  final String companyId;   // ✅ company id add pannom

  const AddCustomerPopup({super.key, required this.companyId});

  @override
  State<AddCustomerPopup> createState() => _AddCustomerPopupState();
}

class _AddCustomerPopupState extends State<AddCustomerPopup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  bool isValidMobile(String mobile) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Customer"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: "Customer Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                String formatted = capitalizeFirstLetter(value);
                if (value != formatted) {
                  nameController.value = nameController.value.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: "Mobile Number",
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            String name = nameController.text.trim();
            String mobile = mobileController.text.trim();

            if (name.isEmpty || mobile.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter all details")),
              );
              return;
            }

            if (!isValidMobile(mobile)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Enter valid mobile number")),
              );
              return;
            }

            final custProvider =
            Provider.of<CustomerProvider>(context, listen: false);

            custProvider.addCustomerApi(
              companyId: widget.companyId,   // ✅ correct
              customerName: name,
              mobileNo: mobile,
            );

            Navigator.pop(context);
          },
          child: const Text("Save"),
        )
      ],
    );
  }
}