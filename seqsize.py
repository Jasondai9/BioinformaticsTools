import sys
import argparse

#killed

min_coverage = 10



def main():
    ##################
    ##### Parser #####
    ##################

    parser = argparse.ArgumentParser()
    parser.add_argument("mpileup_filename", help = "mpileup file")
    
    try:
        args = parser.parse_args()
    except:
        parser.print_help()
        sys.exit(0)



    count = 0
    for position in open(args.mpileup_filename, 'r').readlines():
        if int(position.strip('\n').split('\t')[3]) >= min_coverage:
            count += 1
    
    #mpileup = map(lambda x: if int(x.strip('\n').split('\t')[3]) >= min_coverage: count += 1, open(args.mpileup_filename, 'r').readlines())

    #for position in mpileup:
    #    coverage = int(position[3])
    #    if coverage >= min_coverage:
    #        count += 1
    print(count)

    
        
if __name__ == '__main__':
    main()