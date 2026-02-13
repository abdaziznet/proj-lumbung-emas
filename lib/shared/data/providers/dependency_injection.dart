import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:lumbungemas/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lumbungemas/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lumbungemas/features/auth/domain/repositories/auth_repository.dart';
import 'package:lumbungemas/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:lumbungemas/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:lumbungemas/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:lumbungemas/features/pricing/data/datasources/pricing_remote_datasource.dart';
import 'package:lumbungemas/features/pricing/data/repositories/pricing_repository_impl.dart';
import 'package:lumbungemas/features/pricing/domain/repositories/pricing_repository.dart';
import 'package:lumbungemas/shared/data/services/google_sheets_service.dart';

/// Logger provider
final loggerProvider = Provider<Logger>((ref) {
  return Logger();
});

/// Google Sheets service provider
final googleSheetsServiceProvider = Provider<GoogleSheetsService>((ref) {
  return GoogleSheetsService(
    googleSignIn: ref.watch(googleSignInProvider),
    logger: ref.watch(loggerProvider),
  );
});

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Google Sign-In instance provider
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(scopes: ['email', 'profile']);
});

/// Auth remote data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

/// Portfolio remote data source provider
final portfolioRemoteDataSourceProvider = Provider<PortfolioRemoteDataSource>((ref) {
  return PortfolioRemoteDataSourceImpl(
    ref.watch(googleSheetsServiceProvider),
  );
});

/// Portfolio repository provider
final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepositoryImpl(
    remoteDataSource: ref.watch(portfolioRemoteDataSourceProvider),
  );
});

/// Pricing remote data source provider
final pricingRemoteDataSourceProvider = Provider<PricingRemoteDataSource>((ref) {
  return PricingRemoteDataSourceImpl(
    ref.watch(googleSheetsServiceProvider),
  );
});

/// Pricing repository provider
final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  return PricingRepositoryImpl(
    remoteDataSource: ref.watch(pricingRemoteDataSourceProvider),
  );
});
