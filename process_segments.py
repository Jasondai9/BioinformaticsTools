import sys
import os
import subprocess

#This will generate a new segments file to be used with deTiN

if len(sys.argv) < 4:
	print("\nThis will generate a new segments file to be used with deTiN\n\n")
	print('USAGE: process_segments.py \\\nsegments_file \\\nproject_directory \\\nLogR file\n\n')
	quit()

segmentsFileName = sys.argv[1]
projectDir = sys.argv[2]
logRFilename = sys.argv[3]


#---------------
#---Functions---
#---------------


#finds f for a specified segment
def calculateF(segment):
	if int(segment[4])+int(segment[5]) == 0:
		return float(0)
	return float(int(segment[5]) / (int(segment[4])+int(segment[5])))


#finds tau for a specified segment
def calculateTau(segment, logRValues):
	totalLogR = 0
	count = 0
	chrom = segment[1]
	start = int(segment[2])
	end = int(segment[3])
	for pos, logR in logRValues[chrom]:
		if pos < start:
			continue
		elif pos > end:
			break
		else:
			totalLogR += logR
			count += 1
	
	tau = float(totalLogR / count) + 2
	return tau


#Writes aSCNA to file
def Write_aSCNA(aSCNA, projectDir, sampleName):
	output = open(str(projectDir + "deTiN/" + sampleName + "_aSCNA.txt"), "w")
	
	#header
	output.write("Chromosome\tStart\tEnd\tf\ttau\n")

	for variant in aSCNA:
		output.write(str(variant[0]) + "\t" + str(variant[1]) + "\t" + str(variant[2]) + "\t" + str(variant[3]) + "\t" + str(variant[4]) + "\n")
	output.close()



#---------------
#-----Main------
#---------------

def main():
	#create deTiN dir
	try: 
		os.mkdir(str(projectDir + "deTiN"))
	except OSError as error:
		pass #dir exists


	segmentsFile = open(segmentsFileName, "r").readlines()
	clean_segmentsFile = [f.strip("\n") for f in segmentsFile]

	logRFile = open(logRFilename, "r").readlines()
	clean_logRFile = [f.strip("\n") for f in logRFile]

	#[[sample, chr, startpos, endpos, nMajor, nMinor], [sample2 ... ]]
	segments = [f.split("\t") for f in clean_segmentsFile[1:]]

	#chr: [[pos, logR], [pos2, logR2], ... ]
	logRValues = {}
	for i, line in enumerate(clean_logRFile):
		chrpos = line.split('"')[1]
		chrom = chrpos.split("_")[0]
		pos = int(chrpos.split("_")[1])

		if chrom not in logRValues:
			logRValues[chrom] = []
		logRValues[chrom].append((pos, float(line.split("\t")[1])))


	aSCNA = []
	for i, segment in enumerate(segments):
		aSCNA.extend([segments[i][1:4]])
		aSCNA[i].append(calculateF(segment))
		aSCNA[i].append(calculateTau(segment, logRValues))
	
	sampleName = segments[0][0]
	Write_aSCNA(aSCNA, projectDir, sampleName)


if __name__ == '__main__':
	main()