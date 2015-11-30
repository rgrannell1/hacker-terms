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





'
Usage:
	plot-term-usage.R [--] -

Options:

' -> doc





tryParseNumber <- number := {

	tryCatch({
		as.numeric(number)
	},
	error = xK(number))

}





readRecordFormat = (buffer : line) := {

	tokens  <- xExplode('[ ]+', line)
	keyPath <- xExplode('[.]', xFirstOf(tokens))
	val     <- xSecondOf(tokens)

	# -- add step to update buffer.

	if (xLenOf(keyPath) == 1) {

		buffer[[keyPath]] <- tryParseNumber(val)

	} else if (xLenOf(keyPath) == 2) {

		buffer[[ xFirstOf(keyPath) ]][[ xSecondOf(keyPath) ]] <- tryParseNumber(val)

	}

	print(buffer)

}





foldStdin <- (onLine : acc) := {

	conn <- file('stdin')
	open(conn, blocking = True)

	while(length( line <- readLines(conn, n = 1) ) > 0) {
		acc <- onLine(acc, line)
	}

	acc

}





main <- args := {

	data <- foldStdin((acc : line) := {


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