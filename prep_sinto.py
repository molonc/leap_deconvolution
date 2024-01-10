import click
import yaml

def extract_cell_ids(metadata_file):
    """
    Extracts cell_ids from the given metadata file.
    
    Args:
    metadata_file (str): Path to the YAML metadata file.

    Returns:
    list: A list of cell_ids.
    """
    with open(metadata_file, 'r') as file:
        metadata = yaml.safe_load(file)

    # Extract cell_ids assuming they are under 'meta' -> 'cell_ids'
    if 'meta' in metadata and isinstance(metadata['meta'], dict) and 'cell_ids' in metadata['meta']:
        cell_ids = metadata['meta']['cell_ids']
        if isinstance(cell_ids, list):
            # Remove duplicates and sort the list
            return sorted(set(cell_ids))
    
    return []

def create_output_file(cell_ids, output_file):
    """
    Creates a CSV file with two columns of cell_ids.

    Args:
    cell_ids (list): List of cell_ids.
    output_file (str): Path for the output CSV file.
    """
    with open(output_file, 'w') as file:
        for cell_id in cell_ids:
            file.write(f"{cell_id}\t{cell_id}\n")

@click.command()
@click.argument('metadata_file', type=click.Path(exists=True))
@click.argument('output_file', type=click.Path())
def main(metadata_file, output_file):
    """
    Processes a YAML metadata file to extract cell_ids and creates an output CSV file.

    Args:
    metadata_file (str): Path to the YAML metadata file.
    output_file (str): Path for the output CSV file.
    """
    cell_ids = extract_cell_ids(metadata_file)
    create_output_file(cell_ids, output_file)
    click.echo(f"Output file created at {output_file}")

if __name__ == "__main__":
    main()
