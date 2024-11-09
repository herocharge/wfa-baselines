# WFA baselines

##  1. Get the baseline code
The baseline for CPU and GPU code is taken from the official repositories corresponding to the baselines.
The repositories are: [WFA-lib](https://github.com/smarco/WFA2-lib/) and [WFA-gpu](https://github.com/quim0/WFA-GPU). The WFA-gpu repo also contains the WFA-lib within it, so won't fetch WFA-lib separately.  

Before using the baselines, check if the WFA-gpu submodule is fetched in the `external/` directory.  
If not fetch it using the following command.  
```
$ git submodule update --init --recursive  
```

## 2. Building the dependencies.
```
$ ./build.sh  
```

The above will call perform the build operations corresponding to the baselines. It will also generate `generate_dataset.sh`, `cpu_baseline.sh`, `gpu_baseline.sh`. Usage of these is described below.


##  3. Generate Dataset TOOL

The *generate-dataset* tool allows generating synthetic random datasets for testing and benchmarking purposes. This tool produces a simple output format (i.e., each pair of sequences in 2 lines) containing the pairs of sequences to be aligned using the *align-benchmark* tool. For example, the following command generates a dataset named 'sample.dataset.seq' of 5M pairs of 100 bases with an alignment error of 5% (i.e., 5 mismatches, insertions, or deletions per alignment).

```
$> ./generate_dataset.sh -n 5000000 -l 100 -e 0.05 -o sample.dataset.seq
```

### Command-line Options 

```
        --output|o <File>
          Filename/Path to the output dataset.
          
        --num-patterns|n <Integer>
          Total number of pairs pattern-text to generate.
          
        --length|l <Integer>
          Length of the generated pattern (ie., query or sequence) and text (i.e., target or reference)
          
        --pattern-length|P <Integer>
          Length of the generated pattern (ie., query or sequence)
        
        --text-length|T <Integer>
          Length of the generated text (i.e., target or reference)
          
        --error|e <Float>
          Total error-rate between the pattern and the text (allowing single-base mismatches, 
          insertions and deletions). This parameter may modify the final length of the text.
          
        --debug|g
          Output debug information.
          
        --help|h
          Outputs a succinct manual for the tool.
```

##  4. CPU Benchmark Tool

### Introduction to Alignment Benchmarking

The WFA2-lib includes the benchmarking tool *align-benchmark* to test and compare the performance of various pairwise alignment implementations. This tool takes as input a dataset containing pairs of sequences (i.e., pattern and text) to align. Patterns are preceded by the '>' symbol and texts by the '<' symbol. Example:

```
>ATTGGAAAATAGGATTGGGGTTTGTTTATATTTGGGTTGAGGGATGTCCCACCTTCGTCGTCCTTACGTTTCCGGAAGGGAGTGGTTAGCTCGAAGCCCA
<GATTGGAAAATAGGATGGGGTTTGTTTATATTTGGGTTGAGGGATGTCCCACCTTGTCGTCCTTACGTTTCCGGAAGGGAGTGGTTGCTCGAAGCCCA
>CCGTAGAGTTAGACACTCGACCGTGGTGAATCCGCGACCACCGCTTTGACGGGCGCTCTACGGTATCCCGCGATTTGTGTACGTGAAGCAGTGATTAAAC
<CCTAGAGTTAGACACTCGACCGTGGTGAATCCGCGATCTACCGCTTTGACGGGCGCTCTACGGTATCCCGCGATTTGTGTACGTGAAGCGAGTGATTAAAC
[...]
```

Once you have the dataset ready, you can run the *align-benchmark* tool to benchmark the performance of a specific pairwise alignment method. For example, the WFA algorithm:

```
$> ./align_benchmark.sh -i sample.dataset.seq -a gap-affine-wfa
...processed 10000 reads (benchmark=125804.398 reads/s;alignment=188049.469 reads/s)
...processed 20000 reads (benchmark=117722.406 reads/s;alignment=180925.031 reads/s)
[...]
...processed 5000000 reads (benchmark=113844.039 reads/s;alignment=177325.281 reads/s)
[Benchmark]
=> Total.reads            5000000
=> Time.Benchmark        43.92 s  (    1   call,  43.92  s/call {min43.92s,Max43.92s})
  => Time.Alignment      28.20 s  ( 64.20 %) (    5 Mcalls,   5.64 us/call {min438ns,Max47.05ms})
```

The *align-benchmark* tool will finish and report overall benchmark time (including reading the input, setup, checking, etc.) and the time taken by the algorithm (i.e., *Time.Alignment*). If you want to measure the accuracy of the alignment method, you can add the option `--check` and all the alignments will be verified. 

```
$> ./align_benchmark.sh -i sample.dataset.seq -a gap-affine-wfa --check
...processed 10000 reads (benchmark=14596.232 reads/s;alignment=201373.984 reads/s)
...processed 20000 reads (benchmark=13807.268 reads/s;alignment=194224.922 reads/s)
[...]
...processed 5000000 reads (benchmark=10625.568 reads/s;alignment=131371.703 reads/s)
[Benchmark]
=> Total.reads            5000000
=> Time.Benchmark         7.84 m  (    1   call, 470.56  s/call {min470.56s,Max470.56s})
  => Time.Alignment      28.06 s  (  5.9 %) (    5 Mcalls,   5.61 us/call {min424ns,Max73.61ms})
[Accuracy]
 => Alignments.Correct        5.00 Malg        (100.00 %) (samples=5M{mean1.00,min1.00,Max1.00,Var0.00,StdDev0.00)}
 => Score.Correct             5.00 Malg        (100.00 %) (samples=5M{mean1.00,min1.00,Max1.00,Var0.00,StdDev0.00)}
   => Score.Total           147.01 Mscore uds.            (samples=5M{mean29.40,min0.00,Max40.00,Var37.00,StdDev6.00)}
     => Score.Diff            0.00 score uds.  (  0.00 %) (samples=0,--n/a--)}
 => CIGAR.Correct             0.00 alg         (  0.00 %) (samples=0,--n/a--)}
   => CIGAR.Matches         484.76 Mbases      ( 96.95 %) (samples=484M{mean1.00,min1.00,Max1.00,Var0.00,StdDev0.00)}
   => CIGAR.Mismatches        7.77 Mbases      (  1.55 %) (samples=7M{mean1.00,min1.00,Max1.00,Var0.00,StdDev0.00)}
   => CIGAR.Insertions        7.47 Mbases      (  1.49 %) (samples=7M{mean1.00,min1.00,Max1.00,Var0.00,StdDev0.00)}
   => CIGAR.Deletions         7.47 Mbases      (  1.49 %) (samples=7M{mean1.00,min1.00,Max1.00,Var0.00,StdDev0.00)}

```

Using the `--check` option, the tool will report *Alignments.Correct* (i.e., total alignments that are correct, not necessarily optimal), and *Score.Correct* (i.e., total alignments that have the optimal score). Note that the overall benchmark time will increase due to the overhead introduced by the checking routine, however the *Time.Alignment* should remain the same.

### Algorithms & Implementations Summary

Summary of algorithms/methods implemented within the benchmarking tool. If you are interested 
in benchmarking WFA with other algorithms implemented or integrated into the WFA library, 
checkout branch `benchmark`.

|          Algorithm Name           |       Code-name       | Distance        |  Output   |    Library     |
|-----------------------------------|:---------------------:|:---------------:|:---------:|:--------------:|
| WFA Indel (LCS)                   | indel-wfa             | Indel           | Alignment | WFA2-lib       |
| Bit-Parallel-Myers (BPM)          | edit-bpm              | Edit            | Alignment | WFA2-lib       |
| DP Edit                           | edit-dp               | Edit            | Alignment | WFA2-lib       |
| DP Edit (Banded)                  | edit-dp-banded        | Edit            | Alignment | WFA2-lib       |
| WFA Edit                          | edit-wfa              | Edit            | Alignment | WFA2-lib       |
| DP Gap-linear (NW)                | gap-linear-nw         | Gap-linear      | Alignment | WFA2-lib       |
| WFA Gap-linear                    | gap-linear-wfa        | Gap-linear      | Alignment | WFA2-lib       |
| DP Gap-affine (SWG)               | gap-affine-swg        | Gap-affine      | Alignment | WFA2-lib       |
| DP Gap-affine Banded (SWG Banded) | gap-affine-swg-banded | Gap-affine      | Alignment | WFA2-lib       |
| WFA Gap-affine                    | gap-affine-wfa        | Gap-affine      | Alignment | WFA2-lib       |
| DP Gap-affine Dual-Cost           | gap-affine2p-dp       | Gap-affine (2P) | Alignment | WFA2-lib       |
| WFA Gap-affine Dual-Cost          | gap-affine2p-wfa      | Gap-affine (2P) | Alignment | WFA2-lib       |

* DP: Dynamic Programming
* SWG: Smith-Waterman-Gotoh
* NW: Needleman-Wunsch

### Command-line Options

#### - Input

```
          --algorithm|a <algorithm-code-name> 
            Selects pair-wise alignment algorithm/implementation.
                                                       
          --input|i <File>
            Filename/path to the input SEQ file. That is, file containing the sequence pairs to
            align. Sequences are stored one per line, grouped by pairs where the pattern is 
            preceded by '>' and text by '<'.
            
          --output|o <File>
            Filename/path of the output file containing a brief report of the alignment. Each line
            corresponds to the alignment of one input pair with the following tab-separated fields:
            <SCORE>  <CIGAR>
          
          --output-full <File> 
            Filename/path of the output file containing a report of the alignment. Each line
            corresponds to the alignment of one input pair with the following tab-separated fields:
            <PATTERN-LENGTH>  <TEXT-LENGTH>  <SCORE>  <PATTERN>  <TEXT>  <CIGAR>
```
                                     
#### - Penalties & Span

```                                                  
          --lineal-penalties|p M,X,I
            Selects gap-lineal penalties for those alignment algorithms that use this penalty model.
            Example: --lineal-penalties="0,1,2"
              M - Match penalty
              X - Mismatch penalty
              I - Indel penalty
                
          --affine-penalties|g M,X,O,E
            Selects gap-affine penalties for those alignment algorithms that use this penalty model.
            Example: --affine-penalties="0,4,2,6" 
              M - Match penalty
              X - Mismatch penalty
              O - Open penalty
              E - Extend penalty
          
          --affine2p-penalties M,X,O1,E1,O2,E2 
            Select gap-affine dual-cost penalties for those alignment algorithms that use this  
            penalty model. Example: --affine2p-penalties="0,4,2,6,20,2" 
              M  - Match penalty
              X  - Mismatch penalty
              O1 - Open penalty (gap 1)
              E1 - Extend penalty (gap 1)
              O2 - Open penalty (gap 2)
              E2 - Extend penalty (gap 2)
          
          --ends-free P0,Pf,T0,Tf
            Determines the maximum ends length to allow for free in the ends-free alignment mode.
            Example: --ends-free="100,100,0,0"
              P0 - Pattern begin (for free)
              Pf - Pattern end (for free)
              T0 - Text begin (for free)
              Tf - Text end (for free)
          
```
                         
#### - Wavefront parameters

```                                                                  
          --minimum-wavefront-length <INT>
            Selects the minimum wavefront length to trigger the WFA-Adapt reduction method.
            
          --maximum-difference-distance <INT>
            Selects the maximum difference distance for the WFA-Adapt reduction method.  
```
                   
#### - Others

```           
          --bandwidth <INT>
            Selects the bandwidth size for those algorithms that use bandwidth strategy. 
            
          --num-threads|t <INT>
            Sets the number of threads to use to align the sequences. If the multithreaded mode is
            enabled, the input is read in batches of multiple sequences and aligned using the number
            of threads configured. 
            
          --batch-size <INT>
            Selects the number of pairs of sequences to read per batch in the multithreaded mode.
            
          --check|c 'correct'|'score'|'alignment'                    
            Activates the verification of the alignment results. 
          
          --check-distance 'edit'|'gap-lineal'|'gap-affine'
            Select the alignment-model to use for verification of the results.
          
          --check-bandwidth <INT>
            Sets a bandwidth for the simple verification functions.

          --help|h
            Outputs a succinct manual for the tool.
```

## 5. GPU Benchmark Tool

Some usage examples are the following, note that depending on the amount of
memory available on the GPU, batch size may be increased or decreased:
* `.seq` file, banded: `./gpu_baseline.sh -i sample.dataset.seq -b 100000 -e 3000 -t 512 -x -B auto -o sample.out`
* `.seq` file, exact: `./gpu_baseline.sh -i sample.dataset.seq -b 100000 -e 3000 -t 512 -x -o sample.out`

Running the binary without any arguments lists the help menu:

```
[Input/Output]
        -i, --input-seq                     (string) Input sequences file in .seq format: File containing the sequences to align in .seq format.
        -Q, --input-fasta-query             (string) Input query file in .fasta format: File containing the query sequences to align (if not using a .seq file).
        -T, --input-fasta-target            (string) Input target file in .fasta format: File containing the target sequences to align (if not using a .seq file).
        -n, --num-alignments                (int) Number of alignments: Number of alignments to read from the file (default=all alignments)
        -o, --output-file                   (string) Output File: File where alignment output is saved.
        -p, --print-output                  Print: Print output to stderr
        -O, --output-verbose                Verbose output: Add the query/target information on the output
[Alignment Options]
        -g, --affine-penalties              (string) Affine penalties: Gap-affine penalties for the alignment, in format x,o,e
        -x, --compute-cigar                 Compute CIGAR: Compute the optimal alignment path (CIGAR) of all the alignments, otherwise, only the distance is computed.
        -e, --max-distance                  (int) Maximum error allowed: Maximum error that the kernel will be able to compute (default = maximum possible error of first alignment)
        -b, --batch-size                    (int) Batch size: Number of alignments per batch.
        -B, --band                          (int) Banded execution: If this parameter is present, a banded approach is used (heuristic).The parameter tells how many steps to wait until the band is re-centered. Use "auto" to use an automatically generated band.
[System]
        -c, --check                         Check: Check for alignment correctness
        -t, --threads-per-block             (int) Number of CUDA threads per alginment: Number of CUDA threads per block, each block computes one or multiple alignment
        -w, --workers                       (int) GPU workers: Number of blocks ('workers') to be running on the GPU.
[Examples]
        ./bin/wfa.affine.gpu -i sequences.seq -b <batch_size> -o scores.out
        ./bin/wfa.affine.gpu -i sequences.seq -b <batch_size> -B auto -o scores-banded.out
        ./bin/wfa.affine.gpu -Q queries.fasta -T targets.fasta -b <batch_size> -o scores.out
        ./bin/wfa.affine.gpu -Q queries.fasta -T targets.fasta -b <batch_size> -x -o cigars.out
```

Choosing the correct alignment and system options is key for performance. The tool tries to automatically choose adequate parameters, but the user
may have additional information to make a better choice. It is especially important to limit the maximum error supported by the kernel as much as
possible (`-e` parameter), this constrains the memory used per alignment and helps the program to choose better block and grid sizes. Keep in mind that any alignment having an error higher than the specified with the `-e` argument will be computed on the CPU, so, if this argument is too small, performance can decrease.

For big alignments, setting a band (i.e. limiting maximum wavefront size) with the `-B` argument can give significant
speedups, at the expense of potentially losing some accuracy in corner cases.

#### Note
This README is a concatenation of the READMEs of the baseline repos