#!/usr/bin/env Rscript





if (!require(devtools)) {
	install.packages(devtools)
}

if (!require(docopt)) {
	library(devtools)
	install_github("docopt/docopt.R")
}

if (!require(kea)) {
	library(devtools)
	install_github("rgrannell1/kea")
}





library(docopt)




'
Usage:
	plot-term-usage.R [--] -

Options:

' -> doc




readRecordFormat = function (buffer, line) {

	tokens  <- xExplode('[ ]+', line)
	keyPath <- xExplode('[.]', xFirstOf(tokens))
	val     <- xSecondOf(tokens)

	# -- add step to update buffer.

	buffer

}





foldStdin <- function (onLine, acc) {

	conn <- file('stdin')
	open(conn, blocking = TRUE)

	while(length( line <- readLines(conn, n = 1) ) > 0) {
		acc <- onLine(acc, line)
	}

	acc

}





main <- function (args) {

	data <- foldStdin(function (acc, line) {


		if (xIsMatch('^[ 	]*$', line)) {

			list(
				buffer = list( ),
				data   = xJoin_(acc $ data, acc $ buffer)
			)

		} else {

			list(
				buffer = readRecordFormat(acc $ buffer, line),
				data   = acc $ data
			)

		}

	}, list(
		buffer = list( ),
		data   = list( )
	))

}





main(args)