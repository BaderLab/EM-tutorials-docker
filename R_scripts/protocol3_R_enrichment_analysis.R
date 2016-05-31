
###########################################
# using enrichment tools suggested by edgeR - roast, romer or camera
# roast is a self contained gene set test
# camera is a competitive gene set test
# romer is similiar to GSEA but using a rotation approach to gene set randomization

#load the geneset files
library(limma)
library(GSA)

#load in the gmt file
genesets <- GSA.read.gmt("Human_GOBP_AllPathways_no_GO_iea_December_24_2015_symbol.gmt")

#camera and roast expect a list of lists of genesets where the name of each list is the names of the geneset
# the GSEA.read.gmt method loads the gmt file as an object with the list of names and list of genesets.
#merge the two ojbects to create a set of genesets required by roast and camera
names(genesets$genesets) <- genesets$geneset.names

#splice out the entrez gene symbols. - the gmt file we are using is based on gene symbol unlike the built in goana and kegga in edgeR
#We choose to use gene symbols as it is easier to interpret the results when looking at the list of genes associated with the enriched
#genesets
data_for_gs_analysis <- d
temp_names <- rownames(data_for_gs_analysis)
rownames(data_for_gs_analysis) <- unlist(lapply(temp_names,function(x){ unlist(strsplit(x,"\\|"))[1]}))

#additionally camera and roast require that the genesets are filtered by the dataset in question
genesets_filtered <- ids2indices(genesets$genesets, rownames(data_for_gs_analysis), remove.empty=TRUE)

#get the length of each geneset
geneset_sizes <- unlist(lapply(genesets_filtered,length))

#only  include genesets that are greater than 10 but less than 500
geneset_indices <- which(geneset_sizes>=15 & geneset_sizes<500)

type <- data_for_gs_analysis$samples$group
design <- model.matrix(~0+type)

#roast
mroast_results <- mroast(data_for_gs_analysis,genesets_filtered[geneset_indices],design, contrast =2,nrot=10000)

#format output files
mroast_descr <- unlist(lapply(rownames(mroast_results),function(x){unlist(strsplit(x,"\\%"))[1]}))
Phenotype <- unlist(lapply(mroast_results[,"Direction"],function(x){if(x=="Up"){1}else{(-1)}}))

#for each geneset get the list of genes to associate with it (filtered by the dataset)
genes <- c()
for(i in 1:length(rownames(mroast_results))){
  current_geneset <- unlist(genesets_filtered[which(names(genesets_filtered) %in% rownames(mroast_results)[i])])
  current_genes <- c()
  for(j in 1:length(current_geneset)){
    if(j==length(current_geneset)){
      current_genes <- paste(current_genes,rownames(d)[current_geneset[j]],sep="")
    }
    else{
      current_genes <- paste(current_genes,rownames(d)[current_geneset[j]],",",sep="")
    }
  }
  genes <- rbind(genes, current_genes)
}
rownames(genes) <- rownames(mroast_results)

mroast_results_generic_em <- data.frame(rownames(mroast_results),mroast_descr,PValue = mroast_results[,"PValue"],
                                        FDR= mroast_results[,"FDR"],Phenotype,genes )
write.table(mroast_results_generic_em,"mroast_results_generic_em.txt",col.name=TRUE,sep="\t",row.names=FALSE,quote=FALSE)

#################
# calculate enrichments using camera.
##############
camera_results <- camera(data_for_gs_analysis,genesets_filtered[geneset_indices],design,contrast=2)
camera_descr <- unlist(lapply(rownames(camera_results),function(x){unlist(strsplit(x,"\\%"))[1]}))
camera_Phenotype <- unlist(lapply(camera_results[,"Direction"],function(x){if(x=="Up"){1}else{(-1)}}))


camera_genes <- c()
for(i in 1:length(rownames(camera_results))){
  current_geneset <- unlist(genesets_filtered[which(names(genesets_filtered) %in% rownames(camera_results)[i])])
  current_genes <- c()
  for(j in 1:length(current_geneset)){
    if(j==length(current_geneset)){
      current_genes <- paste(current_genes,rownames(d)[current_geneset[j]],sep="")
    }
    else{
      current_genes <- paste(current_genes,rownames(d)[current_geneset[j]],",",sep="")
    }
  }
  camera_genes <- rbind(camera_genes, current_genes)
}
rownames(camera_genes) <- rownames(camera_results)

camera_results_generic_em <- data.frame(rownames(camera_results),camera_descr,PValue = camera_results[,"PValue"],
                                        FDR= camera_results[,"FDR"],Phenotype,genes )

write.table(camera_results_generic_em,"camera_results_generic_em.txt",col.name=TRUE,sep="\t",row.names=FALSE,quote=FALSE)
