import Foundation

enum DateUtilities {

  private static let utcCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
  }()

  /// Day of year (1-based) for a given Date in UTC.
  static func dayOfYear(for date: Date) -> Int {
    utcCalendar.ordinality(of: .day, in: .year, for: date) ?? 1
  }

  /// Whether the year of the given date is a leap year.
  static func isLeapYear(for date: Date) -> Bool {
    let year = utcCalendar.component(.year, from: date)
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
  }

  /// Number of days in the year of the given date.
  static func daysInYear(for date: Date) -> Int {
    isLeapYear(for: date) ? 366 : 365
  }

  /// Extract (year, month, day, hour, minute, second) in UTC.
  static func utcComponents(from date: Date) -> DateComponents {
    utcCalendar.dateComponents(
      [.year, .month, .day, .hour, .minute, .second],
      from: date
    )
  }

  /// Extract (year, month, day) in the given timezone.
  static func dateComponents(
    from date: Date,
    in timeZone: TimeZone
  ) -> DateComponents {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    return calendar.dateComponents([.year, .month, .day], from: date)
  }

  /// Build a Date from year/month/day plus fractional UTC hours.
  static func date(
    year: Int,
    month: Int,
    day: Int,
    utcHours: Double
  ) -> Date? {
    let totalSeconds = utcHours * 3600.0
    let hour = Int(totalSeconds / 3600.0)
    let minute = Int((totalSeconds.truncatingRemainder(dividingBy: 3600.0)) / 60.0)
    let second = Int(totalSeconds.truncatingRemainder(dividingBy: 60.0))

    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    components.second = second
    components.timeZone = TimeZone(identifier: "UTC")

    return utcCalendar.date(from: components)
  }

  /// Solar noon date for a given year/month/day and longitude.
  static func solarNoon(
    year: Int,
    month: Int,
    day: Int,
    longitude: Double,
    eqTime: Double
  ) -> Date? {
    let noonMinutes = 720.0 - 4.0 * longitude - eqTime
    let noonHours = noonMinutes / 60.0
    return date(year: year, month: month, day: day, utcHours: noonHours)
  }
}
