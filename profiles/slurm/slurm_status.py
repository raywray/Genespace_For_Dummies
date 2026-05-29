#!/usr/bin/env python3
"""
Slurm status script for Snakemake
This script checks the status of Slurm jobs and returns appropriate status codes
"""

import sys
import subprocess
import time
import re

def check_job_status(job_id):
    """Check the status of a Slurm job"""
    try:
        # Use sacct to get job status
        cmd = ["sacct", "-j", str(job_id), "--format=State", "--noheader", "--parsable2"]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        
        if result.returncode != 0:
            # Job might not be in sacct yet, try squeue
            cmd = ["squeue", "-j", str(job_id), "--format=%T", "--noheader"]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
            if result.returncode != 0:
                # Job not found, assume it completed
                return "success"
        
        status = result.stdout.strip().split('\n')[0]
        
        # Map Slurm states to Snakemake expectations
        if status in ["COMPLETED"]:
            return "success"
        elif status in ["RUNNING", "PENDING", "CONFIGURING", "RESIZING"]:
            return "running"
        elif status in ["FAILED", "CANCELLED", "TIMEOUT", "NODE_FAIL", "PREEMPTED"]:
            return "failed"
        else:
            # Unknown status, assume running
            return "running"
            
    except subprocess.TimeoutExpired:
        return "running"
    except Exception:
        # If we can't check status, assume success to avoid hanging
        return "success"

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: slurm_status.py <job_id>", file=sys.stderr)
        sys.exit(1)
    
    job_id = sys.argv[1]
    status = check_job_status(job_id)
    print(status)
