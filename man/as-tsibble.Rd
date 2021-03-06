% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as-tsibble.R, R/ts2tsibble.R
\name{as_tsibble}
\alias{as_tsibble}
\alias{as.tsibble}
\alias{as_tsibble.tbl_df}
\alias{as_tsibble.tbl_ts}
\alias{as_tsibble.data.frame}
\alias{as_tsibble.list}
\alias{as.tsibble}
\alias{as_tsibble.ts}
\alias{as_tsibble.mts}
\alias{as_tsibble.msts}
\alias{as_tsibble.hts}
\title{Coerce to a tsibble object}
\usage{
as_tsibble(x, ...)

\method{as_tsibble}{tbl_df}(x, key = id(), index, regular = TRUE,
  validate = TRUE, ...)

\method{as_tsibble}{tbl_ts}(x, ...)

\method{as_tsibble}{data.frame}(x, key = id(), index, regular = TRUE,
  validate = TRUE, ...)

\method{as_tsibble}{list}(x, key = id(), index, regular = TRUE,
  validate = TRUE, ...)

\method{as_tsibble}{ts}(x, tz = "UTC", ...)

\method{as_tsibble}{mts}(x, tz = "UTC", gather = TRUE, ...)

\method{as_tsibble}{msts}(x, tz = "UTC", gather = TRUE, ...)

\method{as_tsibble}{hts}(x, tz = "UTC", ...)
}
\arguments{
\item{x}{Other objects to be coerced to a tsibble (\code{tbl_ts}).}

\item{...}{Other arguments passed on to individual methods.}

\item{key}{Structural variable(s) that define unique time indices, used with
the helper \link{id}. If a univariate time series (without an explicit key),
simply call \code{id()}. See below for details.}

\item{index}{A bare (or unquoted) variable to specify the time index variable.}

\item{regular}{Regular time interval (\code{TRUE}) or irregular (\code{FALSE}). \code{TRUE}
finds the greatest common divisor of positive time distances as the interval.}

\item{validate}{\code{TRUE} suggests to verify that each key or each combination
of key variables lead to unique time indices (i.e. a valid tsibble). It will
also make sure that the nested variables are arranged from lower level to
higher, if nested variables are passed to \code{key}. If you are sure that it's a
valid input, specify \code{FALSE} to skip the checks.}

\item{tz}{Time zone. May be useful when a \code{ts} object is more frequent than
daily.}

\item{gather}{TRUE gives a "long" data form, otherwise as "wide" as \code{x}.}
}
\value{
A tsibble object.
}
\description{
Coerce to a tsibble object
}
\examples{
# coerce tibble to tsibble w/o a key ----
tbl1 <- tibble::tibble(
  date = seq(as.Date("2017-01-01"), as.Date("2017-01-10"), by = 1),
  value = rnorm(10)
)
as_tsibble(tbl1)
# specify the index var
as_tsibble(tbl1, index = date)

# coerce tibble to tsibble with one key ----
# "date" is automatically considered as the index var, and "group" is the key
tbl2 <- tibble::tibble(
  mth = rep(yearmonth(seq(2017, 2017 + 9 / 12, by = 1 / 12)), 3),
  group = rep(c("x", "y", "z"), each = 10),
  value = rnorm(30)
)
as_tsibble(tbl2, key = id(group))
as_tsibble(tbl2, key = id(group), index = mth)

# coerce ts to tsibble
as_tsibble(AirPassengers)
as_tsibble(sunspot.year)
as_tsibble(sunspot.month)
as_tsibble(austres)

# coerce mts to tsibble
z <- ts(matrix(rnorm(300), 100, 3), start = c(1961, 1), frequency = 12)
as_tsibble(z)
as_tsibble(z, gather = FALSE)

# coerce hts from the "hts" package to tsibble
if (!requireNamespace("hts", quietly = TRUE)) {
  stop("Please install the hts package to run these following examples.")
}
as_tsibble(hts::htseg1)
as_tsibble(hts::htseg2)
}
\seealso{
tsibble
}
