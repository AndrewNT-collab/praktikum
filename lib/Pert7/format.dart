import 'package:intl/intl.dart';

String formatRupiah(int nominal) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(nominal);
}

String formatTanggal(DateTime tanggal) {
  return DateFormat('yyyy-MM-dd').format(tanggal);
}

String formatTanggalIndonesia(DateTime tanggal) {
  return DateFormat('dd MMMM yyyy', 'id_ID').format(tanggal);
}

DateTime parseTanggal(String tanggal) {
  return DateFormat('yyyy-MM-dd').parse(tanggal);
}