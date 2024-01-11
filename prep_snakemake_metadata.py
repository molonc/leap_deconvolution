import pandas as pd
import os
import glob
import os.path
import click

@click.command()
@click.argument('bam_directory', nargs=1)
@click.argument('metadata_outpath', nargs=1)

def main(bam_directory,metadata_outpath):
    if bam_directory[-1] != "/":
        bam_directory = bam_directory + str("/*.bam")
    else:
        bam_directory = bam_directory + str("*.bam")

    bamfiles = pd.Series(glob.glob(bam_directory))
    cell_ids = bamfiles.apply(os.path.basename).str.replace(".bam", "")
    df = {'cell_ids': cell_ids, 'bamfiles': bamfiles}
    metadata_df = pd.DataFrame(df)
    metadata_df.to_csv(metadata_outpath)




if __name__ == "__main__":
    main()