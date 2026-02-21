import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';
import 'package:lumbungemas/core/theme/app_colors.dart';
import 'package:lumbungemas/core/utils/validators.dart';
import 'package:lumbungemas/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';
import 'package:lumbungemas/features/portfolio/presentation/providers/portfolio_provider.dart';
import 'package:lumbungemas/features/pricing/presentation/providers/pricing_provider.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final MetalAsset? editingAsset;

  const AddTransactionScreen({
    super.key,
    this.editingAsset,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedBrand = 'Antam';
  MetalType _selectedMetal = MetalType.gold;
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  double? _parseRupiah(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;
    return double.tryParse(digitsOnly);
  }

  @override
  void initState() {
    super.initState();
    final editingAsset = widget.editingAsset;
    if (editingAsset == null) return;

    _selectedBrand = editingAsset.brand;
    _selectedMetal = editingAsset.metalType;
    _selectedDate = editingAsset.purchaseDate;
    _weightController.text = editingAsset.weightGram.toString();
    _priceController.text = NumberFormat.decimalPattern(
      'id_ID',
    ).format(editingAsset.totalPurchaseValue.toInt());
    _notesController.text = editingAsset.notes ?? '';
  }

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final weight = double.tryParse(_weightController.text);
      final priceTotal = _parseRupiah(_priceController.text);

      if (weight == null || weight <= 0 || priceTotal == null || priceTotal <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Input berat/harga tidak valid')),
        );
        return;
      }

      final pricePerGram = priceTotal / weight;
      final editingAsset = widget.editingAsset;

      final asset = MetalAsset(
        transactionId: editingAsset?.transactionId ?? const Uuid().v4(),
        userId: user.userId,
        brand: _selectedBrand,
        metalType: _selectedMetal,
        weightGram: weight,
        purchasePricePerGram: pricePerGram,
        totalPurchaseValue: priceTotal,
        purchaseDate: _selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: editingAsset?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final action = editingAsset == null
          ? ref.read(portfolioProvider.notifier).addTransaction(asset)
          : ref.read(portfolioProvider.notifier).updateTransaction(asset);

      action.then((_) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                editingAsset == null
                    ? 'Transaksi berhasil ditambahkan!'
                    : 'Transaksi berhasil diperbarui!',
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(portfolioProvider).isLoading;
    final isEditMode = widget.editingAsset != null;
    final pricingState = ref.watch(pricingProvider);
    final brandOptions = _buildBrandOptions(pricingState, _selectedBrand);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metal Type Toggle
              const Text('Jenis Logam', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetalToggle(
                    MetalType.gold,
                    'Emas',
                    'assets/images/ic-gold.svg',
                  ),
                  const SizedBox(width: 12),
                  _buildMetalToggle(
                    MetalType.silver,
                    'Perak',
                    'assets/images/ic-silver.svg',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Brand
              const Text('Brand', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedBrand,
                items: brandOptions
                    .map(
                      (b) => DropdownMenuItem(
                        value: b,
                        child: _buildBrandOption(b),
                      ),
                    )
                    .toList(),
                selectedItemBuilder: (context) => brandOptions
                    .map((b) => _buildBrandOption(b))
                    .toList(),
                onChanged: (val) => setState(() => _selectedBrand = val!),
                decoration: const InputDecoration(hintText: 'Pilih Brand'),
              ),
              const SizedBox(height: 24),

              // Weight
              const Text('Berat (gram)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'Contoh: 5.0'),
                validator: Validators.weight,
              ),
              const SizedBox(height: 24),

              // Total Price
              const Text('Total Harga Beli (Rp)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  RupiahTextInputFormatter(),
                ],
                decoration: const InputDecoration(hintText: 'Contoh: 5000000'),
                validator: (val) {
                  final parsedPrice = _parseRupiah(val);
                  if (parsedPrice == null) return 'Wajib diisi';
                  if (parsedPrice < AppConstants.minPrice) {
                    return 'Price must be at least Rp ${AppConstants.minPrice}';
                  }
                  if (parsedPrice > AppConstants.maxPrice) {
                    return 'Price seems unrealistic';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Date
              const Text('Tanggal Pembelian', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Notes
              const Text('Catatan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Contoh: Hadiah ulang tahun'),
              ),
              const SizedBox(height: 48),

              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditMode ? 'Update Transaksi' : 'Simpan Transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetalToggle(MetalType type, String label, String iconAsset) {
    final isSelected = _selectedMetal == type;
    final backgroundColor = type == MetalType.gold
        ? (isSelected ? const Color(0xFFD4AF37) : const Color(0xFFFFF4CC))
        : (isSelected ? const Color(0xFF9AA0A6) : const Color(0xFFF1F3F5));
    final borderColor = type == MetalType.gold
        ? (isSelected ? const Color(0xFFB8860B) : const Color(0xFFE5D08F))
        : (isSelected ? const Color(0xFF7B8188) : const Color(0xFFD8DDE1));
    final foregroundColor = isSelected
        ? Colors.white
        : (type == MetalType.gold
            ? const Color(0xFF8A6A1A)
            : const Color(0xFF5F6670));

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMetal = type),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: SvgPicture.asset(
                  iconAsset,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandOption(String brand) {
    final logoPath = _brandLogoPath(brand);
    if (logoPath == null) {
      return Text(brand);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SvgPicture.asset(
            logoPath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          brand,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String? _brandLogoPath(String brand) {
    final normalized = brand.trim().toLowerCase();
    switch (normalized) {
      case 'antam':
        return 'assets/images/antam-logo.svg';
      case 'ubs':
        return 'assets/images/ubs-logo.svg';
      case 'emasku':
        return 'assets/images/emasku-logo.svg';
      case 'galeri 24':
      case 'galeri24':
        return 'assets/images/galeri24.svg';
      case 'bsi':
        return 'assets/images/bsi-logo.svg';
      default:
        return 'assets/icons/gold.svg';
    }
  }

  List<String> _buildBrandOptions(
    PricingState pricingState,
    String selectedBrand,
  ) {
    final unique = <String, String>{};
    for (final brand in AppConstants.supportedBrands) {
      unique[brand.trim().toLowerCase()] = brand;
    }
    for (final price in pricingState.prices) {
      final brand = price.brand.trim();
      if (brand.isEmpty) continue;
      unique.putIfAbsent(brand.toLowerCase(), () => brand);
    }
    final selected = selectedBrand.trim();
    if (selected.isNotEmpty) {
      unique.putIfAbsent(selected.toLowerCase(), () => selected);
    }
    return unique.values.toList();
  }
}

class RupiahTextInputFormatter extends TextInputFormatter {
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

    final number = int.parse(digitsOnly);
    final newText = _formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
