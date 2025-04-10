class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  String membershipStatus;
  int loyaltyPoints;
  double totalSpending;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.membershipStatus,
    required this.loyaltyPoints,
    required this.totalSpending,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['CustomerId'],
      firstName: json['FirstName'],
      lastName: json['LastName'],
      email: json['Email'],
      membershipStatus: json['MembershipStatus'],
      loyaltyPoints: json['LoyaltyPoints'] ?? 0,
      totalSpending: (json['TotalSpending'] as num).toDouble(),
    );
  }
}
