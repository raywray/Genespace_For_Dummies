"""
snakemake --configfile configs/tutorial.yaml --profile profiles/slurm --cores 1 -n
"""

configfile: "configs/tutorial.yaml"
mscanx_path = config["mcscanx_path"]
results_dir = config["results_dir"]
raw_genomes = config["raw_genomes"]
genomes2run_ncbi = config["genomes2run_ncbi"]
genomes2run_custom = config.get("genomes2run_custom", [])


ruleorder: parse_annotations_ncbi > parse_annotations_custom 

rule all:
    input:
        expand(results_dir + "/bed/{genome}.bed", genome=genomes2run_ncbi + genomes2run_custom),
        expand(results_dir + "/peptide/{genome}.fa", genome=genomes2run_ncbi + genomes2run_custom),
        results_dir + "/rds/gpar.rds",
        results_dir + "/genespace_run_complete.txt"

rule parse_annotations_ncbi:
    params:
        r_script = "scripts/parse_annotations_ncbi.R",
        raw_genomes = raw_genomes,
        wd = results_dir,
        mscanx_path = mscanx_path,
    wildcard_constraints:
        genome = "|".join(genomes2run_ncbi)
    resources:
        cpus_per_task=1,
        mem_mb=4000,
        runtime=60
    output:
        beds = results_dir + "/bed/{genome}.bed",
        peptides = results_dir + "/peptide/{genome}.fa"
    shell:
        """
        eval "$(/opt/linux/rhel/8.x/x86_64/pkgs/miniconda3/py39_4.12.0/bin/conda shell.bash hook)"
        module load R
        module load orthofinder/2.5.5
        module load MCScanX
        
        Rscript {params.r_script} {params.raw_genomes} {params.wd} {params.mscanx_path} {wildcards.genome}
        """

rule parse_annotations_custom:
    params:
        r_script = "scripts/parse_annotations_custom.R",
        raw_genomes = raw_genomes,
        wd = results_dir,
        mscanx_path = mscanx_path,
    wildcard_constraints:
        genome = "|".join(genomes2run_custom)
    resources:
        cpus_per_task=1,
        mem_mb=4000,
        runtime=60
    output:
        beds = results_dir + "/bed/{genome}.bed",
        peptides = results_dir + "/peptide/{genome}.fa"
    shell:
        """
        eval "$(/opt/linux/rhel/8.x/x86_64/pkgs/miniconda3/py39_4.12.0/bin/conda shell.bash hook)"
        module load R
        module load orthofinder/2.5.5
        module load MCScanX
        
        Rscript {params.r_script} {params.raw_genomes} {params.wd} {params.mscanx_path} {wildcards.genome}
        """

rule initialize_gs_run:
    input:
        expand(results_dir + "/bed/{genome}.bed", genome=genomes2run_ncbi + genomes2run_custom),
        expand(results_dir + "/peptide/{genome}.fa", genome=genomes2run_ncbi + genomes2run_custom)
    params:
        r_script = "scripts/initialize_genespace_run.R",
        wd = results_dir,
        mscanx_path = mscanx_path
    resources:
        cpus_per_task=1,
        mem_mb=4000,
        runtime=60
    output:
        rds = results_dir + "/rds/gpar.rds"
    shell:
        """
        mkdir -p {params.wd}/rds

        eval "$(/opt/linux/rhel/8.x/x86_64/pkgs/miniconda3/py39_4.12.0/bin/conda shell.bash hook)"
        module load R
        module load orthofinder/2.5.5
        module load MCScanX
        
        Rscript {params.r_script} {params.wd} {params.mscanx_path}
        """

rule run_genespace:
    input:
        rds = results_dir + "/rds/gpar.rds"
    params:
        r_script = "scripts/run_genespace.R",
        raw_genomes = raw_genomes,
        wd = results_dir,
        mscanx_path = mscanx_path
    resources:
        cpus_per_task=4,
        mem_mb=32000,
        runtime=2880
    output:
        touch(results_dir + "/genespace_run_complete.txt")
    shell:
        """
        eval "$(/opt/linux/rhel/8.x/x86_64/pkgs/miniconda3/py39_4.12.0/bin/conda shell.bash hook)"
        module load R
        module load orthofinder/2.5.5
        module load MCScanX

        Rscript {params.r_script} {params.raw_genomes} {params.wd} {params.mscanx_path} {input.rds} || exit 1
        touch {output}
        """