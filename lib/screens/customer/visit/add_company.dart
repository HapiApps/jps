import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../view_model/customer_provider.dart';

class AddCompanyPopup extends StatefulWidget {
  const AddCompanyPopup({super.key});

  @override
  State<AddCompanyPopup> createState() => _AddCompanyPopupState();
}

class _AddCompanyPopupState extends State<AddCompanyPopup> {

  final TextEditingController companyController = TextEditingController();
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
    companyController.dispose();
    nameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Company & Customer"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// ✅ Company Name
            TextField(
              controller: companyController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: "Company Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                String formatted = capitalizeFirstLetter(value);
                if (value != formatted) {
                  companyController.value = companyController.value.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),

            const SizedBox(height: 12),

            /// ✅ Customer Name
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

            /// ✅ Mobile
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
          child:  Text("Cancel",style: TextStyle(color: colorsConst.primary),),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorsConst.primary, // button color
            foregroundColor: Colors.white, // text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
          ),
          onPressed: () async {
            String companyName = companyController.text.trim();
            String custName = nameController.text.trim();
            String mobile = mobileController.text.trim();

            if (companyName.isEmpty || custName.isEmpty || mobile.isEmpty) {
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

            final custProvider = Provider.of<CustomerProvider>(context, listen: false);

            bool success = await custProvider.addCompanyAndCustomerApi(
              companyName: companyName,
              customerName: custName,
              mobileNo: mobile,
            );

            if (success) {
              Navigator.pop(context, true);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Company & Customer Added")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Already Exists / Failed")),
              );
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}