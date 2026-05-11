import 'package:flutter/material.dart';

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

    double safeDouble(value) {
      return double.tryParse(value.toString()) ?? 0.0;
    }

    double allowedVal = safeDouble(allowed);
    double takenVal = safeDouble(taken);

    double remaining = allowedVal - takenVal;

    /// 🟢 PRINT (DEBUG)
    print("🔥 Leave Taken = $takenVal");

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
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

          /// TITLE
          const Text(
            "📅 Leave Summary",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          /// QUICK INFO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// TOTAL
              Row(
                children: [
                  Text(
                    "Total Leave : ",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  Text(
                    "$allowedVal",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              /// TAKEN (WITH PRINT VALUE)
              Row(
                children: [
                  Text(
                    "Leave Taken : ",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  Text(
                    "$takenVal",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// STATUS
          Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: remaining > 0
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              remaining > 0
                  ? "✨ $remaining days left. Plan smart!"
                  : "All leaves used. Plan Accordingly",
              style: TextStyle(
                fontSize: 14,
                color: remaining > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}