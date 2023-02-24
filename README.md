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
scp <uNID>@lonepeak.chpc.utah.edu:<path-to-repository>/example_fastqc.zip .```
unzip example_fastqc.zip
cd example_fastqc
open fastqc_report.html
```
> note: This will copy to whatever directory you are in.

At the top of the page, you should see information about the 'Basic statistics' for your reads in the file example.fastq. You have 25 total sequences in this file, each of which is of length 100 bp. If you look at the example.fastq file (e.g., ```less example.fastq```), you'll see that each read is 100 bp in length (this is your read length).

Under this, you should see a section called 'Per base sequencing quality' with a plot that looks like this:

![abbrev-pipeline](./images/fastqc_plot.png)

This shows you the average quality score for your reads at each position. On this plot, you'll see that each column represents a position (1-100). Each column also has a value represented by the blue line. This is your average score at that position across your reads. Most of the reads start of strong (Phred score > 30), but then they tapers toward the end where the score drops beneath the standard threshold of 30. The base calls with scores less than 30 should be trimmed (removed).
> note: We chose '30' as our cutoff. However, the cutoff you choose may be different. You need to decide based on the needs of your project what your cutoff is going to be.


# Trimming

To trim our reads, we will use the program 'fastp'. The syntax for this program is simple, and is described on their [documentation](https://github.com/OpenGene/fastp). Execute the following command.

```fastp -q 15 -u 40 -i example_raw.fastq -o example_cleaned.fastq```

Information on what the options for this program do is provided in the table below.


| Flag  |  Full option                  | Description                         | Default |
|:-----:|:--------------------------:|:-----------------------------------:|:-------:|
|  ```-q```   |  ```--qualified_quality_phred``` | The threshold for qualifying ```a``` base | 15      |
|  ```-u```   |  ```--unqualified_percent_limit``` | Reads with ```u```% bases under ```q``` value are discarded | 40   |
|  ```-e```   |  ```--average_qual```              | Reads with average quality of ```e``` are discarded   | 0    |


