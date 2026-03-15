import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _display    = DateFormat('dd MMM yyyy');
  static final DateFormat _displayDT  = DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat _storage    = DateFormat('yyyy-MM-dd');
  static final DateFormat _storageDT  = DateFormat('yyyy-MM-ddTHH:mm:ss');

  static String toDisplay(DateTime dt)    => _display.format(dt);
  static String toDisplayDT(DateTime dt)  => _displayDT.format(dt);
  static String toStorage(DateTime dt)    => _storage.format(dt);
  static String toStorageDT(DateTime dt)  => _storageDT.format(dt);
  static DateTime fromStorage(String s)   => _storage.parse(s);
  static DateTime fromStorageDT(String s) => _storageDT.parse(s);

  /// Returns gestational age in weeks from LMP
  static int gestationWeeks(DateTime lmp) {
    return DateTime.now().difference(lmp).inDays ~/ 7;
  }

  /// Expected Delivery Date = LMP + 280 days
  static DateTime calcEDD(DateTime lmp) {
    return lmp.add(const Duration(days: 280));
  }
}
