# This script is used to generate specific codon mutations in a sequence
# Currently exames at a codon level, but this can be adjusted.
# Change values in for-loop to switch the type of mutation.

mutantSeq = []
f = open('mutantSeq.txt', 'w')

with open('seq.txt') as input:
	seq=input.read()
	codon_list=map(''.join, zip(*[iter(seq)]*3))

	for codon in codon_list:
		if codon == 'atg':
			mutantSeq.append('aug')
		else:
			mutantSeq.append(codon)

	print(''.join(mutantSeq), file=f)
