# Slurm Profile for ROH Pipeline

This directory contains the Slurm profile configuration for running the ROH (Runs of Homozygosity) pipeline on a Slurm cluster.

## Files

- `config.yaml`: Main Slurm profile configuration
- `slurm_status.py`: Python script for checking job status
- `README.md`: This documentation file

## Usage

### Basic Usage

Run the pipeline with Slurm using the provided script:

```bash
./run_slurm_pipeline.sh
```

### Advanced Usage

You can also run Snakemake directly with the Slurm profile:

```bash
snakemake --profile profiles/slurm --jobs 50
```

### Customizing Resources

The default resource allocations are:
- Memory: 8GB per job
- Runtime: 2 hours per job
- CPUs: 1 per job
- Partition: normal
- Account: armstronglab

To modify these defaults, edit `profiles/slurm/config.yaml`:

```yaml
default-resources:
  - mem_mb=16000  # 16GB memory
  - runtime=240   # 4 hours
  - cpus_per_task=2
  - partition=high_mem
  - account=your_account
```

### Rule-Specific Resources

Some rules have custom resource requirements defined in the rule files. For example:

```python
rule convert_vcf_to_plink:
    # ... inputs and outputs ...
    resources:
        mem_mb=16000,     # 16GB memory
        runtime=180,      # 3 hours
        cpus_per_task=2   # 2 CPUs
```

### Monitoring Jobs

1. **Check job status in real-time:**
   ```bash
   squeue -u $USER
   ```

2. **View job logs:**
   - Standard output: `logs/slurm/{rule}_{wildcards}/{rule}_{wildcards}_{job_id}.out`
   - Standard error: `logs/slurm/{rule}_{wildcards}/{rule}_{wildcards}_{job_id}.err`

3. **Check pipeline statistics:**
   ```bash
   cat logs/pipeline_stats.json
   ```

### Troubleshooting

1. **Jobs failing due to insufficient resources:**
   - Increase memory/runtime in the rule's resources section
   - Check error logs in `logs/slurm/`

2. **Jobs not submitting:**
   - Verify your Slurm account and partition names
   - Check queue limits with `sinfo` and `squeue`

3. **Permission errors:**
   - Ensure all scripts are executable: `chmod +x run_slurm_pipeline.sh`
   - Check file permissions in the working directory

### Configuration Options

Key configuration parameters in `config.yaml`:

- `jobs`: Maximum concurrent jobs (default: 50)
- `latency-wait`: Time to wait for output files (default: 60 seconds)
- `restart-times`: Number of restart attempts for failed jobs (default: 3)
- `max-jobs-per-second`: Rate limiting for job submission (default: 10)

### Dry Run

Test your pipeline configuration without submitting jobs:

```bash
snakemake --profile profiles/slurm --dry-run
```

### Cleaning Up

Remove output files and start fresh:

```bash
snakemake --profile profiles/slurm --delete-all-output
```

## Example Commands

1. **Standard run:**
   ```bash
   ./run_slurm_pipeline.sh
   ```

2. **Dry run to check workflow:**
   ```bash
   snakemake --profile profiles/slurm --dry-run --printshellcmds
   ```

3. **Run with custom job limit:**
   ```bash
   CORES=20 ./run_slurm_pipeline.sh
   ```

4. **Force rerun of specific rule:**
   ```bash
   snakemake --profile profiles/slurm --forcerun run_plink_roh
   ```

5. **Run until specific target:**
   ```bash
   snakemake --profile profiles/slurm data/results/plink/bengals_filtered.hom
   ```

## Resource Optimization Tips

1. **Memory-intensive tools:** Increase `mem_mb` for tools like GARLIC and large VCF processing
2. **CPU-intensive tools:** Set `cpus_per_task` > 1 for tools that can use multiple cores
3. **Long-running jobs:** Increase `runtime` for tools that process large datasets
4. **I/O intensive jobs:** Consider using faster storage partitions if available

## Support

For issues specific to:
- Slurm configuration: Contact your cluster administrator
- Pipeline logic: Check the main Snakefile and rule files
- Tool-specific errors: Refer to individual tool documentation
