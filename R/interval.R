#' Extract time interval from a vector
#'
#' Assuming regularly spaced time, the `pull_interval()` returns a list of time
#' components as the "interval" class; the `time_unit()` returns the value of
#' time units.
#'
#' @param x A vector of `POSIXt`, `Date`, `yearmonth`, `yearquarter`, `difftime`,
#' `hms`, `integer`, `numeric`.
#'
#' @details The `pull_interval()` and `time_unit()` make a tsibble extensible to
#' support custom time index.
#' @return `pull_interval()`: an "interval" class (a list) includes "year", 
#' "quarter", "month", #' "week", "day", "hour", "minute", "second", "unit", and
#' other self-defined interval.
#'
#' @rdname pull-interval
#' @export
#'
#' @examples
#' x <- seq(as.Date("2017-10-01"), as.Date("2017-10-31"), by = 3)
#' pull_interval(x)
pull_interval <- function(x) {
  UseMethod("pull_interval")
}

#' @export
# Assume date is regularly spaced
pull_interval.POSIXt <- function(x) {
  dttm <- as.numeric(x)
  nhms <- gcd_interval(dttm) # num of seconds
  period <- split_period(nhms)
  structure(
    list(
      hour = period$hour, 
      minute = period$minute, 
      second = round(period$second, digits = 3)
    ),
    class = "interval"
  )
}

#' @export
pull_interval.nanotime <- function(x) {
  nano <- as.numeric(x)
  int <- gcd_interval(nano) # num of nanoseconds
  sec <- int * 1e-9
  structure(list(second = sec), class = "interval")
}

#' @export
pull_interval.difftime <- pull_interval.POSIXt

#' @export
pull_interval.hms <- pull_interval.difftime # for hms package

#' @export
pull_interval.Date <- function(x) {
  dttm <- as.numeric(x)
  ndays <- gcd_interval(dttm) # num of seconds
  structure(list(day = ndays), class = "interval")
}

#' @export
pull_interval.yearweek <- function(x) {
  wk <- units_since(x)
  nweeks <- gcd_interval(wk)
  structure(list(week = nweeks), class = "interval")
}

#' @export
pull_interval.yearmonth <- function(x) {
  mon <- units_since(x)
  nmonths <- gcd_interval(mon)
  structure(list(month = nmonths), class = "interval")
}

#' @export
pull_interval.yearmth <- function(x) {
  pull_interval(yearmonth(x))
}

#' @export
pull_interval.yearquarter <- function(x) {
  qtr <- units_since(x)
  nqtrs <- gcd_interval(qtr)
  structure(list(quarter = nqtrs), class = "interval")
}

#' @export
pull_interval.yearqtr <- function(x) {
  pull_interval(yearquarter(x))
}

#' @export
pull_interval.numeric <- function(x) {
  nunits <- gcd_interval(x)
  if (min0(x) > 1599 && max0(x) < 2500) {
    return(structure(list(year = nunits), class = "interval"))
  }
  structure(list(unit = nunits), class = "interval")
}

#' @export
`[[.interval` <- function(x, i, j, ..., exact = TRUE) {
  NextMethod()
}

#' @export
`[.interval` <- function(x, i, j, drop = FALSE) {
  NextMethod()
}

#' @rdname pull-interval
#' @export
#' @examples
#' # at two months interval ----
#' x <- yearmonth(seq(2016, 2018, by = 0.5))
#' time_unit(x)
time_unit <- function(x) {
  if (has_length(x, 1)) {
    return(0L)
  }
  UseMethod("time_unit")
}

#' @export
time_unit.POSIXt <- function(x) {
  int <- pull_interval(x)
  int$second + int$minute * 60 + int$hour * 60 * 60
}

#' @export
time_unit.numeric <- function(x) {
  int <- pull_interval(x)
  if (min0(x) > 1599 && max0(x) < 2500) {
    return(int$year)
  }
  int$unit
}

#' @export
time_unit.Date <- function(x) {
  pull_interval(x)$day
}

#' @export
time_unit.yearweek <- function(x) {
  pull_interval(x)$week
}

#' @export
time_unit.yearmonth <- function(x) {
  pull_interval(x)$month
}

#' @export
time_unit.yearquarter <- function(x) {
  pull_interval(x)$quarter
}

# from ts time to dates
time_to_date <- function(x, ...) {
  UseMethod("time_to_date")
}

time_to_date.ts <- function(x, tz = "UTC", ...) {
  freq <- stats::frequency(x)
  time_x <- as.numeric(stats::time(x))
  if (freq == 7) { # daily
    start_year <- trunc(time_x[1])
    return(as.Date(lubridate::round_date(
      lubridate::date_decimal(start_year + (time_x - start_year) * 7 / 365),
      unit = "day"
    )))
  } else if (freq == 52) { # weekly
    return(yearweek(lubridate::date_decimal(time_x)))
  } else if (freq > 4 && freq <= 12) { # monthly
    return(yearmonth(time_x))
  } else if (freq > 1 && freq <= 4) { # quarterly
    return(yearquarter(time_x))
  } else if (freq == 1) { # yearly
    return(time_x)
  } else {
    if (stats::end(x)[1] > 999) {
      date_x <- lubridate::date_decimal(time_x, tz = tz)
      return(lubridate::round_date(date_x, unit = "seconds"))
    }
    time_x
  }
}

time_to_date.gts <- function(x, tz = "UTC", ...) {
  time_to_date(x$bts, tz = tz, ...)
}
