/// Locale-light date formatting (English UI in v1, PRD §13).
library;

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "22 Oct 2026, 1:28 PM" in the device's local time.
String formatDateTime(DateTime value) {
  final t = value.toLocal();
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  final period = t.hour < 12 ? 'AM' : 'PM';
  return '${t.day} ${_months[t.month - 1]} ${t.year}, $hour:$minute $period';
}
