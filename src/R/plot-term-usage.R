#!/usr/bin/env Rscript





if (!require(devtools)) {
	install.packages(devtools)
}

if (!require(docopt)) {
	library(devtools)
	install_github("docopt/docopt.R")
}





library(docopt)




'
Usage:
	plot-term-usage.R [--] -

Options:

' -> doc





foldStdin <- function (callback, acc) {

	conn <- file('stdin')
	open(conn, blocking = TRUE)

	while(length( line <- readLines(conn, n = 1) ) > 0) {
		acc <- callback(acc, line)
	}

	acc

}





main <- function (args) {

	data <- foldStdin(function (acc, line) {

		print(line)

	}, list( ))

}





main(args)