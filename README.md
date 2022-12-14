# Xylella_pcrONT

**Last update on 5 October 2022**

A quick tutorial for *Xylella* species/subspecies identification from *Xylella*-ComEC PCR + Nanopore sequencing workflow. Three methods are summarised here:
- A. ***De novo* sequence cluster method**
- B. **Reference-guided consensus method**
- C. **Alignment and variant calling method**

## Requirement and Dependency
This workflow has been tested to work on Linux environment with conda installed and it is dependent on the following tools:
1. [BLAST+](https://www.ncbi.nlm.nih.gov/books/NBK279690/)
2. [medaka](https://github.com/nanoporetech/medaka)
3. [NGSpeciesID](https://github.com/ksahlin/NGSpeciesID)

**Installation with conda**
NGSpeicesID and the latest version of medaka are not compatible due to variation in dependency. Therefore, separate conda environments should be created for running NGSpeicesID and medaka

1. Creating NGSpecies environment
```
conda create -n NGSpeciesID python=3.6 pip 
conda activate NGSpeciesID
conda install --yes -c conda-forge -c bioconda medaka==0.11.5 openblas==0.3.3 spoa racon minimap2 blast
pip install NGSpeciesID
```

2. Creating medaka environment
```
conda create -n medaka -c conda-forge -c bioconda medaka blast
```

3. Clone this into your working directory
```
git clone https://github.com/chewbeckie/Xylella_pcrONT
```

## ComEC amplicon database
The `Xylella_ComEC_PCR_amplicons.fasta` file contains different amplicon sequences identified from a collection of *Xylella* genomes in the public genome database on ncbi.

![alignment of Xylella ComEC PCR amplicons](./ComEC-ampliconalignment_genomes129.svg)
**Figure 1:** Alignment of *Xylella* ComEC PCR amplicons extracted from 129 *Xylella* genomes in ncbi genome database (as of 24 August 2022)

Unique sequences are collaged into the `Xylella_ComEC_PCR_amplicons.fasta` file in `database`

To run customised blast search for *Xylella* species/subspecies identification, a blast database has to be set up using the `Xylella_ComEC_PCR_amplicons.fasta` file:

```
makeblastdb -in Xylella_ComEC_PCR_amplicons.fasta -dbtype nucl -out Xylella_ComEC_PCR_amplicons.db
```

By running the above command line, a blastdb namely `Xylella_ComEC_PCR_amplicons.db` will be set up locally in the working directory.

## Input file

Unziped, basecalled, demultiplexed raw read files from Nanopore sequencing run in `fastq` format are required as input. All `fastq` files should be placed in a single directory as an input. Please see the example input directory in `test_files/test_input`.

## *De novo* sequence cluster method

To use this method, the NGSpeciesID environment has to be activated first.
```
conda activate NGSpeciesID
```

### Step-by-step instruction
1. Run [NGSpeciesID](https://github.com/ksahlin/NGSpeciesID) on the raw reads to generate one or more consensus sequences based on similarity.

Here's an example using a test raw read fastq file in `test_files/test_input`
```
NGSpeciesID --ont --fastq ComEC-pcr-CFBP8072.fastq --outfolder test_files/test_output --consensus --medaka
```

2. The NGSpeciesID will generate distinct consensus sequences named as `consensus_reference_0.fasta`, `consensus_reference_1.fasta`, etc. These sequences can be concatenated by running the following command
```
cat consensus_reference_*.fasta > consensus.fasta
```

3. These consensus sequences can be searched with `blastn` against the ComEC amplicon database. (*Before running this script, the blastdb for the ComEC amplicon database has to be set up first. See instruction above*)
```
blastn -db Xylella_ComEC_PCR_amplicons.db -query consensus.fasta -out consensus.blastout -outfmt 7
```
This will generate a blast report listed the matching sequence from the closest match to the least.


### Automated script for batch processing
The script `run_NGSpeciesID.sh` automate the above process.
Here's the command to run this script against the test dataset in `test_files/test_input` to generate sample output data in `test_consensus_output`.

**Before running this command, please change the /path/to/Xylella_ComEC_PCR_amplicons.fasta.blastdb to the path of your blast database**

```
#first create a output directory
mkdir test_files/test_consensus_output

#then run script
bash run_NGSpeciesID.sh  -i test_files/test_input -o test_files/test_NGSpeciesID_output -d /path/to/Xylella_ComEC_PCR_amplicons.fasta.blastdb
```

The following parameters have to be set to run this script
- `-i` flag the path to the directory containing the input fastq files
- `-o` flag the path you wish to save the output files at
- `-d` flag the path to the blastdb for the ComEC amplicon database

## Reference-guided consensus method

To use this method, the medaka environment has to be activated first.
```
conda activate medaka
```

### Step-by-step instruction
1. Run `medaka_consensus` and use one of the amplicon sequences as a reference. Here's an example using the `Xylella_fastidiosa_fastidiosa-ComEC_pcr_amplicon.fasta` as a reference.
```
medaka_consensus -i ComEC-pcr-CFBP8072.fastq \
                 -d database/separate_seqs/Xylella_fastidiosa_fastidiosa-ComEC_pcr_amplicon.fasta \
                 -o medaka_output-CFBP8072 \
                 -m r941_min_high_g303
```
You can find the consensus sequence under the output directory `medaka_output-CFBP8072`

2. Then using the consensus sequence generated, search the sequence using `blastn` against the ComEC amplicon database. (*Before running this script, the blastdb for the ComEC amplicon database has to be set up first. See instruction above*)
```
blastn -db Xylella_ComEC_PCR_amplicons.db -query medaka_output-CFBP8072/consensus.fasta -out consensus.blastout -outfmt 7
```
This will generate a blast report listed the matching sequence from the closest match to the least.


## Alignment and variant calling method

Alternatively, variant calling can be done individually using amplicon sequences listed in `database/separate_seqs` as references individually. For example, sample output in `test_vcall_output` is generated by testing the `ComEC-pcr-CFBP8072.fastq` test data against the *Xff* amplicon as reference. To do so, the following command line was used:
```
medaka_haploid_variant -i ComEC-pcr-CFBP8072.fastq -r database/separate_seqs/Xylella_fastidiosa_fastidiosa-ComEC_pcr_amplicon.fasta -o test_files/test_vcall_output
```
