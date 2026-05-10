import '../entities/listing_entity.dart';
import '../../../../core/errors/failures.dart';

/// Listing repository interface - contract for data layer
abstract class ListingRepository {
  /// Get single listing
  Future<({Listing? listing, Failure? failure})> getListing(String id);

  /// Get all listings with filters and pagination
  Stream<List<Listing>> getListings({
    String? category,
    int limit = 20,
  });

  /// Create listing
  Future<({String? id, Failure? failure})> createListing({
    required String title,
    required String description,
    required double price,
    String? imageUrl,
    String? category,
    String? location,
  });

  /// Update listing
  Future<Failure?> updateListing({
    required String id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    String? location,
    ListingStatus? status,
  });

  /// Delete listing
  Future<Failure?> deleteListing(String id);

  /// Search listings
  Stream<List<Listing>> searchListings(String query, {int limit = 20});
}