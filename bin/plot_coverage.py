#!/usr/bin/env python3
import sys
import matplotlib.pyplot as plt

def read_fai(fai_file):
    contigs = {}
    with open(fai_file) as f:
        for line in f:
            fields = line.strip().split("\t")
            contigs[fields[0]] = int(fields[1])
    return contigs

def read_mpileup(mpileup_file):
    coverage = {}
    with open(mpileup_file) as f:
        for line in f:
            fields = line.strip().split("\t")
            if len(fields) < 4:
                continue
            contig, pos, depth = fields[0], int(fields[1]), int(fields[3])
            coverage.setdefault(contig, {})[pos] = depth
    return coverage

def main():
    if len(sys.argv) != 4:
        sys.stderr.write(f"Uso: {sys.argv[0]} <reads.mpileup> <genome.fasta.fai> <output.pdf>\n")
        sys.exit(1)

    mpileup = sys.argv[1]
    fai = sys.argv[2]
    output_pdf = sys.argv[3]

    contigs = read_fai(fai)
    coverage = read_mpileup(mpileup)

    fig, axes = plt.subplots(len(contigs), 1, figsize=(12, 4*len(contigs)))

    if len(contigs) == 1:
        axes = [axes]

    for ax, (contig, length) in zip(axes, contigs.items()):
        cov = coverage.get(contig, {})
        x = list(range(1, length+1))
        y = [cov.get(pos, 0) for pos in x]

        ax.plot(x, y, lw=0.7, color="steelblue")
        ax.set_title(f"{contig} (len={length})")
        ax.set_xlabel("Posição (bp)")
        ax.set_ylabel("Cobertura")

    plt.tight_layout()
    plt.savefig(output_pdf)

if __name__ == "__main__":
    main()