###############################################
# -- Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  stop("Usage: Rscript run_genespace.R <workingDirectory> <path2mcscanx>\n",
       "  workingDirectory: path to genespace working directory\n",
       "  path2mcscanx: path to MCScanX installation")
}

wd <- args[1]
path2mcscanx <- args[2]
###############################################

library(GENESPACE)
genomeIDs <- sub("\\.bed$", "", list.files(file.path(wd, "bed"), pattern = "\\.bed$"))

# Initialize the run and QC the inputs
gpar <- init_genespace(
  genomeIDs = genomeIDs,		       
  wd = wd, 
  path2mcscanx = path2mcscanx)

saveRDS(gpar, file.path(wd, "rds", "gpar.rds"))
