###############################################
# -- Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 4) {
  stop("Usage: Rscript run_genespace.R <genomeRepo> <workingDirectory> <path2mcscanx> <gpar>\n",
       "  genomeRepo: path to store raw genomes\n",
       "  workingDirectory: path to genespace working directory\n",
       "  path2mcscanx: path to MCScanX installation\n",
       "  gpar_path: path to gpar.rds file")
}

genomeRepo <- args[1]
wd <- args[2]
path2mcscanx <- args[3]
gpar_path <- args[4]
###############################################

library(GENESPACE)

# -- load the gpar object
gpar <- readRDS(gpar_path)

# -- accomplish the run
out <- run_genespace(gpar)
saveRDS(out, file.path(wd, "rds", "genespace_out.rds"))