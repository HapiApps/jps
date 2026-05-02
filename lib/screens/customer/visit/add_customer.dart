import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../component/custom_loading_button.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/utilities/utils.dart';
import '../../../view_model/customer_provider.dart';

class AddCustomerPopup extends StatefulWidget {
  final String companyId;

  const AddCustomerPopup({super.key, required this.companyId});

  @override
  State<AddCustomerPopup> createState() => _AddCustomerPopupState();
}

class _AddCustomerPopupState extends State<AddCustomerPopup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  late var webWidth = MediaQuery.of(context).size.width * 0.5;
  late var phoneWidth = MediaQuery.of(context).size.width * 0.9;
  bool isLoading = false;

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
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              return CustomLoadingButton(
                callback:
                    () async {
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

                  if (widget.companyId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Company ID is empty")),
                    );
                    return;
                  }

                  setState(() => isLoading = true);

                  final custProvider =
                  Provider.of<CustomerProvider>(context, listen: false);

                  /// ✅ 1) Insert Customer
                  bool success = await custProvider.addCustomerApi(
                    companyId: widget.companyId,
                    customerName: name,
                    mobileNo: mobile,
                  );

                  if (success) {

                    await custProvider.getAllCustomers(true);

                    String newId = "";
                    String newName = "";

                    for (var item in custProvider.customer) {

                      List<String> idList = item.customerId.toString().split("||");
                      List<String> nameList = item.firstName.toString().split("||");
                      List<String> phoneList = item.phoneNumber.toString().split("||");

                      for (int i = 0; i < phoneList.length; i++) {
                        if (phoneList[i].trim() == mobile.trim()) {
                          newId = idList[i];
                          newName = nameList[i];
                          break;
                        }
                      }

                      if (newId.isNotEmpty) break;
                    }

                    if (newId.isNotEmpty) {

                      final newCustomer = {
                        "id": newId,
                        "name": newName.isNotEmpty ? newName : name,
                        "no": mobile,
                      };

                      // ✅ selected list update inside popup
                      List<Map<String, dynamic>> currentList =
                      List<Map<String, dynamic>>.from(custProvider.multiSelectedCustomerList);

                      currentList.add(newCustomer);

                      custProvider.setMultiSelectedCustomers(currentList);
                      utils.showWarningToast(context,text:  "Customer Added Successfully",);
                      custProvider.addcustomerCtr.reset();
                      Navigator.pop(context, newCustomer);

                    } else {
                      utils.showWarningToast(context,text:  "Customer added but ID not found in list",);
                      custProvider.addcustomerCtr.reset();
                    }

                  } else {
                    utils.showWarningToast(context,text:  "Customer Already Exists / Failed",);
                    custProvider.addcustomerCtr.reset();
                  }

                  setState(() => isLoading = false);
                },
                text: "Save",
                controller: provider.addcustomerCtr, // if exists
                isLoading: true,
                backgroundColor: colorsConst.primary,
                radius: 10,
                width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1,
              );
            }
        ),

      ],
    );
  }
}