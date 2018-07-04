# GCA: Gene Correlation Analysis in Single-cell RNA-seq data

Author: Feng Zhang

Email: 15110700005@fudan.edu.cn

# Demo

Human Oligodendrogliomas: http://omics.fudan.edu.cn/static/demo/GCA/GSE70630/index.html

![image](/image.png "image")

# Requirements

    Operating system: Mac or Linux, python=2.7, R=3.5    
    Python packages: scipy    
    R packages: stringr, pastecs, mixtools, igraph

# Tips

1. Get normalized expression matrix:  [sup1_normData.R](/sup1_normData.R) 

2. Downstream analysis of regulatory feature binary matrix: [sup2_Downstream.R](/sup2_Downstream.R)

# How to run GCA

i) Build expression index ( Python )

    python | step1_BuildIndex.py | NETWORK | EXP | OUTPUT_INDEX | RATE
    
    NETWORK: a list of tab-delimited gene pairs 
    EXP: normalized expression matrix (without quotation marks)    
    OUTPUT_INDEX: the index file name, given by the user   
    RATE: the cutoff for the non-zero rate. For each gene pair, non-zero rate equals to the proportion of cells of which two genes both are detected. 

ii) Generate Z-value matrix ( Python )

    python | step2_CalZmat.py | OUTPUT_INDEX | OUTPUT_ZMAT | CPU    
    
    OUTPUR_INDEX: the index file generated in the first step    
    OUTPUT_ZMAT: the z-value matrix file name, given by the user   
    CPU: the number of threads to run GCA 

iii) Mixture models analysis ( R )

    Rscript | step3_deMix.R | EXP | OUTPUT_ZMAT | OUTPUT | CPU | SEED | CUTOFF
    
    EXP: the expression matrix used in the first step
    OUTPUT_ZMAT: the z-value matrix generated in the second step
    OUTPUT: the name of the output directory, given by the user
    CPU: the number of threads to run GCA 
    SEED: seed for random function in R
    CUTOFF: the cutoff of edge score to draw the gene graph
    
iv) Get regulatory feature binary matrix ( Python )

    python | step4_getRegFeature.py | MODE | GCA_OUTPUT | OUTPUT
    
    MODE: a list of tab-delimited gene pairs with regulatory mode information (TRRUST file or your own file in the same format)
    GCA_OUTPUT: the OUTPUT directory of GCA
    OUTPUT: the regulatory feature binary matrix
    
    
# Result introduction

The result summary HTML file named “index.html” locates in the output directory. A result demo is available at: http://omics.fudan.edu.cn/static/demo/GCA/GSE70630/index.html

The left side of this page records the contribution score of each gene, and the right side presents the edge score of each gene pair.

Links:

    “Graph” links to the gene graph that shows the path of genes that might contribute to the expression heterogeneity. 
    “Args” links to the txt file that records GCA running options 
    “txt” in “MixInfo” links to the txt file that records the parameters of ‘mixtools’ (Benaglia, et al., 2010).
    “txt” in “Cluster” links to the txt file that records the cell labels, z-values, sub-group labels, color keys, and gene’s expression values.
    “pdf” in “Figure” links to the pdf file that shows all the figure result for each gene pair.

# Adjust figures generated by GCA 

Users can simply adjust the figure by loading the “OUTPUT.saved_RData” into R, and generate different figures following the scripts in: step3_deMix.R
