import 'package:lumbungemas/features/portfolio/domain/entities/metal_asset.dart';

enum AssetSortOption {
  purchaseDate,
  updatedAt,
  brand,
  weight,
}

extension AssetSortOptionX on AssetSortOption {
  String get label {
    switch (this) {
      case AssetSortOption.purchaseDate:
        return 'Tanggal beli';
      case AssetSortOption.updatedAt:
        return 'Terakhir diupdate';
      case AssetSortOption.brand:
        return 'Brand';
      case AssetSortOption.weight:
        return 'Berat';
    }
  }

  List<MetalAsset> sortAssets(List<MetalAsset> assets) {
    final sortedAssets = List<MetalAsset>.from(assets);

    sortedAssets.sort((a, b) {
      switch (this) {
        case AssetSortOption.purchaseDate:
          return _compareDateDesc(a.purchaseDate, b.purchaseDate);
        case AssetSortOption.updatedAt:
          return _compareDateDesc(a.updatedAt, b.updatedAt);
        case AssetSortOption.brand:
          final brandComparison = a.brand.toLowerCase().compareTo(
            b.brand.toLowerCase(),
          );
          if (brandComparison != 0) {
            return brandComparison;
          }
          return _compareDateDesc(a.purchaseDate, b.purchaseDate);
        case AssetSortOption.weight:
          final weightComparison = b.weightGram.compareTo(a.weightGram);
          if (weightComparison != 0) {
            return weightComparison;
          }
          return _compareDateDesc(a.purchaseDate, b.purchaseDate);
      }
    });

    return sortedAssets;
  }

  static int _compareDateDesc(DateTime a, DateTime b) {
    return b.compareTo(a);
  }
}
