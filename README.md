# trimming_raw_reads
Orientation to raw read trimming for advanced bioinformatics course at Utah Tech University

---

# Contents

-   [Objectives](#objectives)
-   [Genomic Filetypes](#genomic-filetypes)
-   [Basic Processing Steps](#basic-processing-steps)
-   [Exercise](#exercise)

---

# <a name="objectives"></a>
# Objectives

-  Understand why trimming is an important part of bioinformatics pipelines
-  Understand the file conversions
---

# <a name="getting-set-up"></a>
# Getting set up
If you are here as a UTU student taking BIOL 4300, you should do the following:

1.  Login to your [Github](https://github.com/) account.

1.  Fork [this repository](https://github.com/rklabacka/genomics-pipeline-intro), by
    clicking the 'Fork' button on the upper right of the page.

    After a few seconds, you should be looking at *your*
    copy of the repo in your own Github account.

1.  Click the 'Clone or download' button, and copy the URL of the repo via the
    'copy to clipboard' button. **note: if you have an SSH key with your github account, make sure you select the ```SSH``` tab**

1.  Login to the lonepeak cluster (CHPC) from your terminal

1.  On your lonepeak login node, navigate to where you want to keep this repo (
    I recommend having an exercise folder where you can clone repositories for the
    coding exercises). Then type:

        $ git clone the-url-you-just-copied

    and hit enter to clone the repository. Make sure you are cloning **your**
    fork of this repo.

1.  Next, `cd` into the directory:

        $ cd the-name-of-directory-you-just-cloned

1.  At this point, you should be in your own local copy of the repository.

    As you work on the exercise below, be sure to frequently `commit` your work
    and `push` changes to the *remote* copy of the repo hosted on Github.
---

# <a name="what-is-trimming"></a>
# What is trimming?

Raw reads generated from a high-throughput sequencer are stored within the fastq filetype (see the [genomics pipeline intro repository](https://github.com/rklabacka/genomics-pipeline-intro) for details about fastq files). These reads are called "raw" because they have not been adjusted for quality control (e.g., removing sequence with low confidence and removing the adapter sequence used for library preparation).

There are multiple ways to examine the quality of your reads and then perform read cleaning (trimming). We will examine a few bioinformatics packages in this overview, but many other exist that can perform the same or similar tasks.

# Quality check

Before trimming your data, it may be helpful to examine the quality of your reads as a whole. You can perform a quality check using the software package 'fastqc'. This will generate a set of results that can provide quick insight into the quality of your data. You can visualize the results using an html interpreter (e.g., a web browser). For example, copy the file 'SRR11621811_fastqc.zip' to your personal desktop for visualization on a web browser. You can perform a quality check and then visualize the results by performing the following commands:

While on the CHPC in this repository:
```
module load fastqc/0.11.4
fastqc example.fastq
```

Then from your local environment (not from the CHPC terminal window):

```
scp <uNID>@lonepeak.chpc.utah.edu:<path-to-repository>/example_fastqc.zip .
unzip example_fastqc.zip
cd example_fastqc
open fastqc_report.html
```
> note: scp is a way to securely copy a file. The first parameter is the path to the remote file. The second parameter is the path to the destination location (in this scenario we just used the current directory ```.```)
> note: The ```.``` at the end of your scp command means the file you are copying will land in the directory you are in.

At the top of the page, you should see information about the 'Basic statistics' for your reads in the file example.fastq. You have 25 total sequences in this file, each of which is of length 100 bp. If you look at the example.fastq file (e.g., ```less example.fastq```), you'll see that each read is 100 bp in length (this is your read length).

Under this, you should see a section called 'Per base sequencing quality' with a plot that looks like this:

![abbrev-pipeline](./images/fastqc_plot.png)

This shows you the average quality score for your reads at each position. On this plot, you'll see that each column represents a position (1-100). Each column also has a value represented by the blue line. This is your average score at that position across your reads. Most of the reads start of strong (Phred score > 30), but then they tapers toward the end where the score drops beneath the standard threshold of 30. The base calls with scores less than 30 should be trimmed (removed).
> note: We chose '30' as our cutoff. However, the cutoff you choose may be different. You need to decide based on the needs of your project what your cutoff is going to be.


# Trimming

To trim our reads, we will use the program 'fastp'. The syntax for this program is described in their [documentation](https://github.com/OpenGene/fastp). Execute the following command to trim reads within the file ```example_raw.fastq```:

```
module load fastp/0.20.1
fastp \
  -i example_raw.fastq \
  -q 15 \
  -u 40 \
  -e 30 \
  -l 15 \
  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
  -M 25 \
  -W 5  \
  -5 \
  -3 \
  -o example_cleaned.fastq
```

Information on what the options for this program do is provided in the table below. You can see all fastp options by running ```fastp -h```


| Flag                   |  Full option                            | Description                                                              | Default |
|:----------------------:|:---------------------------------------:|:------------------------------------------------------------------------:|:-------:|
|  ```-i``` and ```-I``` |  ```--in1``` and ```--in2```            | Infile(s) (plural if paired-end reads)                                   | NA      |
|  ```-q```              |  ```--qualified_quality_phred```        | The threshold for qualifying ```a``` base                                | 15      |
|  ```-u```              |  ```--unqualified_percent_limit```      | Reads with ```u```% bases under ```q``` value are discarded              | 40      |
|  ```-e```              |  ```--average_qual```                   | Reads with average quality of ```e``` are discarded                      | 0       |
|  ```-l```              |  ```--length_required```                | Reads with length (after filtering) > ```l``` are discarded              | 15      |
|  ```-a```              |  ```--adapter_sequence```               | The nucleotide sequence for the adapter** used for sequencing            | *       |
|                        |  ```--adapter_sequence_r2```            | The adapter sequence** for read 2 in paired-end sequencing               | *       |
|  ```-M```              |  ```--cut_mean_quality```               | The minimum average in a sliding window to not remove bases              | 20      |
|  ```-W```              |  ```--cut_window_size```                | The number of bases in a sliding window                                  | 4       |
|  ```-5```              |  ```--cut_front```                      | Use sliding window to trim leading sequences with averages < ```M```     | OFF     |
|  ```-3```              |  ```--cut_tail```                       | Use sliding window to trim trailing sequences with averages < ```M```    | OFF     |
|  ```-c```              |  ```--correction```                     | Overlap analysis to correct bases with low reads (only for PE reads)     | OFF     |
|  ```-m```              |  ```--merged```	                   | Merge paired-end reads that overlap into a single read                   | OFF     |
|                        |  ```--merged_out```                     | Filename for storing merged reads                                        | NA      |
|  ```-o``` and ```-O``` |  ```--out1``` and ```out2```            | Filenames for unmerged reads that passed trimming filters                | NA      |
|                        |  ```--unpaired1``` and ```unpaired2```  | Filenames for reads that can't be merged because one didn't pass filters | NA      |
|                |  ```--dedup```                          | Duplicate reads\*\*\* (reads with the exact same sequence) are removed   | ON      |
##### \* If no adapter sequence is specified, the adapter sequence is intuited by fastp (which is faster, but can be inaccurate)
##### \*\* The TruSeq adapter sequences are ```AGATCGGAAGAGCACACGTCTGAACTCCAGTCA``` (for read 1) and ```AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT``` (for read2). 
##### \*\*\* This is to remove PCR duplicates, however this feature is only available in fastp versions after 0.22

You'll notice that many of the options in this table aren't implemented in your command above. One reason for this is because the example_raw.fastq contains reads from single-end (SE) sequencing. Options such as ```--in2```, ```adapter_sequence_r2```, ```--correction```, ```--merged``` (and the other 

You can also split the output files into multiple fastq files, which can be helpful if you plan to do mapping in parallel. This options to create 3 output files for a single individual is shown below (we don't include it in this example, but it would decrease downstream processing time).
```fastp --split_prefix_digits=4 --out1=out.fq --split=3```

