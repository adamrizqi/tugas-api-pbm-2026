import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../models/produk_model.dart';
import '../services/api_service.dart';
import '../utils/notif_helper.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  Future<List<Product>>? _productsFuture;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    String? token = await _storage.read(key: 'token');
    String? name = await _storage.read(key: 'name');
    if (token != null) {
      setState(() {
        _userName = name ?? 'User';
        _productsFuture = _apiService.getProducts(token);
      });
    }
  }

  void _logout() async {
    await _storage.delete(key: 'token');
    if (mounted) {
      showCenterNotification(context, 'Berhasil Logout');
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void _hapusDraft(int id) async {
    String? token = await _storage.read(key: 'token');
    if (token != null) {
      bool res = await _apiService.deleteProduct(token, id);
      if (res) {
        if (mounted) showCenterNotification(context, 'Draft berhasil dihapus');
        _fetchData();
      } else {
        if (mounted) showCenterNotification(context, 'Gagal menghapus draft', isError: true);
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
        backgroundColor: const Color(0xFFFAF9F5),
        title: Text('Tambah Produk', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF1B1C1A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nama Produk', labelStyle: GoogleFonts.inter(), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF775A19))))),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga', labelStyle: GoogleFonts.inter(), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF775A19))))),
            TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Deskripsi', labelStyle: GoogleFonts.inter(), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF775A19))))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.inter(color: const Color(0xFF5F5E5E)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF775A19)),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
                showCenterNotification(context, 'Semua kolom wajib diisi!', isError: true);
                return;
              }
              
              int? price = int.tryParse(priceCtrl.text);
              if (price == null) {
                showCenterNotification(context, 'Harga harus berupa angka!', isError: true);
                return;
              }

              String? token = await _storage.read(key: 'token');
              if (token != null) {
                bool res = await _apiService.saveProduct(token, nameCtrl.text, price, descCtrl.text);
                
                if (context.mounted) Navigator.pop(context);
                
                if (res) {
                  if (context.mounted) {
                    showCenterNotification(context, 'Draft tersimpan');
                  }
                  await Future.delayed(const Duration(milliseconds: 500));
                  _fetchData();
                } else {
                  if (context.mounted) {
                    showCenterNotification(context, 'Gagal menyimpan draft', isError: true);
                  }
                }
              }
            },
            child: Text('Simpan', style: GoogleFonts.inter(color: Colors.white)),
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
        backgroundColor: const Color(0xFFFAF9F5),
        title: Text('Submit Tugas', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF1B1C1A))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nama', labelStyle: GoogleFonts.inter(), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF775A19))))),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga', labelStyle: GoogleFonts.inter(), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF775A19))))),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Deskripsi', labelStyle: GoogleFonts.inter(), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF775A19))))),
              TextField(controller: githubCtrl, decoration: InputDecoration(labelText: 'Link GitHub', labelStyle: GoogleFonts.inter(), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF775A19))))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.inter(color: const Color(0xFF5F5E5E)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF775A19)),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty || githubCtrl.text.isEmpty) {
                showCenterNotification(context, 'Semua kolom wajib diisi!', isError: true);
                return;
              }

              int? price = int.tryParse(priceCtrl.text);
              if (price == null) {
                showCenterNotification(context, 'Harga harus berupa angka!', isError: true);
                return;
              }

              String? token = await _storage.read(key: 'token');
              if (token != null) {
                bool res = await _apiService.submitAssignment(token, {
                  'name': nameCtrl.text,
                  'price': price,
                  'description': descCtrl.text,
                  'github_url': githubCtrl.text,
                });
                
                if (context.mounted) Navigator.pop(context);
                
                if (res) {
                  if (context.mounted) {
                    showCenterNotification(context, 'Tugas berhasil disubmit');
                  }
                } else {
                  if (context.mounted) {
                    showCenterNotification(context, 'Gagal submit tugas', isError: true);
                  }
                }
              }
            },
            child: Text('Submit', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFAF9F5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF775A19),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outlined, color: Color(0xFFFAF9F5)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B1C1A),
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDrawerItem(Icons.auto_awesome, 'Products', isActive: true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Color(0xFFBA1A1A)),
                label: Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFBA1A1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        title: Text(
          'Katalog Produk',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF1B1C1A),
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color.fromARGB(255, 112, 85, 25)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined, color: Color.fromARGB(255, 112, 85, 25)),
            onPressed: _submitTugasAkhir,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE3E2DF).withOpacity(0.5),
            height: 1,
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF775A19)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error mengambil data', style: GoogleFonts.inter()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Data kosong', style: GoogleFonts.inter()));
          }

          final products = snapshot.data!;
          
          return RefreshIndicator(
            onRefresh: () async {
              _fetchData();
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F0),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF775A19).withOpacity(0.03),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE9E8E4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF775A19), size: 28),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: GoogleFonts.playfairDisplay(
                                      color: const Color(0xFF1B1C1A),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A), size: 20),
                                  onPressed: () => _hapusDraft(product.id),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.description,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF4E4639),
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Rp ${product.price}.00',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF775A19),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahDraft,
        backgroundColor: const Color(0xFF2F312E),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        child: const Icon(Icons.add, color: Color(0xFFFAF9F5)),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF4F4F0) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF775A19) : const Color(0xFF4E4639),
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? const Color(0xFF775A19) : const Color(0xFF4E4639),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
