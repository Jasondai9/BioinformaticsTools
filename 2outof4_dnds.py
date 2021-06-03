import glob
import os
import argparse
import sys

header_length = 0

def Intersect_Wrapper(vcf1, vcf2, vcf3, vcf4):
    intersect = {}


    intersect = Union(intersect, Intersection(vcf1, vcf2))
    intersect = Union(intersect, Intersection(vcf1, vcf3))
    intersect = Union(intersect, Intersection(vcf1, vcf4))
    intersect = Union(intersect, Intersection(vcf2, vcf3))
    intersect = Union(intersect, Intersection(vcf2, vcf4))
    intersect = Union(intersect, Intersection(vcf3, vcf4))
    
    return intersect


# dic_a should be larger
def Union(dic_a, dic_b):
    for pair in dic_b.items():
        id_string = pair[0]
        dnds_set = pair[1]
        if id_string in dic_a:
            dic_a[id_string].update(dnds_set)
        else:
            dic_a[id_string] = dnds_set
    return dic_a


# gets intersection between two vcfs
def Intersection(dic_a, dic_b):
    if len(dic_a) > len(dic_b):
        return_dic = {}
        for f in dic_b.items():
            if f[0] in dic_a:
                f[1].update(dic_a[f[0]])
                return_dic[f[0]] = f[1]
    else:
        return_dic = {}
        for f in dic_a.items():
            if f[0] in dic_b:
                f[1].update(dic_b[f[0]])
                return_dic[f[0]] = f[1]
    return return_dic


# returns important columns as list by reading from file
# { mutation identifier: entire line as list }
def loadVCF(filename):
    vcf = {}
    global header_length
    for line in open(filename, 'r').readlines()[header_length:]:
        line_list = line.strip('\n').split('\t')
        
        dnds_line = '\t'.join(line_list[:7] + line_list[8:9])
        
        # must pass
        if 'PASS' not in line_list[9]:
            continue
        
        # id_string only includes columns that are not caller-specific
        id_string = ' '.join(line_list[0:1] + line_list[2:4] + line_list[5:7])
        
        # add the line to the vcf dictionary to take advantage of O(1) lookup
        try:
            if id_string not in vcf:
                vcf[id_string] = set()
                
            vcf[id_string].add(dnds_line)
        except:
            print(id_string + ' is a duplicate')
            
    return vcf


def writeVCF(vcf, output_filename):
    with open(output_filename, 'w') as f:
        for line_set_list in list(vcf.values()):
            # include a tab after every item except the last one
            for line_set in line_set_list:
                f.write(line_set + '\n')
            
            
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
    dnds_filename = output + '/' + args.project_name + '_dNdScv_input.txt'
    
    # load vcfs from file
    vcf1 = loadVCF(args.vc1)
    vcf2 = loadVCF(args.vc2)
    vcf3 = loadVCF(args.vc3)
    vcf4 = loadVCF(args.vc4)
    
    # get intersection of every possible combination
    intersect = Intersect_Wrapper(vcf1, vcf2, vcf3, vcf4)
    
    # write merged vcf to file
    writeVCF(intersect, dnds_filename)
    

        
if __name__ == '__main__':
    main()