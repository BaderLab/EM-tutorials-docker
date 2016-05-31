#install te gprofiler package if it is not installed
#install.packages("gProfileR")

library("gProfileR");

#navigate to the directory where you put the downloaded protocol files.
setwd("./Files_for_protocol")
##############################################################
#load in the list you would like to test - mesenchymal specific genes
##############################################################
mesenchymal_genes <- read.table( "mesenvsimmuno_mesenonly_RNAseq_gprofiler.txt", header = FALSE, sep = "\t", quote="\"",  stringsAsFactors = FALSE)
mesenchymal_genes <- as.vector(t(mesenchymal_genes))

mesenchymal_gprofiler_results <- gprofiler(mesenchymal_genes,significant=T,ordered_query = T,exclude_iea=T,max_set_size = 500,
                                           correction_method = "fdr",
                                           src_filter = c("GO:BP","KEGG","REAC"))

#using gprofiler through the R interface doesn't allow you to specify a minimum for the term size or overlap size
#filter the results - exclude terms that have less than 3 genes
# exclude terms taht have less than 2 genes in overlap
mesenchymal_gprofiler_results <- mesenchymal_gprofiler_results[which(mesenchymal_gprofiler_results[,'term.size'] >= 3 & mesenchymal_gprofiler_results[,'overlap.size'] >= 2 ),]

#Enrichment map file generic results requires columns : (Name, Description, pvalue, qvalue, phenotype, list of genes)
# because we are running this in R we can actually create one enrichment results file with results from both mesenchymal and immunoreactive 
# searchs merged into one file.  Just change the phenotype value in order to represent the two distinct results in the enrichment map 
#
# gProfileR returns corrected p-values only.  Set p-value to corrected p-value
mesenchymal_em_results <- cbind(mesenchymal_gprofiler_results[,c("term.id","term.name","p.value","p.value")], 1,
                                mesenchymal_gprofiler_results[,"intersection"])
colnames(mesenchymal_em_results) <- c("Name","Description", "pvalue","qvalue","phenotype","genes")

write.table(mesenchymal_em_results,"gprofiler_results_mesenonly_ordered_computedinR.txt",col.name=TRUE,sep="\t",row.names=FALSE,quote=FALSE)


##############################################################
#load in the list you would like to test - immunoreactive specific genes
##############################################################
immunoreactive_genes <- read.table( "mesenvsimmuno_immunoonly_RNAseq_gprofiler.txt", header = FALSE, sep = "\t", quote="\"",  stringsAsFactors = FALSE)
immunoreactive_genes <- as.vector(t(immunoreactive_genes))

immunoreactive_gprofiler_results <- gprofiler(immunoreactive_genes,significant=T,ordered_query = T,exclude_iea=T,max_set_size = 500,
                                           correction_method = "fdr",
                                           src_filter = c("GO:BP","KEGG","REAC"))

#using gprofiler through the R interface doesn't allow you to specify a minimum for the term size or overlap size
#filter the results - exclude terms that have less than 3 genes
# exclude terms taht have less than 2 genes in overlap
immunoreactive_gprofiler_results <- immunoreactive_gprofiler_results[which(immunoreactive_gprofiler_results[,'term.size'] >= 3 
                                                                           & immunoreactive_gprofiler_results[,'overlap.size'] >= 2 ),]

#Enrichment map file generic results requires columns : (Name, Description, pvalue, qvalue, phenotype, list of genes)
# because we are running this in R we can actually create one enrichment results file with results from both immunoreactive and immunoreactive 
# searchs merged into one file.  Just change the phenotype value in order to represent the two distinct results in the enrichment map
#
# gProfileR returns corrected p-values only.  Set p-value
immunoreactive_em_results <- cbind(immunoreactive_gprofiler_results[,c("term.id","term.name","p.value","p.value")], -1,
                                immunoreactive_gprofiler_results[,"intersection"])
colnames(immunoreactive_em_results) <- c("Name","Description", "pvalue","qvalue","phenotype","genes")

write.table(immunoreactive_em_results,"gprofiler_results_immunoonly_ordered_computedinR.txt",col.name=TRUE,sep="\t",row.names=FALSE,quote=FALSE)


##############################################################
#You can either examine the above results in two separate enrichment maps or together in one enrichment map
##############################################################
mesenvsimmuno_em_results <- rbind(immunoreactive_em_results,mesenchymal_em_results)
write.table(mesenvsimmuno_em_results,"gprofiler_results_both_ordered_computedinR.txt",col.name=TRUE,sep="\t",row.names=FALSE,quote=FALSE)


##############################################################
# Create EM through Cyrest interface - make sure you open cytoscape 
# for example from a terminal /Applications/Cytoscape_v3.3.0/cytoscape.sh -R 1234
##############################################################
library(RJSONIO)

library(httr)
# Basic settings
port.number = 1234
base.url = paste("http://localhost:", toString(port.number), "/v1", sep="")

print(base.url)

version.url = paste(base.url, "version", sep="/")
cytoscape.version = GET(version.url)
cy.version = fromJSON(rawToChar(cytoscape.version$content))
print(cy.version)

# to create an Enrichment map we need to specify
# analysisType = generic
# 
enrichmentmap.url <- paste(base.url, "commands","enrichmentmap","build", sep="/") 

enr_file = paste(getwd(),"gprofiler_results_both_ordered_computedinR.txt",sep="/")
#exp_file = paste(getwd(),"MesenchymalvsImmunoreactive_RNAseq_expression.txt",sep="/")
#class_file = paste(getwd(),"MesenchymalvsImmunoreactive_RNAseq_classes.cls",sep="/")

em_params <- list(analysisType = "generic",enrichmentsDataset1 = enr_file,pvalue="1.0",qvalue="0.00001",
                  #expressionDataset1 = exp_file, 
                  similaritycutoff="0.25",coeffecients="JACCARD")

response <- GET(url=enrichmentmap.url, query=em_params)

content(response, "text", encoding = "ISO-8859-1")
  