import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  final CollectionReference _db = FirebaseFirestore.instance.collection('menu');

  // หมวดหมู่ dropdown
  final List<String> categories = ["เนื้อสัตว์", "ผัก", "ของกินเล่น"];

  // เพิ่ม/แก้ไขเมนู
  void openMenuForm({String? id, String? name, String? category, String? image}) {
    // สร้าง controller และตัวแปร local สำหรับ dialog
    TextEditingController _nameCtrl = TextEditingController(text: name ?? "");
    TextEditingController _imageCtrl = TextEditingController(text: image ?? "");
    String? _selectedCategory = category;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(id == null ? "เพิ่มเมนู" : "แก้ไขเมนู"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: "ชื่อเมนู"),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: "หมวดหมู่"),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _imageCtrl,
                      decoration: const InputDecoration(labelText: "URL รูปภาพ"),
                    ),
                    const SizedBox(height: 10),
                    if (_imageCtrl.text.isNotEmpty)
                      Image.network(
                        _imageCtrl.text,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ยกเลิก"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedCategory == null || _nameCtrl.text.isEmpty) return;

                    if (id == null) {
                      // เพิ่มเมนูใหม่
                      await _db.add({
                        "name": _nameCtrl.text,
                        "category": _selectedCategory,
                        "image": _imageCtrl.text,
                      });
                    } else {
                      // แก้ไขเมนู
                      await _db.doc(id).update({
                        "name": _nameCtrl.text,
                        "category": _selectedCategory,
                        "image": _imageCtrl.text,
                      });
                    }

                    Navigator.pop(context);
                  },
                  child: Text(id == null ? "บันทึก" : "แก้ไข"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ลบเมนู
  Future deleteMenu(String id) async {
    await _db.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin: จัดการเมนู"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openMenuForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              var data = docs[i].data() as Map<String, dynamic>;
              String id = docs[i].id;

              return Card(
                child: ListTile(
                  leading: (data["image"] ?? "").isNotEmpty
                      ? Image.network(
                          data["image"],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.fastfood, size: 40),
                  title: Text(data["name"]),
                  subtitle: Text("หมวดหมู่: ${data["category"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => openMenuForm(
                          id: id,
                          name: data["name"],
                          category: data["category"],
                          image: data["image"],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteMenu(id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
