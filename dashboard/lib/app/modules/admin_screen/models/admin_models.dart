import 'package:flutter/material.dart';

enum PlaceStatus { pending, approved, rejected }

class AdminPlace {
  final String id;
  final String name;
  final String subtitle;
  final String company;
  final String category;
  final String province;
  final String fee; // e.g. "\$37" or "Free"
  final String submittedDate;
  final PlaceStatus status;
  final Color imageColor;
  final String? imageUrl;

  const AdminPlace({
    this.id = "",
    required this.name,
    required this.subtitle,
    required this.company,
    required this.category,
    required this.province,
    required this.fee,
    required this.submittedDate,
    required this.status,
    required this.imageColor,
    this.imageUrl,
  });
}

// Generic row shape shared by Manage Hotels / Manage Packages / Manage
// Restaurants — those three collections don't have the province+category
// mix AdminPlace has, but they all share the same submit -> pending ->
// admin approves/rejects/deletes workflow, so one model + one page widget
// (AdminManageListingPage) covers all three instead of tripling the code.
class AdminListingItem {
  final String id;
  final String name;
  final String subtitle;
  final String owner;
  final String typeLabel; // e.g. star rating, cuisine, duration
  final String location;
  final String price;
  final String submittedDate;
  final PlaceStatus status;
  final Color imageColor;
  final String? imageUrl;

  const AdminListingItem({
    this.id = "",
    required this.name,
    required this.subtitle,
    required this.owner,
    required this.typeLabel,
    required this.location,
    required this.price,
    required this.submittedDate,
    required this.status,
    required this.imageColor,
    this.imageUrl,
  });
}

class AdminCompany {
  final String name;
  final String id;
  final String initials;
  final Color color;
  final String email;
  final String phone;
  final String businessType;
  final Color businessTypeColor;
  final String location;
  final int places;
  final String joined;
  final bool suspended;

  const AdminCompany({
    required this.name,
    required this.id,
    required this.initials,
    required this.color,
    required this.email,
    required this.phone,
    required this.businessType,
    required this.businessTypeColor,
    required this.location,
    required this.places,
    required this.joined,
    this.suspended = false,
  });
}

class ProvinceStat {
  final String province;
  final int places;
  final int share; // percent
  final int growth; // percent
  const ProvinceStat({
    required this.province,
    required this.places,
    required this.share,
    required this.growth,
  });
}

class CategoryStat {
  final String label;
  final int percent;
  final Color color;
  const CategoryStat({
    required this.label,
    required this.percent,
    required this.color,
  });
}