import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../source/constant/colors_constant.dart';
import '../../view_model/task_provider.dart';

class WagesWorkerDetailsPage extends StatefulWidget {
  const WagesWorkerDetailsPage({super.key});

  @override
  State<WagesWorkerDetailsPage> createState() => _WagesWorkerDetailsPageState();
}

class _Worker {
  final String id;
  final String name;
  final String phone;
  final double salary; // per day (8 hrs)
  _Worker(this.id, this.name, this.phone, this.salary);
}

class _WagesWorkerDetailsPageState extends State<WagesWorkerDetailsPage> {
  final List<_Worker> _workers = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  // ---------------- FETCH ALL WORKERS (backend) ----------------
  // pull = true na RefreshIndicator-oda own loader use aagum
  Future<void> _loadWorkers({bool pull = false}) async {
    if (!pull) setState(() => _loading = true);
    try {
      final list =
      await Provider.of<TaskProvider>(context, listen: false).getWages();
      if (!mounted) return;
      setState(() {
        _workers
          ..clear()
          ..addAll(list.map((m) => _Worker(
            (m['id'] ?? '').toString(),
            (m['emp_name'] ?? m['name'] ?? '').toString(),
            (m['emp_contact'] ?? m['contact'] ?? '').toString(),
            double.tryParse(
                (m['rate'] ?? m['salary'] ?? '0').toString()) ??
                0,
          )));
      });
    } catch (e) {
      debugPrint("Load workers error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------- ADD WORKER (backend) ----------------
  void _openAddWorker() {
    final name = TextEditingController();
    final phone = TextEditingController();
    final salary = TextEditingController();
    final key = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Add Worker",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 10),
                _field(name, "Name", Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Enter name"
                        : null),
                const SizedBox(height: 12),
                _field(phone, "Mobile Number", Icons.phone_outlined,
                    type: TextInputType.phone,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10)
                    ],
                    validator: (v) => (v == null || v.length != 10)
                        ? "Enter 10 digit number"
                        : null),
                const SizedBox(height: 12),
                _field(salary, "Salary (per day)", Icons.currency_rupee,
                    type: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                    (v == null || v.isEmpty) ? "Enter salary" : null),
                const SizedBox(height: 18),
                StatefulBuilder(
                  builder: (c, setSheet) => SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                        if (!key.currentState!.validate()) return;

                        setSheet(() => saving = true);
                        bool ok = false;
                        try {
                          ok = await Provider.of<TaskProvider>(context,
                              listen: false)
                              .addWages(
                            context: context,
                            empName: name.text,
                            empContact: phone.text,
                            rate: salary.text,
                          );
                        } catch (e) {
                          debugPrint("Add worker error: $e");
                        }

                        if (ok) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          _loadWorkers(); // loader + refresh list
                        } else if (ctx.mounted) {
                          setSheet(() => saving = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorsConst.primary,
                          disabledBackgroundColor:
                          colorsConst.primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: saving
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                          : const Text("Save Worker",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI HELPERS ----------------
  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? type,
        List<TextInputFormatter>? formatters,
        String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      inputFormatters: formatters,
      validator: validator,
      decoration: _dec(label, icon),
    );
  }

  Widget _workerTile(_Worker w) {
    final primary = colorsConst.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: primary.withOpacity(0.12),
          child: Text(w.name.isEmpty ? "?" : w.name[0].toUpperCase(),
              style: TextStyle(
                  color: primary, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(w.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.phone_outlined,
                    size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(w.phone,
                    style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ]),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹${w.salary.toStringAsFixed(0)}",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700)),
              Text("per day",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.only(top: 80),
    child: Column(children: [
      Icon(Icons.groups_outlined, size: 60, color: Colors.grey.shade400),
      const SizedBox(height: 10),
      Text("No Workers Added",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      const SizedBox(height: 4),
      Text("Tap 'Add Worker' to add your first worker",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final primary = colorsConst.primary;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Wages Workers",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : RefreshIndicator(
        onRefresh: () => _loadWorkers(pull: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (_workers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 2),
                child: Text("Total Workers: ${_workers.length}",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
              ),
            if (_workers.isEmpty) _emptyState(),
            ..._workers.map(_workerTile),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _openAddWorker,
              icon: const Icon(Icons.person_add_alt_1,
                  size: 18, color: Colors.white),
              label: const Text("Add Worker",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ),
      ),
    );
  }
}