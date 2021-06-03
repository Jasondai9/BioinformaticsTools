import glob
import os
import argparse
import sys

header_length = 0
hm_mutations = set(['transcript_ablation', 'splice_acceptor_variant', 'splice_donor_variant', 'stop_gained', 'frameshift_variant', 'stop_lost', 'start_lost', 'transcript_amplification', 'inframe_insertion', 'inframe_deletion', 'missense_variant', 'protein_altering_variant', 'regulatory_region_ablation'])

# get hmm from merged vcf
def HighModerateMutations(vcf_dict):
    global hm_mutations
    hmm_vcf = {}
    hmm_freqs = {}
    for f in vcf_dict.items():
        # get all effects in the ';' seperated list
        effect_list = f[1][8].split(';')
        for effect in effect_list:
            if effect in hm_mutations:
                # add to hmm vcf if its a hmm
                hmm_vcf[f[0]] = f[1]
                
                # add to freqs
                samplename = f[1][0]
                gene = f[1][1]
                
                # create an empty set for unique samples 
                if gene not in hmm_freqs:
                    hmm_freqs[gene] = set()        
                    
                # add to the hmmfreqs set
                hmm_freqs[gene].add(samplename)
        
    # count up all the samplenames for each gene
    #freq_counts = {f[0]: len(f[1]) for f in hmm_freqs.items()}
    sorted_freqs = {k: v for k, v in sorted({f[0]: len(f[1]) for f in hmm_freqs.items()}.items(), key=lambda item: item[1], reverse=True)}
    
    return hmm_vcf, sorted_freqs


# gets intersection between two vcfs
def Intersection(dic_a, dic_b):
    intersect_dict = {}
    if len(dic_a) > len(dic_b):
        for f in dic_b.items():
            if f[0] in dic_a:
                # if dic_b has an intergenic variant, use the annotation from dic_a
                if "intergenic_variant" in f[1]:
                    intersect_dict[f[0]] = dic_a[f[0]]
                else:
                    # else just use dic_b's annotations
                    intersect_dict[f[0]] = f[1]
        #return {f[0]: f[1] for f in dic_b.items() if f[0] in dic_a}
    else:
        for f in dic_a.items():
            if f[0] in dic_b:
                # if dic_a has an intergenic variant, use the annotation from dic_b
                if "intergenic_variant" in f[1]:
                    intersect_dict[f[0]] = dic_b[f[0]]
                else:
                    # else just use dic_a's annotations
                    intersect_dict[f[0]] = f[1]
        #return {f[0]: f[1] for f in dic_a.items() if f[0] in dic_b}
    return intersect_dict


# dic_a should be larger
def Union(dic_a, dic_b):
    for pair in dic_b.items():
        id_string = pair[0]
        line_list = pair[1]
        
        # if this mutation is already in the dictionary
        if id_string in dic_a:
            # only if the new variant isnt an integenic variant, update the dictionary
            if 'intergenic_variant' not in line_list:
                dic_a[id_string] = line_list
        # if this is a new mutation, update the dictionary
        else:
            dic_a[id_string] = line_list
    return dic_a


# returns important columns as list by reading from file
# { mutation identifier: entire line as list }
def loadVCF(filename):
    vcf = {}
    global header_length
    for line in open(filename, 'r').readlines()[header_length:]:
        line_list = line.strip('\n').split('\t')
        
        # must pass
        if 'PASS' not in line_list[9]:
            continue
        
        # must be an snv, not an indel
#        if len(line_list[5]) > 1 or len(line_list[6]) > 1 or ('-' in line_list[6]) or ('-' in line_list[5]):
#            continue
        
        # id_string only includes columns that are not caller-specific
        id_string = ' '.join(line_list[0:1] + line_list[2:4] + line_list[5:7])
        
        # add the line to the vcf dictionary to take advantage of O(1) lookup
        try:
            vcf[id_string] = line_list
        except:
            print(id_string + ' is a duplicate')
            
    return vcf


def writeVCF(vcf, output_filename):
    with open(output_filename, 'w') as f:
        for line_list in list(vcf.values()):
            # include a tab after every item except the last one
            for value in line_list[:-1]:
                f.write(value + '\t')
            # write last item and append a newline
            f.write(line_list[-1] + '\n')

def writeVCF_dnds(vcf, output_filename, tissue):
    with open(output_filename, 'w') as f:
        for line_list in list(vcf.values()):
            f.write(line_list[0] + '\t' + line_list[2] + '\t' + line_list[3] + '\t' + line_list[5] + '\t' + line_list[6] + '\t' + tissue + '\t' + line_list[1] + '\t' + line_list[8] + '\n')

            
            
def writeHmmFreqs(freqs_dict, filename):
    with open(filename, 'w') as f:
        for gene, freq in freqs_dict.items():
            f.write(gene + '\t' + str(freq) + '\n')


def main():
    ##################
    ##### Parser #####
    ##################

    parser = argparse.ArgumentParser()
    parser.add_argument("output_directory", help = "Directory to output 2 out of 4 vcf file")
    parser.add_argument("project_name", help = "the name of the cancer/precancer")
    parser.add_argument("vc1", help = "vcf file for variant caller")
    parser.add_argument("vc2", help = "vcf file for variant caller")
    parser.add_argument("vc3", help = "vcf file for variant caller")
    parser.add_argument("vc4", help = "vcf file for variant caller")
    parser.add_argument("header_length", help = "do the input vcfs have headers")

    try:
        args = parser.parse_args()
    except:
        parser.print_help()
        sys.exit(1)

    # set header length from input
    global header_length
    header_length = int(args.header_length)


    # make output directory
    output = args.output_directory
    try:
        os.makedirs(output)
    except:
        pass # directory exists    
    
    # create filename
    merged_filename = output + '/' + args.project_name + '_merged_snv.txt'
    hmm_info_filename = output + '/' + args.project_name + '_Hmmutation_info.txt'
    hmm_freq_filename = output + '/' + args.project_name + '_Hmmutation_freq.txt'
    dnds_filename = output + '/' + args.project_name + '_dNdScv_input.txt'
    
    # load vcfs from file
    vcf1 = loadVCF(args.vc1)
    vcf2 = loadVCF(args.vc2)
    vcf3 = loadVCF(args.vc3)
    vcf4 = loadVCF(args.vc4)
    
    # get intersection of every possible combination
    intersect = {}

    intersect = Union(intersect, Intersection(vcf1, vcf2))
    intersect = Union(intersect, Intersection(vcf1, vcf3))
    intersect = Union(intersect, Intersection(vcf1, vcf4))
    intersect = Union(intersect, Intersection(vcf2, vcf3))
    intersect = Union(intersect, Intersection(vcf2, vcf4))
    intersect = Union(intersect, Intersection(vcf3, vcf4))
    
    # write merged vcf to file
    writeVCF(intersect, merged_filename)
    
    # write dnds file with tissue
    writeVCF_dnds(intersect, dnds_filename, args.project_name)
    
    # get hmm's
    hmm_info, hmm_freqs = HighModerateMutations(intersect)
    
    # write hmm_info to file
    writeVCF(hmm_info, hmm_info_filename)
    
    # write hmm_freqs to file
    writeHmmFreqs(hmm_freqs, hmm_freq_filename)

        
if __name__ == '__main__':
    main()