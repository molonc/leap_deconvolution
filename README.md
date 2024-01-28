# leap_deconvolution


Process

Short version 

## create sinto subdirectory

## prep the sinto metadata file (see below for description

```
python /projects/molonc/scratch/sbeatty/SCY-289/leap_deconvolution/prep_sinto.py ./metadata.yaml sinto_metadata.csv
```

The metadata sheet is just a two column tsv with the cell barcodes repeated in both columns (cell barcode, tab, exactly the same cell barcode). 

SLX23873-SLX23873-R1-C1	SLX23873-SLX23873-R1-C1
SLX23873-SLX23873-R1-C2	SLX23873-SLX23873-R1-C2
SLX23873-SLX23873-R1-C3	SLX23873-SLX23873-R1-C3
SLX23873-SLX23873-R1-C4	SLX23873-SLX23873-R1-C4
SLX23873-SLX23873-R1-C5	SLX23873-SLX23873-R1-C5
SLX23873-SLX23873-R1-C6	SLX23873-SLX23873-R1-C6

## Run Sinto 
```
sinto filterbarcodes -b ../alignment_workflow_all_cells_bulk.bam -c ../sinto_metadata.csv -p 20 
```
## Prepare the snakemake metadata
```
python /projects/molonc/scratch/sbeatty/SCY-289/leap_deconvolution/prep_snakemake_metadata.py ./sinto ./snakemake_metadata.csv
```
## Run snakemake
```
snakemake -s /path/to/snakemake_file/index.snk --cluster "sbatch --mem-per-cpu=15G -c 10 -p upgrade" --jobs 1000 --latency-wait 60
```
