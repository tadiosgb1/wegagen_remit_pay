class Bonus {
  final int id;
  final String description;
  final double amount; // Fixed amount in ETB per dollar/euro/etc
  final bool status;

  Bonus({
    required this.id,
    required this.description,
    required this.amount,
    required this.status,
  });

  factory Bonus.fromJson(Map<String, dynamic> json) {
    return Bonus(
      id: json['id'] as int,
      description: json['description'] as String,
      amount: double.parse(json['amount'].toString()),
      status: json['status'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount.toString(),
      'status': status,
    };
  }
}

class BonusResponse {
  final String status;
  final int count;
  final int totalPages;
  final int currentPage;
  final String? next;
  final String? previous;
  final int pageSize;
  final List<Bonus> data;

  BonusResponse({
    required this.status,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    this.next,
    this.previous,
    required this.pageSize,
    required this.data,
  });

  factory BonusResponse.fromJson(Map<String, dynamic> json) {
    return BonusResponse(
      status: json['status'] as String,
      count: json['count'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      pageSize: json['page_size'] as int,
      data: (json['data'] as List<dynamic>)
          .map((item) => Bonus.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'total_pages': totalPages,
      'current_page': currentPage,
      'next': next,
      'previous': previous,
      'page_size': pageSize,
      'data': data.map((bonus) => bonus.toJson()).toList(),
    };
  }
}