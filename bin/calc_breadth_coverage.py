#!/usr/bin/env python3
import argparse
from collections import defaultdict
import pandas as pd
import matplotlib.pyplot as plt

def main():
    parser = argparse.ArgumentParser(description="Calculate breadth of coverage from mpileup using fasta.fai")
    parser.add_argument("-i", "--input", required=True, help="Input mpileup file")
    parser.add_argument("-f", "--fai", required=True, help="Reference fasta index file (.fai)")
    parser.add_argument("-o", "--output", default="breadth_coverage.tsv", help="Output TSV file")
    parser.add_argument("-p", "--plot", default="breadth_coverage_plot.png", help="Output plot")
    parser.add_argument("-t", "--threshold", type=float, default=0.1, help="Breadth threshold")
    args = parser.parse_args()

    # Ler tamanhos dos cromossomos do arquivo .fai
    chrom_sizes = {}
    with open(args.fai) as f:
        for line in f:
            cols = line.strip().split('\t')
            chrom, length = cols[0], int(cols[1])
            chrom_sizes[chrom] = length

    # Ler mpileup e calcular bases cobertas
    coverage = defaultdict(set)
    with open(args.input) as f:
        for line in f:
            cols = line.strip().split('\t')
            if len(cols) < 4:
                continue
            chrom, pos, _, depth = cols[:4]
            try:
                if int(depth) > 0:
                    coverage[chrom].add(int(pos))
            except ValueError:
                continue

    # Calcular breadth
    summary = []
    with open(args.output, 'w') as out:
        out.write('Chromosome\tCovered_bases\tTotal_bases\tBreadth\n')
        for chrom, covered_positions in coverage.items():
            total = chrom_sizes.get(chrom)
            if total is None:
                continue  # chrom não encontrado no .fai
            covered = len(covered_positions)
            breadth = covered / total if total > 0 else 0
            if breadth >= args.threshold:
                out.write(f'{chrom}\t{covered}\t{total}\t{breadth:.4f}\n')
                summary.append((chrom, breadth))

    # Gerar plot
    if summary:
        df = pd.DataFrame(summary, columns=['Chromosome', 'Breadth'])
        df.sort_values('Breadth', ascending=False).plot(
            x='Chromosome', y='Breadth', kind='bar', figsize=(10,5), legend=False
        )
        plt.ylabel('Breadth of Coverage')
        plt.title('Coverage Breadth per Virus')
        plt.tight_layout()
        plt.savefig(args.plot)

if __name__ == "__main__":
    main()