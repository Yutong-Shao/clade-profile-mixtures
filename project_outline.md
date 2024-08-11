
# 1. The overall aims of my project

***Project Title: Do profile mixture models better explain the evolution of plant genes?***

***Description:***

Capturing the evolutionary characteristics of amino acid substitutions in protein sequences has traditionally been accomplished using empirical matrices. 

On one hand, the development of empirical matrices has been very slow over the past decade, with few people estimating their own new Q matrices. On the other hand, due to different functional constraints and structural characteristics within proteins, using a single empirical matrix or a single equilibrium frequency does not adequately describe all the information in the process of protein evolution. To address this issue, [Quang et al. (2008)](https://academic.oup.com/bioinformatics/article/24/20/2317/260174) designed **the profile mixture model C20-C60**, which assumes a common exchangeability matrix and different equilibrium frequency profiles. This method has been tested and can improve the robustness of phylogenetic reconstruction in saturated data.

Regarding the development of empirical matrices, [Minh et al. (2021)](https://academic.oup.com/sysbio/article/70/5/1046/6146362) has developed a suite of new methods to estimate models of molecular evolution for proteins, including a model, **Q.plant**, designed to encapsulate key features of plant protein evolution.

However, the aforementioned Q.plant was derived under the assumption that all sites share a single set of equilibrium amino acid frequencies. The proposal of **GTRpmix** [(Banos et al., 2024)](https://www.biorxiv.org/content/10.1101/2024.03.29.587376v1) provides a robust method for estimating exchangeability matrices corresponding to different profile mixture models.

***This project will be based on the GTRpmix model and will test a series of extensions to the Q.plant model. And test whether they better help explain the evolution of plant genes. These extensions include:***

> 1. Q.plantC10 to Q.plantC60: Q matrices estimated under pre-defined profile mixture models C10-C60

>2. Q.plantF1 to Q.plantF10: Q matrices estimated under profile mixture models with 1 to 10 classes estimated from plants


# 2. What dataset I will use and why

The green plants (Viridiplantae) are estimated to comprise between 450,000 and 500,000 species, showcasing a high level of diversity and evolutionary timescale. To better study the evolution of green plants, [the 1KP dataset](https://zenodo.org/records/3255100), also known as the 1,000 Plants Project, conducted extensive taxonomic sampling of green plants. This project generated a total of 1,342 transcriptomes representing broad plants (including green plants, glaucophytes, and red algae), covering 1,124 species.

The 1KP dataset provides various alignment files, including single-copy gene alignment files and supermatrix alignment files. These aligned sequences are generated after certain filtering steps and classified according to different gene loci, providing excellent samples for further phylogenetic studies.


# 3. A brief description of the dataset

The 1KP dataset provides detailed species analysis data and scripts, mainly including: 

- Species trees

- Gene trees

- Gene and supermatrix alignments

- Various species analysis scripts

- Supplementary data for the papers

In the gene alignment files, the 1KP dataset provides alignment files generated after different filtering steps. This project will use the single-copy gene alignment files from `alignments-FAA-masked.tar.bz`, as they have undergone all major filtering steps (including the removal of gap sites and fragment sequences) and are used for the main results.

A summary of the data contained in this file is as follows:

| Seqs        | Sites         | Loci          | Training      | Testing       |
|-------------|---------------|---------------|---------------|---------------|
| 1187        | 155575        | 410           | 369           | 41            |

# 4. Describe a small subset of the data that I can test my code on

## (a) Method for Selecting 100 Taxa:

1. In QMaker, the dataset from [Ran et al. (2018)](https://royalsocietypublishing.org/doi/10.1098/rspb.2018.1012) was used to estimate Q.plant. This dataset includes 38 species: 22 gymnosperms, 3 ferns, and 13 angiosperms. Initially, I considered all 38 species, but after screening, only 22 species were suitable for the current dataset (some species were not present in the 1KP dataset, and others had insufficient gene information collected).

2. Figure 2 in [the 1KP paper](https://www.nature.com/articles/s41586-019-1693-2) depicts the phylogenetic inference of 410 single-copy nuclear gene families (using ASTRAL). I considered selecting major clades involved in the figure, screening the complementary set of the aforementioned 22 species in the dataset to fill the remaining 78 taxa.

3. I counted the presence of each sequence in the gene alignment information of each gene in the 1KP dataset. For sequences within the same order, I prioritized those with a larger number of genes included.

    - For a detailed list, please see: `/data/process/total_species.csv`; For detailed code, please see:`/data/process/species2gene.py` 

> [!TIP]\
> **I have currently attempted to screen 54 species**, including a significant number of dicotyledons, monocotyledons, and gymnosperms, as well as a few ferns and algae. For details, please see: `/data/selected_species.csv`.\
> In the subsequent selection of 46 species, I will consider screening some bryophytes and then continue to expand the number to 100 according to a certain proportion for these different phyla (angiosperms, gymnosperms, ferns, bryophytes, algae).

## (b) Selecting Genes for Training and Testing

Once the 100 taxa to be selected are roughly determined:

There are a total of 410 genes.

First, count the number of taxa included in each gene. For genes with very few taxa sequences (meaning most sequence information at this gene locus will be empty), I will delete them. 
<span style="color: gray;"> (*I checked the number of species involved in each gene file, and most genes perform well, so not many will be deleted, just about 4-5 genes.)*</span>


After screening, these gene sequences will be shuffled. The first 90% will be used for training, and the last 10% for testing.

- Due to the insufficient number of selected taxa, the detailed calculation output CSV has not yet been submitted to GitHub.

## (c) Description of Example Data

I selected 12 species and 10 genes to create a simulated dataset for running the code from the section five.

- In the alignment sequence files of these 10 genes, I used the code from `/data/process/filter_species.py` to extract the 12 species I needed. Corresponding FASTA files named after the gene numbers were generated sequentially and saved in the `/data/example_genes` folder.

- The code to concatenate these gene alignment sequences:

```
iqtree2 -p genes/ --out-aln example_training.phy
```

# 5. The plan for what commands I'll need to run my analysis

> [!Note]\
> **Question 1:**\
> Do I not need to partition the model based on different gene loci?\
> **Question 2:**\
> If the answer to Question 1 is no, do I need to concatenate the sequences into two .nex files based on training genes and testing genes, the former for estimating the Q matrix and profile, and the latter for testing?

## (a) Estimate Q.1kp+F1 according to the method in QMaker

1. First, find the appropriate rate distribution:

```
iqtree2 -s example_alignment.nex -mset LG,WAG,JTT -m MFP --link-model
```

2. Based on the best rate distribution obtained above, estimate Q.1kp+F1: <span style="color: gray;"> *(About 1h to run this code on my own computer.)*</span>

```
iqtree2 -s example_alignment.nex -m "GTR20+FO+<rate>" --link-exchange --init-exchange LG --link-model -pre Q1F1
```

3. Extract the resulting Q.plantF1:

```
grep -A 21 "can be used as input for IQ-TREE" Q1F1.iqtree | tail -n20 > Q.plantF1
```

> [!Note]\
> **Question 3:**\
> The above code seems to need to be used in a Linux environment and doesn't run in my Windows terminal.\
> I used the following code as a replacement, but the format of the generated <Q.plantF1> file differs from the <Q.plant> format I downloaded from the QMaker supplementary materials, preventing me from reading it correctly in IQ-TREE.
> ``` 
> Get-Content Q1F1.iqtree | Select-String -Pattern "can be used as input for IQ-TREE" -Context 0,21 | Select-Object -Last 20 | Out-file Q.plantF1 
> ```
> I will try running the Linux environment on my Windows system soon to see if it works properly. <span style="color: gray;"> *(Or, it might be that I made a mistake in referencing the Q.plantF1 code at the time, and I will recheck it.)*</span>

4. Use PCA analysis to compare Q.plantF1 with Q.plant and other matrices. The expected Q.plantF1 should be similar to Q.plant, proving the above analysis method is correct.

I ran the above steps using example data. For detailed output information, please refer to `/data/output`。

## (b) Continue to estimate Q.plantF2 - Q.plantF10

Estimate the Q matrix anew each time, and initialize the matrix each time to the latest Q matrix. For example, the process of estimating F2 and F3 is as follows:

```
iqtree -s example_alignment.nex -m "GTR20+F2+<rate>" --mdef Q1F1.GTRPMIX.nex --init-exchange GTRPMIX --link-model -pre Q2F2
```

```
iqtree -s example_alignment.nex -m "GTR20+F3+<rate>" --mdef Q2F2.gtrpmix.nex --init-exchange GTRPMIX --link-model -pre Q3F3
```

# 6. What I will measure and why

**1. The log-likelihoods, AIC, and BIC:** 

- It is expected that the log-likelihoods, AIC, and BIC obtained from the new Q.plant models will numerically perform better than those from the old models.

**2. Principle components analysis (PCA):** 

- Use PCA to compare the properties of these new amino acid models to previously estimated models, examining the differences in properties between different models and the main sources of these differences.

**3. Concordance factor:** 

- The concordance factor measures the similarity between gene trees and species trees. For this project, I would use both the new and old models on the same data, hoping to observe that the gene trees generated by the new model have a higher concordance factor.
