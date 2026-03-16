import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/utils/date_utils.dart';

void main() {
  group('AppDateUtils.timeAgo', () {
    test('returns "Just now" for current time', () {
      expect(AppDateUtils.timeAgo(DateTime.now()), 'Just now');
    });

    test('returns "Just now" for a few seconds ago', () {
      final date = DateTime.now().subtract(const Duration(seconds: 30));
      expect(AppDateUtils.timeAgo(date), 'Just now');
    });

    test('returns "1m ago" for 1 minute ago', () {
      final date = DateTime.now().subtract(const Duration(minutes: 1));
      expect(AppDateUtils.timeAgo(date), '1m ago');
    });

    test('returns "5m ago" for 5 minutes ago', () {
      final date = DateTime.now().subtract(const Duration(minutes: 5));
      expect(AppDateUtils.timeAgo(date), '5m ago');
    });

    test('returns "59m ago" for 59 minutes ago', () {
      final date = DateTime.now().subtract(const Duration(minutes: 59));
      expect(AppDateUtils.timeAgo(date), '59m ago');
    });

    test('returns "1h ago" for 1 hour ago', () {
      final date = DateTime.now().subtract(const Duration(hours: 1));
      expect(AppDateUtils.timeAgo(date), '1h ago');
    });

    test('returns "12h ago" for 12 hours ago', () {
      final date = DateTime.now().subtract(const Duration(hours: 12));
      expect(AppDateUtils.timeAgo(date), '12h ago');
    });

    test('returns "23h ago" for 23 hours ago', () {
      final date = DateTime.now().subtract(const Duration(hours: 23));
      expect(AppDateUtils.timeAgo(date), '23h ago');
    });

    test('returns "1d ago" for 1 day ago', () {
      final date = DateTime.now().subtract(const Duration(days: 1));
      expect(AppDateUtils.timeAgo(date), '1d ago');
    });

    test('returns "15d ago" for 15 days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 15));
      expect(AppDateUtils.timeAgo(date), '15d ago');
    });

    test('returns "30d ago" for exactly 30 days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 30));
      expect(AppDateUtils.timeAgo(date), '30d ago');
    });

    test('returns "1mo ago" for 31 days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 31));
      expect(AppDateUtils.timeAgo(date), '1mo ago');
    });

    test('returns "6mo ago" for ~180 days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 185));
      expect(AppDateUtils.timeAgo(date), '6mo ago');
    });

    test('returns "11mo ago" for ~350 days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 350));
      expect(AppDateUtils.timeAgo(date), '11mo ago');
    });

    test('returns "1y ago" for 366 days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 366));
      expect(AppDateUtils.timeAgo(date), '1y ago');
    });

    test('returns "2y ago" for ~730 days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 731));
      expect(AppDateUtils.timeAgo(date), '2y ago');
    });

    test('returns "5y ago" for ~1825 days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 1826));
      expect(AppDateUtils.timeAgo(date), '5y ago');
    });

    test('boundary: 60 minutes equals 1h ago', () {
      final date = DateTime.now().subtract(const Duration(minutes: 60));
      expect(AppDateUtils.timeAgo(date), '1h ago');
    });

    test('boundary: 24 hours equals 1d ago', () {
      final date = DateTime.now().subtract(const Duration(hours: 24));
      expect(AppDateUtils.timeAgo(date), '1d ago');
    });

    test('boundary: 365 days is still in months range', () {
      final date = DateTime.now().subtract(const Duration(days: 365));
      expect(AppDateUtils.timeAgo(date), '12mo ago');
    });
  });

  group('AppDateUtils.formatDate', () {
    test('formats a typical date', () {
      final date = DateTime(2024, 3, 15);
      expect(AppDateUtils.formatDate(date), '15/3/2024');
    });

    test('formats January 1st', () {
      final date = DateTime(2024, 1, 1);
      expect(AppDateUtils.formatDate(date), '1/1/2024');
    });

    test('formats December 31st', () {
      final date = DateTime(2024, 12, 31);
      expect(AppDateUtils.formatDate(date), '31/12/2024');
    });

    test('formats a date with single-digit day and month', () {
      final date = DateTime(2023, 5, 9);
      expect(AppDateUtils.formatDate(date), '9/5/2023');
    });

    test('formats a leap year date (Feb 29)', () {
      final date = DateTime(2024, 2, 29);
      expect(AppDateUtils.formatDate(date), '29/2/2024');
    });

    test('formats a date in a past century', () {
      final date = DateTime(1999, 12, 25);
      expect(AppDateUtils.formatDate(date), '25/12/1999');
    });

    test('formats a future date', () {
      final date = DateTime(2030, 6, 1);
      expect(AppDateUtils.formatDate(date), '1/6/2030');
    });

    test('formats the Unix epoch', () {
      final date = DateTime(1970, 1, 1);
      expect(AppDateUtils.formatDate(date), '1/1/1970');
    });
  });
}
