#!/usr/bin/env Rscript





if (!require(devtools)) {
	install.packages(devtools)
}

if (!require(ggplot2)) {
	install.packages(ggplot2)
}

if (!require(docopt)) {
	library(devtools)
	install_github("docopt/docopt.R")
}

if (!require(reshape2)) {
	install.packages(reshape2)
}

if (!require(scales)) {
	install.packages(scales)
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

	# -- this is unpleasant.

	if (xLenOf(keyPath) == 1) {

		buffer[[keyPath]] <- tryParseNumber(val)

	} else if (xLenOf(keyPath) == 2) {

		buffer[[ xFirstOf(keyPath) ]][[ xSecondOf(keyPath) ]] <- tryParseNumber(val)

	}

	buffer

}





foldStdin <- (onLine : acc) := {

	conn <- file('stdin')
	open(conn, blocking = True)

	while(length( line <- readLines(conn, n = 1) ) > 0) {
		acc <- onLine(acc, line)
	}

	close(conn)
	acc

}




writePlot <- gg := {

	# -- because R plots doesn't seem to support stdout (ffs).

	file <- tempfile('ptu-')

	png(file)
		plot(gg)
	dev.off( )

	system(paste0('cat ', file))

}





plotFrequency <- (args : data) := {

	aggregate <- x_(data)  $
		xMap(group := {

			c(
				group $ termAverages,
				timeLabel    = group $ timeLabel,
				observations = group $ observations
			)

		}) $
		x_Apply(rbind)

	melted <- melt(
		as.data.frame(aggregate, stringsAsFactors = False),
		id.vars = c('timeLabel', 'observations')
	)

	gg <- ggplot(melted) +
		geom_line( aes(x = timeLabel, y = value, color = variable) ) +

		scale_x_continuous(labels = point := {
			floor(point)
		}) +
		scale_y_continuous(labels = percent) +

		xlab('') +
		ylab('term frequency') +

		ggtitle('HN term usage over time.')

	writePlot(gg)

}





parseLines <- (acc : line) := {

	if (xIsMatch('^[ 	]*$', line)) {

		list(
			buffer = list( ),
			data   = xJoin_(acc $ data, list(acc $ buffer))
		)

	} else {

		list(
			buffer = readRecordFormat(acc $ buffer, line),
			data   = acc $ data
		)

	}

}





main <- args := {

	data <- foldStdin(parseLines, list(
		buffer = list( ),
		data   = list( )
	)) $ data

	plotFrequency(args, xSelect(row := {
		xLenOf(row) > 0
	}, data))

}





main(args)