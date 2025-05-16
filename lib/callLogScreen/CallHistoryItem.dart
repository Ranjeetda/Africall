class CallHistoryItem {
  final int startDate;      // The start time of the call (UNIX timestamp)
  final String direction;   // 'Incoming' or 'Outgoing'
  final String status;      // 'Missed', 'Completed', etc.
  final String contactName; // Optional
  final String sipAddress;  // Optional

  CallHistoryItem({
    required this.startDate,
    required this.direction,
    required this.status,
    required this.contactName,
    required this.sipAddress,
  });

  // Factory constructor if you are getting a Map<String, dynamic> from JSON or plugin
  factory CallHistoryItem.fromMap(Map<String, dynamic> map) {
    return CallHistoryItem(
      startDate: map['startDate'] ?? 0,
      direction: map['direction'] ?? '',
      status: map['status'] ?? '',
      contactName: map['contactName'] ?? '',
      sipAddress: map['sipAddress'] ?? '',
    );
  }
}
