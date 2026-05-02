import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../component/custom_loading_button.dart';
import '../../../model/customer/customer_model.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/utilities/utils.dart';
import '../../../view_model/customer_provider.dart';
import '../../../view_model/leave_provider.dart';

class AddCompanyPopup extends StatefulWidget {
  const AddCompanyPopup({super.key});

  @override
  State<AddCompanyPopup> createState() => _AddCompanyPopupState();
}

class _AddCompanyPopupState extends State<AddCompanyPopup> {

  final TextEditingController companyController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  late var webWidth = MediaQuery.of(context).size.width * 0.5;
  late var phoneWidth = MediaQuery.of(context).size.width * 0.9;
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
        Consumer<CustomerProvider>(
            builder: (context, provider, child) {
        return CustomLoadingButton(
        callback: ()
        async {
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
        await custProvider.getAllCustomers(true);

        CustomerModel? addedCompany;

        for (var item in custProvider.customer) {
        if (item.companyName.toString().trim().toLowerCase() ==
        companyName.trim().toLowerCase()) {
        addedCompany = item;
        break;
        }
        }

        if (addedCompany != null) {

        List<Map<String, dynamic>> tempList = [];

        var idList = addedCompany.customerId.toString().split("||");
        var nameList = addedCompany.firstName.toString().split("||");
        var phoneList = addedCompany.phoneNumber.toString().split("||");

        for (int i = 0; i < nameList.length; i++) {
        tempList.add({
        "id": idList[i],
        "name": nameList[i],
        "no": phoneList[i],
        });
        }

        // ✅ provider values set
        custProvider.selectedCompanyId = addedCompany.userId.toString();
        custProvider.selectedCompanyName = addedCompany.companyName.toString();
        custProvider.setSendList(tempList);

        if (tempList.isNotEmpty) {
        custProvider.setMultiSelectedCustomers([tempList[0]]);
        }

        custProvider.notifyListeners();
        utils.showWarningToast(context,text:  "Company & Customer Added",);
        Navigator.pop(context, addedCompany);
        custProvider.addCompanyCtr.reset();
        } else {
        utils.showWarningToast(context,text:  "Company added but not found",);
        custProvider.addCompanyCtr.reset();
        }

        } else {
        utils.showWarningToast(context,text:  "Already Exists / Failed",);
        custProvider.addCompanyCtr.reset();
        }
        },
        text: "Save",
        controller: provider.addCompanyCtr, // if exists
        isLoading: true,
        backgroundColor: colorsConst.primary,
        radius: 10,
        width: kIsWeb ? webWidth / 2.1 : phoneWidth / 2.1,
        );
      }
    ),
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: colorsConst.primary, // button color
        //     foregroundColor: Colors.white, // text color
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
        //   ),
        //   onPressed: () async {
        //     String companyName = companyController.text.trim();
        //     String custName = nameController.text.trim();
        //     String mobile = mobileController.text.trim();
        //
        //     if (companyName.isEmpty || custName.isEmpty || mobile.isEmpty) {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text("Please enter all details")),
        //       );
        //       return;
        //     }
        //
        //     if (!isValidMobile(mobile)) {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text("Enter valid mobile number")),
        //       );
        //       return;
        //     }
        //
        //     final custProvider = Provider.of<CustomerProvider>(context, listen: false);
        //
        //     bool success = await custProvider.addCompanyAndCustomerApi(
        //       companyName: companyName,
        //       customerName: custName,
        //       mobileNo: mobile,
        //     );
        //
        //     if (success) {
        //       await custProvider.getAllCustomers(true);
        //
        //       CustomerModel? addedCompany;
        //
        //       for (var item in custProvider.customer) {
        //         if (item.companyName.toString().trim().toLowerCase() ==
        //             companyName.trim().toLowerCase()) {
        //           addedCompany = item;
        //           break;
        //         }
        //       }
        //
        //       if (addedCompany != null) {
        //
        //         List<Map<String, dynamic>> tempList = [];
        //
        //         var idList = addedCompany.customerId.toString().split("||");
        //         var nameList = addedCompany.firstName.toString().split("||");
        //         var phoneList = addedCompany.phoneNumber.toString().split("||");
        //
        //         for (int i = 0; i < nameList.length; i++) {
        //           tempList.add({
        //             "id": idList[i],
        //             "name": nameList[i],
        //             "no": phoneList[i],
        //           });
        //         }
        //
        //         // ✅ provider values set
        //         custProvider.selectedCompanyId = addedCompany.userId.toString();
        //         custProvider.selectedCompanyName = addedCompany.companyName.toString();
        //         custProvider.setSendList(tempList);
        //
        //         if (tempList.isNotEmpty) {
        //           custProvider.setMultiSelectedCustomers([tempList[0]]);
        //         }
        //
        //         custProvider.notifyListeners();
        //         utils.showWarningToast(context,text:  "Company & Customer Added",);
        //         Navigator.pop(context, addedCompany);
        //
        //       } else {
        //         utils.showWarningToast(context,text:  "Company added but not found",);
        //       }
        //
        //     } else {
        //       utils.showWarningToast(context,text:  "Already Exists / Failed",);
        //     }
        //   },
        //   child: const Text("Save"),
        // ),
      ],
    );
  }
}