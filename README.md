# Xylella_pcrONT

**Last update on 24 August 2022**

A quick script for *Xylella* species/subspecies identification from *Xylella*-ComEC PCR + Nanopore sequencing workflow.

## Requirement and Dependency
This workflow has been tested to work on Linux environment with conda installed and it is dependent on the following tools:
1. [BLAST+](https://www.ncbi.nlm.nih.gov/books/NBK279690/)
2. [medaka](https://github.com/nanoporetech/medaka)
3. [NGSpeciesID](https://github.com/ksahlin/NGSpeciesID)

**Installation with conda**
1. Create and activate conda environment
```
conda create -n Xylella_pcrONT python=3.6 pip
conda activate Xylella_pcrONT
```

2. Install required packages
```
conda install -c bioconda -c conda-forge medaka openblas==0.3.3 spoa racon minimap2 blast
```

3. Clone this into your working directory
```
git clone https://github.com/chewbeckie/Xylella_pcrONT
```

## ComEC amplicon database
The `Xylella_ComEC_PCR_amplicons.fasta` file contains different amplicon sequences identified from a collection of *Xylella* genomes in the public genome database on ncbi.

**Total number of ComEC PCR amplicon variants (*As of 24 August 2022*)**
|Species | subspecies | Number of amplicon variant | 
|--------|------------|----------------------------|
|*Xylella fastidiosa*| *fastidiosa* or *morus* | 1 |
|*Xylella fastidiosa*| *pauca* | 4 |
|*Xylella fastidiosa*| *sandyi* | 1 |
|*Xylella fastidiosa*| *multiplex* | 2 |
|*Xylella taiwanensis*| - | 1 |

Unique sequences are collaged into the `Xylella_ComEC_PCR_amplicons.fasta` file in `database`

To run customised blast search for *Xylella* species/subspecies identification, a blast database has to be set up using the `Xylella_ComEC_PCR_amplicons.fasta` file:

```
makeblastdb -in Xylella_ComEC_PCR_amplicons.fasta -dbtype nucl -out Xylella_ComEC_PCR_amplicons.db
```

By running the above command line, a blastdb namely `Xylella_ComEC_PCR_amplicons.db` will be set up locally in the working directory.

## Input file

Unziped, basecalled, demultiplexed raw read files from Nanopore run in `fastq` format are required as input. All `fastq` files should be placed in a single directory as an input. Please see the example input directory in `test_files/test_input`.

## Reference-free consensus sequence cluster method

### Step-by-step instruction
1. Run [NGSpeciesID](https://github.com/ksahlin/NGSpeciesID) on the raw reads to generate one or more consensus sequences based on similarity, and polish the consensus sequences using `medaka`

Here's an example using the test raw read fastq files in `test_files/test_input`
```
NGSpeciesID --ont --fastq test_files/test_input --outfolder test_files/test_output --consensus --medaka
```

2. The NGSpeciesID will generate distinct consensus sequences named as `consensus_reference_0.fasta`, `consensus_reference_1.fasta`, etc. These sequences can be concatenated by running the following command
```
cat consensus_reference_*.fasta > consensus.fasta
```

3. These consensus sequences can be searched with `blastn` against the ComEC amplicon database. (*Before running this script, the blastdb for the ComEC amplicon database has to be set up first see instruction above*)
```
blastn -db Xylella_ComEC_PCR_amplicons.db -query consensus.fasta -out consensus.blastout -outfmt 7
```
This will generate a blast report listed the matching sequence from the closest match to the least.


### Automated script for batch processing
The script `run_pcrONT.sh` automate the above process.
Here's the command to run this script against the test dataset
```
bash run_pcrONT.sh -i test_files/test_input -o test_files/test_output -d /path/to/Xylella_ComEC_PCR_amplicons.fasta.blastdb
```

- `-i` flag the input path location with the fastq files
- `-o` flag the output path
- `-d` flag the path to the blastdb for the ComEC amplicon database

