import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumbungemas/features/pricing/presentation/providers/pricing_provider.dart';

class PriceManagementScreen extends ConsumerStatefulWidget {
  const PriceManagementScreen({super.key});

  @override
  ConsumerState<PriceManagementScreen> createState() => _PriceManagementScreenState();
}

class _PriceManagementScreenState extends ConsumerState<PriceManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();

  String _selectedBrand = AppConstants.supportedBrands.first;
  MetalType _selectedMetalType = MetalType.gold;

  @override
  void dispose() {
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    super.dispose();
  }

  double? _parseRupiah(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;
    return double.tryParse(digitsOnly);
  }

  Future<void> _savePrice() async {
    if (!_formKey.currentState!.validate()) return;

    final buyPrice = _parseRupiah(_buyPriceController.text);
    final sellPrice = _parseRupiah(_sellPriceController.text);

    if (buyPrice == null || sellPrice == null || buyPrice <= 0 || sellPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga beli/jual tidak valid')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    final success = await ref.read(pricingProvider.notifier).updateTodayPrice(
          brand: _selectedBrand,
          metalType: _selectedMetalType,
          buyPrice: buyPrice,
          sellPrice: sellPrice,
          updatedBy: currentUser?.email,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga hari ini berhasil diperbarui')),
      );
      Navigator.pop(context);
      return;
    }

    final error = ref.read(pricingProvider).error ?? 'Gagal memperbarui harga';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pricingState = ref.watch(pricingProvider);
    final today = DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Harga Hari Ini'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.secondary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'Tanggal update: $today',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Brand', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedBrand,
                items: AppConstants.supportedBrands
                    .map((brand) => DropdownMenuItem(value: brand, child: Text(brand)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedBrand = value);
                },
                decoration: const InputDecoration(hintText: 'Pilih brand'),
              ),
              const SizedBox(height: 24),
              const Text('Jenis Logam', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<MetalType>(
                initialValue: _selectedMetalType,
                items: MetalType.values
                    .map((type) => DropdownMenuItem(value: type, child: Text(type.displayName)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedMetalType = value);
                },
                decoration: const InputDecoration(hintText: 'Pilih logam'),
              ),
              const SizedBox(height: 24),
              const Text('Harga Beli (Rp)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _buyPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _RupiahTextInputFormatter(),
                ],
                decoration: const InputDecoration(hintText: 'Contoh: 1.500.000'),
                validator: (value) {
                  final parsed = _parseRupiah(value);
                  if (parsed == null || parsed <= 0) return 'Harga beli wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Harga Jual (Rp)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sellPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _RupiahTextInputFormatter(),
                ],
                decoration: const InputDecoration(hintText: 'Contoh: 1.450.000'),
                validator: (value) {
                  final parsed = _parseRupiah(value);
                  if (parsed == null || parsed <= 0) return 'Harga jual wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: pricingState.isLoading ? null : _savePrice,
                icon: pricingState.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(pricingState.isLoading ? 'Menyimpan...' : 'Simpan Harga Hari Ini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RupiahTextInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final value = int.parse(digitsOnly);
    final newText = _formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
