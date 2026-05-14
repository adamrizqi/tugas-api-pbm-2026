import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/produk_model.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  Future<List<Product>>? _productsFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    String? token = await _storage.read(key: 'token');
    if (token != null) {
      setState(() {
        _productsFuture = _apiService.getProducts(token);
      });
    }
  }

  void _hapusDraft(int id) async {
    String? token = await _storage.read(key: 'token');
    if (token != null) {
      bool res = await _apiService.deleteProduct(token, id);
      if (res) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft berhasil dihapus')));
        _fetchData();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus draft')));
      }
    }
  }

  void _tambahDraft() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk')),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              String? token = await _storage.read(key: 'token');
              if (token != null) {
                bool res = await _apiService.saveProduct(token, nameCtrl.text, int.parse(priceCtrl.text), descCtrl.text);
                
                if (context.mounted) Navigator.pop(context);
                
                if (res) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft tersimpan')));
                  }
                  await Future.delayed(const Duration(milliseconds: 500));
                  _fetchData();
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan draft')));
                  }
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _submitTugasAkhir() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final githubCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Tugas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi')),
              TextField(controller: githubCtrl, decoration: const InputDecoration(labelText: 'Link GitHub')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              String? token = await _storage.read(key: 'token');
              if (token != null) {
                bool res = await _apiService.submitAssignment(token, {
                  'name': nameCtrl.text,
                  'price': int.parse(priceCtrl.text),
                  'description': descCtrl.text,
                  'github_url': githubCtrl.text,
                });
                
                if (context.mounted) Navigator.pop(context);
                
                if (res) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tugas berhasil disubmit')));
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal submit tugas')));
                  }
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitTugasAkhir,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data kosong'));
          }

          final products = snapshot.data!;
          
          return RefreshIndicator(
            onRefresh: () async {
              _fetchData();
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(product.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Rp ${product.price}'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapusDraft(product.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahDraft,
        child: const Icon(Icons.add),
      ),
    );
  }
}