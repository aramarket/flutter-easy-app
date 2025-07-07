import 'package:intl/intl.dart';

class AppFormatter {

  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String formatStringDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd, MMMM yyyy').format(dateTime);
    return formattedDate;
  }

  static String formatRelativeDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    Duration diff = DateTime.now().difference(dateTime);

    if (diff.inDays < 1) {
      return "1D"; // Less than 1 day
    } else if (diff.inDays < 7) {
      return "${diff.inDays}D"; // Days ago
    } else if (diff.inDays < 30) {
      return "${(diff.inDays / 7).floor()}W"; // Weeks ago
    } else if (diff.inDays < 365) {
      return "${(diff.inDays / 30).floor()}M"; // Months ago
    } else {
      return "${(diff.inDays / 365).floor()}Y"; // Years ago
    }
  }

  static String maskEmail(String email) {
    // Split email into username and domain
    List<String> parts = email.split('@');
    if (parts.length != 2) {
      // Invalid email format
      return email;
    }

    String username = parts[0];
    String domain = parts[1];

    // Extract first two characters
    String firstTwo = username.substring(0, 2);

    // Extract last two characters
    String lastTwo = username.substring(username.length - 2);

    return '$firstTwo***$lastTwo@$domain';
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  static String formatPhoneNumber(String phoneNumber) {
    //Assuming a 10-digit US phone number format: (123) 456-7895
    if(phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6) }';
    }else if(phoneNumber.length == 11) {
      return '(${phoneNumber.substring(0, 4)}) ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7) }';
    }
    return phoneNumber;
  }
}