#install required R and bioconductor packages
source("http://www.Bioconductor.org/biocLite.R")
biocLite("BiocUpgrade")

biocLite(c("Biobase","limma"))

#load Required libraries
library("Biobase")
library("limma")

#navigate to the directory where you put the downloaded protocol files.
setwd("./Files_for_protocol")

#################################################
# Mesenchymal vs Immunoreactive 
#################################################

#load the Gene expression data
expressionMatrix<- read.table( "SupplementaryDataTable1.txt", header = TRUE, sep = "\t", quote="\"",  stringsAsFactors = FALSE)

#load class definitions
classDefinitions <-  read.table( "SupplementaryDataTable3.txt", header = TRUE, sep = "\t", quote="\"",  stringsAsFactors = FALSE)

#create the data matrix for limma with the expression value
minimalSet <- ExpressionSet(assayData=as.matrix(expressionMatrix))

classes <- factor(classDefinitions[,"SUBTYPE"])

modelDesign <- model.matrix(~ 0 + classes)

fit <- lmFit(minimalSet, modelDesign) 

#(2) contrast fitting
contrastnm <- c("classesMesenchymal-classesImmunoreactive") #contrast between a pair of classes
contrast.matrix <- makeContrasts(contrasts=contrastnm, levels=modelDesign)

fit1 <- contrasts.fit(fit, contrast.matrix)

#(3) eBayes fitting
fit2 <- eBayes(fit1)

#(4.1) topfit based on F-statistic
#H1: At least one of the contrasts is significantly differetial.  
topfit <- topTable(fit2, number=nrow(expressionMatrix), adjust="BH")

#create the output matrix
ranks <- cbind(rownames(topfit),topfit[,'t'])
#get rid of missing gene names
ranks <- ranks[which(ranks[,1] != ''),]

colnames(ranks) <- c("GeneID","t-stat")
write.table(ranks,"MesenchymalvsImmunoreactive_limma_ranks.rnk",col.name=TRUE,sep="\t",row.names=FALSE,quote=FALSE)

#output optional expresion file to be used by Enrichment Map
EM_expressionFile <- cbind(rownames(expressionMatrix), rownames(expressionMatrix),expressionMatrix)
colnames(EM_expressionFile)[1] <- "Name"
colnames(EM_expressionFile)[2] <- "Description"
colnames(EM_expressionFile) <- substring(colnames(EM_expressionFile),1,12)
write.table(EM_expressionFile,"MesenchymalvsImmunoreactive_expression.txt",col.name=TRUE,sep="\t",row.names=FALSE,quote=FALSE)


#write out a class file to be used for Enrichment maps
#write out a class file to be used for Enrichment maps
fileConn<-file("MesenchymalvsImmunoreactive_classes.cls")
writeLines(c(paste(length(classDefinitions[,'SUBTYPE']),"2 1"),paste("# ", unique(classDefinitions[,'SUBTYPE'])[1], " ",unique(classDefinitions[,'SUBTYPE'])[2])), fileConn)
write.table(t(classDefinitions[,'SUBTYPE']),"MesenchymalvsImmunoreactive_classes.cls",col.name=FALSE,sep="\t",row.names=FALSE,quote=FALSE,append=TRUE)
close(fileConn)


###################################################################
# Examine the results using a heatmaps to makes sure there is a separation in out samples
library("pheatmap")
library("RColorBrewer")

#try clustering the columns (annotate with the subtype)
annotation_col <- data.frame(SUBTYPE= factor(classDefinitions[,3]))
rownames(annotation_col) <- classDefinitions[,2]
ann_colors = list(
  SUBTYPE = c(Immunoreactive = "#1B9E77", Mesenchymal = "#D95F02")
)

col.pal <- brewer.pal(11,"RdBu")
pheatmap(as.matrix(expressionMatrix[rownames(expressionMatrix) %in% rownames(topfit)[which(topfit$adj.P.Val<0.05)], ]), color = col.pal,
         scale = "row",kmeans_k = NA,show_rownames = F, show_colnames = F,main = "Top differential AFFY genes(Mesen vs Immuno)",
         cluster_rows = TRUE, cluster_cols = FALSE,clustering_distance_rows = "correlation",annotation_col=annotation_col, annotation_colors = ann_colors)


#########################################
# gprofler files - top genes only

#Mesenchymal vs immunoreactive - mesenchymal only
write.table(rownames(topfit[which(topfit$adj.P.Val < 0.001 & topfit$logFC < 0),]),"MesenvsImmuno_mesenonly_Affy_gprofiler.txt",col.name=TRUE,sep="\t",row.names=FALSE,quote=FALSE)

#Mesenchymal vs immunoreactive - immuno only
write.table(rownames(topfit[which(topfit$adj.P.Val < 0.001 & topfit$logFC > 0),]),"MesenvsImmuno_immunoonly_Affy_gprofiler.txt",col.name=TRUE,sep="\t",row.names=FALSE,quote=FALSE)

#Mesenchymal vs immunoreactive - both
write.table(rownames(topfit[which(topfit$adj.P.Val < 0.001),]),"MesenvsImmuno_Affy_gprofiler.txt",col.name=TRUE,sep="\t",row.names=FALSE,quote=FALSE)

