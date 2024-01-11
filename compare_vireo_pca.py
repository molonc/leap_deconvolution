import pandas as pd
import matplotlib.pyplot as plt
import click


#@click.argument('figure_output_path', type=click.File('wb'))
#cluster_df = "/projects/molonc/scratch/sbeatty/SCY-289/mondrian_output/sequencingrun_SLX23704/results/output/cluster_assignment.csv"
#donor_df = "/projects/molonc/scratch/sbeatty/SCY-289/mondrian_output/sequencingrun_SLX23704/results/output/vireo/donor_ids.tsv"
#figure_output_path = "/projects/molonc/scratch/sbeatty/SCY-289/mondrian_output/sequencingrun_SLX23704/results/output/check_sequencing_run_count.png"

@click.command()
@click.argument('cluster_file', nargs=1)
@click.argument('donor_file', nargs=1)
@click.argument('figure_output_path', nargs=1)
def main(cluster_file, donor_file, figure_output_path):
    cluster_df = str(cluster_file)
    donor_file = str(donor_file)
    cluster_df = pd.read_csv(cluster_df)
    print("file read in")
    print(cluster_df)
    donor_df = pd.read_csv(donor_file, sep="\t")
    print("donor read in")
    print(donor_file)
    figure_output_path = str(figure_output_path)
    #cluster_df = pd.read_csv("/projects/molonc/scratch/sbeatty/SCY-289/mondrian_output/sequencingrun_SLX23704/results/output/cluster_assignment.csv")
    #donor_df = pd.read_csv("/projects/molonc/scratch/sbeatty/SCY-289/mondrian_output/sequencingrun_SLX23704/results/output/vireo/donor_ids.tsv",sep='\t')
    merged_df = pd.merge(cluster_df, donor_df, left_on='cell_id', right_on='cell')

    # generate a csv with best_singlet,cluster_top5,percentage
    grouped_data = merged_df.groupby('best_singlet')['cluster_top5'].value_counts(normalize=True).reset_index(name='percentage')
    grouped_data['percentage'] *= 100 
    grouped_data.to_csv("./SLX23704_check_sequencing_run.csv", index=False)
    print("data_grouped")
    # generate the graph in COUNT
    count_bar_data = pd.pivot_table(merged_df, values='cell_id', index='best_singlet', 
                                    columns='cluster_top5', aggfunc='count')
    count_bar_data.plot(kind='bar')
    plt.xlabel('Best Singlet')
    plt.ylabel('Count')
    plt.title('Count by Best Singlet and Cluster Top 5')
    plt.legend(title='Cluster Top 5')
    #plt.show()
    plt.savefig(figure_output_path)

#cluster_df = pd.read_csv("/projects/molonc/scratch/sbeatty/SCY-288/sequencingrun_SLX23704/results/output/cluster_assignment.csv")
#donor_df = pd.read_csv("/projects/molonc/scratch/sbeatty/SCY-288/sequencingrun_SLX23704/results/output/vireo/donor_ids.tsv",sep='\t')


if __name__ == "__main__":
    main()


__main__