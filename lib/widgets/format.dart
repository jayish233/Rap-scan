/// Locale-light date formatting (English UI in v1, PRD §13).
library;

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// "22 Oct 2026, 1:28 PM" in the device's local time.
String formatDateTime(DateTime value) {
  final t = value.toLocal();
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  final period = t.hour < 12 ? 'AM' : 'PM';
  return '${t.day} ${_months[t.month - 1]} ${t.year}, $hour:$minute $period';
}

String _time(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  final period = t.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

/// Mockup style: "Today, 6:42 PM", "Yesterday, 4:30 PM", "Mon, 9:20 PM"
/// within the week, then "22 Oct, 1:28 PM".
String formatRelative(DateTime value) {
  final t = value.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;
  return switch (diff) {
    0 => 'Today, ${_time(t)}',
    1 => 'Yesterday, ${_time(t)}',
    <= 6 && > 1 => '${_weekdays[t.weekday - 1]}, ${_time(t)}',
    _ => '${t.day} ${_months[t.month - 1]}, ${_time(t)}',
  };
}

/// Thousands separator for kcal totals: 14280 → "14,280".
String formatThousands(int n) {
  final s = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
