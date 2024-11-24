class PointTransaction {
  final int refId;
  final String userName;
  final double points;
  final double pointBalance;
  final double currentPoints;
  final DateTime createdOn;
  final String type;
  final String posName;
  final String status;
  final String userUid;
  final String imageUrl;
  final bool isChecked;
  final String? checkedBy;
  final String notes;
  final String userNotes;

  final DateTime updatedOn;

  PointTransaction({
    required this.refId,
    required this.userNotes,
    required this.currentPoints,
    required this.userName,
    required this.points,
    required this.createdOn,
    required this.type,
    required this.pointBalance,
    required this.posName,
    required this.status,
    required this.userUid,
    required this.imageUrl,
    required this.isChecked,
    required this.notes,
    this.checkedBy,
    required this.updatedOn,
  });

  /// Converts the object to a Firestore-compatible map
  Map<String, dynamic> toFirestoreMap() {
    return {
      'refId': refId,
      'userName': userName,
      'points': points,
      'pointBalance': pointBalance,
      'createdOn': createdOn.toIso8601String(),
      'type': type,
      'posName': posName,
      'notes': notes,
      'status': status,
      'currentPoints': currentPoints,
      'userUid': userUid,
      'imageUrl': imageUrl,
      'isChecked': isChecked,
      'userNotes': userNotes,
      'checkedBy': checkedBy,
      'updatedOn': updatedOn.toIso8601String(),
    };
  }

  /// Factory constructor to create a PointTransaction from Firestore data
  factory PointTransaction.fromFirestoreMap(Map<String, dynamic> data) {
    return PointTransaction(
      refId: data['refId'] as int,
      userNotes: data['userNotes'] as String,
      notes: data['notes'] as String,
      userName: data['userName'] as String,
      points: (data['points'] as num).toDouble(),
      currentPoints: (data['currentPoints'] as num).toDouble(),
      pointBalance: (data['pointBalance'] as num).toDouble(),
      createdOn: DateTime.parse(data['createdOn'] as String),
      type: data['type'] as String,
      posName: data['posName'] as String,
      status: data['status'] as String,
      userUid: data['userUid'] as String,
      imageUrl: data['imageUrl'] as String,
      isChecked: data['isChecked'] as bool,
      checkedBy: data['checkedBy'] as String?,
      updatedOn: DateTime.parse(data['updatedOn'] as String),
    );
  }
}
