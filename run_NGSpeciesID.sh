#!/bin/sh

## flags
while getopts i:o:d: flag
do
    case "${flag}" in
        i) fastq_path=${OPTARG};;
        o) outdir=${OPTARG};;
        d) Xylella_blastdb=${OPTARG};;
    esac
done

abs_Xylella_blastdb="$(pwd)/${Xylella_blastdb}"

echo "input path: $fastq_path";
echo "output path: $outdir";
echo "blastdb path: $abs_Xylella_blastdb";

mkdir ${outdir}/NGSpeciesIDout

for fastq in ${fastq_path}/*.fastq; do 
   #prefix
    prefix=$(basename $fastq .fastq)

   #NGSpeceisID
    NGSpeciesID --ont --fastq $fastq --outfolder ${outdir}/NGSpeciesIDout/$prefix --consensus --medaka
done

echo "Generation of consensus sequence cluster completed. Start searching ID against blast database"

cd ${outdir}

for out in NGSpeciesIDout/* ; do
    
    #prefix
    seq=$(basename $out)

    echo "blastn searching $seq against Xylella ComEC amplicons"
    #concatenate all consensus sequences from NGSpeciesID output
    cat ${out}/consensus_reference_*.fasta > ${seq}.consensus.fasta

    #blastn search against the Xylella amplicon sequences
    blastn -db $abs_Xylella_blastdb -query ${seq}.consensus.fasta -out ${seq}.blastout -outfmt 7
done
