import 'package:intl/intl.dart';


NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id', decimalDigits: 0, name: 'Rp. ', symbol: 'Rp. ');


String numberToStrDay(int number) {
  switch (number) {
    case 1:
      return 'Senin';
    case 2:
      return 'Selasa';
    case 3:
      return 'Rabu';
    case 4:
      return 'Kamis';
    case 5:
      return 'Jum\'at';
    case 6:
      return 'Sabtu';
    case 7:
      return 'Minggu';
    default:
      return '';
  }
}

String numberToStrMonth(int number) {
  switch (number) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'Mei';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Agu';
    case 9:
      return 'Sep';
    case 10:
      return 'Okt';
    case 11:
      return 'Nov';
    case 12:
      return 'Des';
    default:
      return '';
  }
}
