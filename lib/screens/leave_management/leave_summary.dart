import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../source/constant/default_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/leave_provider.dart';
import '../common/dashboard.dart';
import 'leave_dashboard.dart';

class LeaveSummaryCard extends StatelessWidget {
  final String allowed;
  final String taken;

  const LeaveSummaryCard({
    super.key,
    required this.allowed,
    required this.taken,
  });

  @override
  Widget build(BuildContext context) {
    double safeDouble(dynamic value) {
      return double.tryParse(value.toString()) ?? 0.0;
    }

    String formatDouble(double val) {
      if (val % 1 == 0) {
        return val.toStringAsFixed(0); // ✅ 1.0 -> 1
      } else {
        return val.toString(); // ✅ 1.5 -> 1.5
      }
    }

    double allowedVal = safeDouble(allowed);
    double takenVal = safeDouble(taken);

    double remaining = allowedVal - takenVal;

    return GestureDetector(
      onTap: (){
        Provider.of<LeaveProvider>(context, listen: false).changeIndex(2);

        utils.navigatePage(
            context,
                ()=>const DashBoard(child: LeaveManagementDashboard())
        );
      },
      child: Consumer<LanguageManager>(
        builder: (context, langManager, _) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// TOTAL
                    Row(
                      children: [
                        Text(
                          " ${constValue.leaveSummary}",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          constValue.totalLeaveLabel,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        Text(
                          formatDouble(allowedVal),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    /// TAKEN
                    Row(
                      children: [
                        Text(
                          constValue.leaveTakenLabel,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        Text(
                          formatDouble(takenVal),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                /// STATUS
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: allowedVal == 0
                        ? Colors.orange.shade50
                        : remaining > 0
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    allowedVal == 0
                        ? constValue.noLeavesAllocated
                        : remaining > 0
                        ? "✨ ${formatDouble(remaining)} ${constValue.daysLeftPlanSmart}"
                        : constValue.allLeavesUsed,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: allowedVal == 0
                          ? Colors.orange.shade800
                          : remaining > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}