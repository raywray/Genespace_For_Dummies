###############################################
# -- Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 4) {
  stop("Usage: Rscript run_genespace.R <genomeRepo> <workingDirectory> <path2mcscanx> <genome2run>\n",
       "  genomeRepo: path to store raw genomes\n",
       "  workingDirectory: path to genespace working directory\n",
       "  path2mcscanx: path to MCScanX installation\n",
       "  genome2run: comma-separated list of genome directories to run\n",)
}

genomeRepo <- args[1]
wd <- args[2]
path2mcscanx <- args[3]
genome2run <- unlist(strsplit(args[4], ","))
###############################################

library(GENESPACE)

# PARSE ANNOTATIONS
parsedPaths<- parse_annotations(
  rawGenomeRepo = genomeRepo,
  genomeDirs = genome2run,
  genomeIDs = genome2run,
  presets = "ncbi",
  genespaceWd = wd)
