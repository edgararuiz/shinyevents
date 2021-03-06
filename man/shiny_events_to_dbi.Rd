% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shiny_events.R
\name{shiny_events_to_dbi}
\alias{shiny_events_to_dbi}
\title{Record Shiny events on a database}
\usage{
shiny_events_to_dbi(app = basename(getwd()), table = "shinyevents",
  connection = NULL)
}
\arguments{
\item{app}{The name of the app. Defaults to the name of the script's containing folder.}

\item{table}{The name of the database table to use. Defautls to "shinyevents". If the table does not exist,
it will created. If it does exist, it will expect the fields to be: `guid`, `app`, `datetime`, `activity`, `value`}

\item{connection}{The name of the database connection}
}
\value{
An environment variable containing: a GUID, the name of the app, entry() function and event() function.
}
\description{
Uses the `DBI` package to record events.  Here are a couple of highlights of how it works:
uses the `dbWriteTable()` function, this allows it to work on most databases `DBI` is
able to interact with, and the `append = TRUE` argument is used.  This allows the table to
be created if it doesn't exists yet, and only to add new records to the table, instead of overriding
its content
}
