import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/listing_entity.dart';

class ListingModel extends ListingEntity {
  const ListingModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.description,
    required super.price,
    super.currency,
    required super.propertyType,
    required super.furnishing,
    required super.bedrooms,
    required super.bathrooms,
    required super.sqft,
    required super.address,
    required super.amenities,
    required super.images,
    required super.imageUrls,
    required super.searchTokens,
    super.latitude,
    super.longitude,
    super.embedding,
    required super.status,
    super.fraudRiskScore,
    super.fraudSignals,
    super.averageRating,
    super.reviewCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      propertyType: json['propertyType'] as String,
      furnishing: json['furnishing'] as String? ?? 'Unfurnished',
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      sqft: (json['sqft'] as num).toDouble(),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as int?) ?? 0,
      address: Map<String, dynamic>.from(json['address'] as Map),
      amenities: List<String>.from(json['amenities'] as List),
      images: List<String>.from(json['images'] as List),
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      searchTokens: List<String>.from(json['searchTokens'] as List),
      latitude: _safeParseDouble(json['latitude'], 11.0168),
      longitude: _safeParseDouble(json['longitude'], 76.9558),
      embedding: json['embedding'] != null
          ? List<double>.from(json['embedding'] as List)
          : null,
      status: json['status'] as String,
      fraudRiskScore: (json['fraudRiskScore'] as num?)?.toDouble(),
      fraudSignals: json['fraudSignals'] != null
          ? List<String>.from(json['fraudSignals'] as List)
          : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory ListingModel.fromEntity(ListingEntity entity) {
    return ListingModel(
      id: entity.id,
      ownerId: entity.ownerId,
      title: entity.title,
      description: entity.description,
      price: entity.price,
      currency: entity.currency,
      propertyType: entity.propertyType,
      furnishing: entity.furnishing,
      bedrooms: entity.bedrooms,
      bathrooms: entity.bathrooms,
      sqft: entity.sqft,
      address: entity.address,
      amenities: entity.amenities,
      images: entity.images,
      imageUrls: entity.imageUrls,
      searchTokens: entity.searchTokens,
      latitude: entity.latitude,
      longitude: entity.longitude,
      embedding: entity.embedding,
      status: entity.status,
      fraudRiskScore: entity.fraudRiskScore,
      fraudSignals: entity.fraudSignals,
      averageRating: entity.averageRating,
      reviewCount: entity.reviewCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'propertyType': propertyType,
      'furnishing': furnishing,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'sqft': sqft,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'address': address,
      'amenities': amenities,
      'images': images,
      'imageUrls': imageUrls,
      'searchTokens': searchTokens,
      'latitude': latitude,
      'longitude': longitude,
      'embedding': embedding,
      'status': status,
      'fraudRiskScore': fraudRiskScore,
      'fraudSignals': fraudSignals,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory ListingModel.fromMap(Map<String, dynamic> map) =>
      ListingModel.fromJson(map);

  static double _safeParseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}
