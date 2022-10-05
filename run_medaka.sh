#!/bin/sh

## flags
while getopts i:o:r:d: flag
do
    case "${flag}" in
        i) fastq_path=${OPTARG};;
        o) outdir=${OPTARG};;
        r) ref=${OPTARG};;
        d) Xylella_blastdb=${OPTARG};;
    esac
done

abs_ref="$(pwd)/${ref}"
abs_Xylella_blastdb="$(pwd)/${Xylella_blastdb}"

echo "input path: $fastq_path";
echo "output path: $outdir";
echo "reference sequence path = $abs_ref";
echo "blastdb path: $abs_Xylella_blastdb";

mkdir ${outdir}/medakaout

for fastq in ${fastq_path}/*.fastq; do 
   #prefix
    prefix=$(basename $fastq .fastq)

   #medaka
    medaka_consensus -i $fastq -d $abs_ref -o ${outdir}/medakaout/${prefix} -m r941_min_high_g303
done

echo "Generation of consensus sequence cluster completed. Start searching ID against blast database"

cd ${outdir}

for out in medakaout/* ; do
    
    #prefix
    seq=$(basename $out)

    echo "blastn searching $seq against Xylella ComEC amplicons"
    #rename consensus sequences
    cp ${out}/consensus.fasta ${seq}.consensus.fasta

    #blastn search against the Xylella amplicon sequences
    blastn -db $abs_Xylella_blastdb -query ${seq}.consensus.fasta -out ${seq}.blastout -outfmt 7
done
