import 'dart:convert';

class CustomUser {
  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String verification_code;
  final String login_verification_code;
  final String contact_verification_code;
  CustomUser({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.verification_code,
    required this.login_verification_code,
    required this.contact_verification_code,
  });

  factory CustomUser.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return CustomUser(
        id: json['id'],
        email:
        json['email'] ?? '', // Check if 'email' key exists and handle null
        firstName: json['first_name'] ??
            '', // Check if 'first_name' key exists and handle null
        lastName: json['last_name'] ??
            '', // Check if 'last_name' key exists and handle null
        password: json['password']?.toString() ?? '',
        verification_code: json['verification_code'] ??
            '', // Check if 'verification_code' key exists and handle null
        login_verification_code: json['login_verification_code'] ??
            '', // Check if 'login_verification_code' key exists and handle null
        contact_verification_code: json['contact_verification_code'] ??
            '', // Check if 'login_verification_code' key exists and handle null
      );
    } else if (json is int) {
      // If 'user' is an int, create a temporary user with empty fields
      return CustomUser(
        email: '',
        firstName: '',
        lastName: '',
        password: '',
        verification_code: '',
        login_verification_code: '',
        contact_verification_code: '',
      );
    } else {
      throw FormatException('Invalid user data format');
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'verification_code': verification_code,
      'login_verification_code': login_verification_code,
      'contact_verification_code': contact_verification_code
    };
  }
}

class PropertyImage {
  final int? id;
  final int? propertyId; // Change the type to int
  final CustomUser? user;
  final String image;
  final DateTime created_at;

  PropertyImage({
    this.id,
    this.propertyId, // Change the name to propertyId
    this.user,
    required this.image,
    required this.created_at,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'],
      propertyId: json['property'],
      user: json['user'] != null ? CustomUser.fromJson(json['user']) : null,
      image: json['image'],
      created_at: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property': propertyId, // Change the name to propertyId
      'user': user != null ? user!.toJson() : null,
      'image': image,
      'created_at': created_at.toIso8601String(),
    };
  }

  static List<PropertyImage> parseImagesList(dynamic jsonList) {
    if (jsonList is List) {
      return jsonList
          .map((imageJson) => PropertyImage.fromJson(imageJson))
          .toList();
    } else {
      print(
          'Invalid data format for images. Expected List, got: ${jsonList.runtimeType}');
      return [];
    }
  }

  static List<Map<String, dynamic>> imagesListToJson(
      List<PropertyImage> images) {
    return images.map((image) => image.toJson()).toList();
  }
}

class PropertyVideo {
  final int id;
  final Property property;
  final String video;

  PropertyVideo({
    required this.id,
    required this.property,
    required this.video,
  });

  factory PropertyVideo.fromJson(Map<String, dynamic> json) {
    return PropertyVideo(
      id: json['id'],
      property: Property.fromJson(json['property']),
      video: json['video'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'videos': video != null
          ? PropertyVideo.videosListToJson(video as List<PropertyVideo>)
          : [],
    };
  }

  static List<Map<String, dynamic>> videosListToJson(
      List<PropertyVideo> videos) {
    return videos.map((video) => video.toJson()).toList();
  }

  static List<PropertyVideo> parseVideosList(List<dynamic> jsonList) {
    return jsonList
        .map((videoJson) => PropertyVideo.fromJson(videoJson))
        .toList();
  }
}

class Property {
  final int? id;
  final CustomUser user;
  final String option;
  final String title;
  final String content;
  final String city;
  final int area;
  final String locality;
  final int floor;
  final String propertyType;
  final String transactionType;
  final double price;
  final int areaSqft;
  final String ownerName;
  final String contactNumber;
  final String facingDirection;
  final String status;
  final DateTime createdAt;
  final List<PropertyImage> images;
  final List<PropertyVideo> videos;

  Property({
    this.id,
    required this.user,
    required this.option,
    required this.title,
    required this.content,
    required this.city,
    required this.area,
    required this.locality,
    required this.floor,
    required this.propertyType,
    required this.transactionType,
    required this.price,
    required this.areaSqft,
    required this.ownerName,
    required this.contactNumber,
    required this.facingDirection,
    required this.status,
    required this.createdAt,
    required this.images,
    required this.videos,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      user: CustomUser.fromJson(json['user']),
      option:json['option'],
      title: json['title'],
      content: json['content'],
      city: json['city'],
      area: json['area'],
      locality: json['locality'],
      floor: json['floor'],
      propertyType: json['property_type'],
      transactionType: json['transaction_type'],
      price: double.parse(json['price']),
      areaSqft: json['area_sqft'],
      ownerName: json['owner_name'],
      contactNumber: json['contact_number'],
      facingDirection: json['facing_direction'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      images: json['images'] is List
          ? PropertyImage.parseImagesList(json['images'])
          : [],
      videos: json['videos'] is List
          ? PropertyVideo.parseVideosList(json['videos'])
          : [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'option':option,
      'title': title,
      'content': content,
      'city': city,
      'area': area,
      'locality': locality,
      'floor': floor,
      'property_type': propertyType,
      'transaction_type': transactionType,
      'price': price,
      'area_sqft': areaSqft,
      'owner_name': ownerName,
      'contact_number': contactNumber,
      'facing_direction': facingDirection,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'images': PropertyImage.imagesListToJson(images),
      'videos': PropertyVideo.videosListToJson(videos),
    };
  }

  static List<Property> parsePropertiesList(dynamic jsonList) {
    if (jsonList is List) {
      return jsonList
          .map((propertyJson) => Property.fromJson(propertyJson))
          .toList();
    } else if (jsonList is Map<String, dynamic> &&
        jsonList.containsKey('results')) {
      final results = jsonList['results'];
      if (results is List) {
        return results
            .map((propertyJson) => Property.fromJson(propertyJson))
            .toList();
      }
    }

    // Handle the case where no properties are available
    print('No properties available.');
    return [];
  }

  static List<Property> parseUserProperties(String responseBody) {
    final parsed = json.decode(responseBody);

    if (parsed is List) {
      return parsed.map<Property>((json) => Property.fromJson(json)).toList();
    } else if (parsed is Map<String, dynamic> &&
        parsed.containsKey('results')) {
      final List<dynamic> results = parsed['results'];
      return results.map<Property>((json) => Property.fromJson(json)).toList();
    } else if (parsed is int) {
      print('No properties available.');
      return [];
    } else {
      print('Invalid data format for properties: $parsed');
      return [];
    }
  }
}