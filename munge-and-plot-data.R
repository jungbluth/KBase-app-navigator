#!/usr/bin/env Rscript

dat1<-read.csv("_kbase_apps_w_extended_information-extended.txt", header=F, sep="\t")

colnames(dat1)<-c('KBase.Category','Module.Title','Module.Name','App.Name','Icon.URL','Git.URL','Input.Objects','Output.Objects','Starred.Count','Times.Run','Percent.Success','Time.Taken')

dat1$KBase.cat.Factors1<-dat1$KBase.Category
dat1$KBase.cat.Factors2<-dat1$KBase.Category
dat1$KBase.cat.Factors3<-dat1$KBase.Category
dat1$KBase.cat.ComparativeGenomics<-'0'
dat1$KBase.cat.Expression<-'0'
dat1$KBase.cat.GenomeAnnotation<-'0'
dat1$KBase.cat.GenomeAssembly<-'0'
dat1$KBase.cat.MetabolicModeling<-'0'
dat1$KBase.cat.MicrobialCommunities<-'0'
dat1$KBase.cat.ReadProcessing<-'0'
dat1$KBase.cat.SequenceAnalysis<-'0'
dat1$KBase.cat.Utilities<-'0'

dat1$Starred.Count[which(is.na(dat1$Starred.Count) == TRUE)]<-0

apps.in.mult.categories<-as.vector(dat1[which(duplicated(dat1$Module.Title) == TRUE),2])

for (i in 1:nrow(dat1)) {
  if (i %in% which(duplicated(dat1$Module.Title) == TRUE)) {
    which(dat1$Module.Title == dat1$Module.Title[i])
    if (length(which(dat1$Module.Title == dat1$Module.Title[i])) == 3) {
      dat1[which(dat1$Module.Title == dat1$Module.Title[i])[1],]$KBase.cat.Factors1 <- dat1[which(dat1$Module.Title == dat1$Module.Title[i])[1],]$KBase.Category
      dat1[which(dat1$Module.Title == dat1$Module.Title[i])[1],]$KBase.cat.Factors2 <- dat1[which(dat1$Module.Title == dat1$Module.Title[i])[2],]$KBase.Category
      dat1[which(dat1$Module.Title == dat1$Module.Title[i])[1],]$KBase.cat.Factors3 <- dat1[which(dat1$Module.Title == dat1$Module.Title[i])[3],]$KBase.Category
    }
    if (length(which(dat1$Module.Title == dat1$Module.Title[i])) == 2) {
      dat1[which(dat1$Module.Title == dat1$Module.Title[i])[1],]$KBase.cat.Factors1 <- dat1[which(dat1$Module.Title == dat1$Module.Title[i])[1],]$KBase.Category
      dat1[which(dat1$Module.Title == dat1$Module.Title[i])[1],]$KBase.cat.Factors2 <- dat1[which(dat1$Module.Title == dat1$Module.Title[i])[2],]$KBase.Category
      dat1[which(dat1$Module.Title == dat1$Module.Title[i])[1],]$KBase.cat.Factors3 <- dat1[which(dat1$Module.Title == dat1$Module.Title[i])[2],]$KBase.Category
    }
  }

}



dat2<-unique(dat1[,-1]) #remove duplicated rows because of KBase category cross-listing



for (i in 1:nrow(dat2)) {
  for (j in 1:length(unique(c(as.vector(dat2$KBase.cat.Factors1[i]),as.vector(dat2$KBase.cat.Factors2[i]),as.vector(dat2$KBase.cat.Factors3[i]))))) {
    if (unique(c(as.vector(dat2$KBase.cat.Factors1[i]),as.vector(dat2$KBase.cat.Factors2[i]),as.vector(dat2$KBase.cat.Factors3[i])))[j] == "Read Processing") {
      dat2$KBase.cat.ReadProcessing[i]<-'1'
    }
    if (unique(c(as.vector(dat2$KBase.cat.Factors1[i]),as.vector(dat2$KBase.cat.Factors2[i]),as.vector(dat2$KBase.cat.Factors3[i])))[j] == "Comparative Genomics") {
      dat2$KBase.cat.ComparativeGenomics[i]<-'1'
    }
    if (unique(c(as.vector(dat2$KBase.cat.Factors1[i]),as.vector(dat2$KBase.cat.Factors2[i]),as.vector(dat2$KBase.cat.Factors3[i])))[j] == "Expression") {
      dat2$KBase.cat.Expression[i]<-'1'
    }
    if (unique(c(as.vector(dat2$KBase.cat.Factors1[i]),as.vector(dat2$KBase.cat.Factors2[i]),as.vector(dat2$KBase.cat.Factors3[i])))[j] == "Genome Annotation") {
      dat2$KBase.cat.GenomeAnnotation[i]<-'1'
    }
    if (unique(c(as.vector(dat2$KBase.cat.Factors1[i]),as.vector(dat2$KBase.cat.Factors2[i]),as.vector(dat2$KBase.cat.Factors3[i])))[j] == "Genome Assembly") {
      dat2$KBase.cat.GenomeAssembly[i]<-'1'
    }
    if (unique(c(as.vector(dat2$KBase.cat.Factors1[i]),as.vector(dat2$KBase.cat.Factors2[i]),as.vector(dat2$KBase.cat.Factors3[i])))[j] == "Microbial Communities") {
      dat2$KBase.cat.MicrobialCommunities[i]<-'1'
    }
    if (unique(c(as.vector(dat2$KBase.cat.Factors1[i]),as.vector(dat2$KBase.cat.Factors2[i]),as.vector(dat2$KBase.cat.Factors3[i])))[j] == "Metabolic Modeling") {
      dat2$KBase.cat.MetabolicModeling[i]<-'1'
    }
    if (unique(c(as.vector(dat2$KBase.cat.Factors1[i]),as.vector(dat2$KBase.cat.Factors2[i]),as.vector(dat2$KBase.cat.Factors3[i])))[j] == "Sequence Analysis") {
      dat2$KBase.cat.SequenceAnalysis[i]<-'1'
    }
    if (unique(c(as.vector(dat2$KBase.cat.Factors1[i]),as.vector(dat2$KBase.cat.Factors2[i]),as.vector(dat2$KBase.cat.Factors3[i])))[j] == "Utilities") {
      dat2$KBase.cat.Utilities[i]<-'1'
    }
  }
}







allinputobjects <- unique(unlist(strsplit(as.character(dat2$Input.Objects), split = ",")))
alloutputobjects <- unique(unlist(strsplit(as.character(dat2$Output.Objects), split = ",")))


for (k in 1:length(allinputobjects)) {
  current.col<-ncol(dat2)+1
  dat2[,current.col]<-'0'
  colnames(dat2)[current.col]<-paste0("Input.",allinputobjects[k])
  for (i in 1:nrow(dat2)) {
    if (identical(grep(allinputobjects[k], as.vector(dat1[which(dat1$Module.Title == as.vector(dat2$Module.Title[i])),]$Input.Objects)), integer(0)) == FALSE) {
      dat2[i,current.col]<-'1'
    }
  }
}

for (k in 1:length(alloutputobjects)) {
  current.col<-ncol(dat2)+1
  dat2[,current.col]<-'0'
  colnames(dat2)[current.col]<-paste0("Output.",alloutputobjects[k])
  for (i in 1:nrow(dat2)) {
    if (identical(grep(alloutputobjects[k], as.vector(dat1[which(dat1$Module.Title == as.vector(dat2$Module.Title[i])),]$Output.Objects)), integer(0)) == FALSE) {
      dat2[i,current.col]<-'1'
    }
  }
}


# dat3<-as.vector(dat2$Time.Taken)


# for (i in 1:length(dat3)) {
#   if (identical(grep("h", dat3[i]), integer(0)) == FALSE) {
#     print(as.data.frame(strsplit(dat3[i],"h ")))
#   }
# }

#trim for matrix
dat3<-dat2[,seq(which(colnames(dat2) == "KBase.cat.ComparativeGenomics"),ncol(dat2), by=1)]

dat3 <- as.data.frame(sapply(dat3, as.numeric))
rownames(dat3)<-make.names(as.vector(dat2$Module.Title), unique=TRUE)
rownames(dat2)<-make.names(as.vector(dat2$App.Name), unique=TRUE)

dat3.pca <- prcomp(dat3, center = TRUE)


dat2$PCA.PC1<-as.numeric(dat3.pca$x[,1])
dat2$PCA.PC2<-as.numeric(dat3.pca$x[,2])
dat2$PCA.PC3<-as.numeric(dat3.pca$x[,3])





#dat3<-dat2[,seq(which(colnames(dat2) == "KBase.cat.ComparativeGenomics"),which(colnames(dat2) == "KBase.cat.Utilities"), by=1)]


library(ggbiplot)
library(ggrepel)


as.vector(unique(dat2$KBase.cat.Factors1))
# [1] "Read Processing"       "Genome Assembly"       "Genome Annotation"    
# [4] "Sequence Analysis"     "Comparative Genomics"  "Metabolic Modeling"   
# [7] "Expression"            "Microbial Communities" "Utilities"  

#pal1 = c('#D16197','#0A71A7','#9C1D22','#74B8DC','#6239B3','#23877D','#E6B74D','#328031','#ED8C3C')

pal1 = c('#6239B3','#E6B74D','#9C1D22','#0A71A7','#23877D','#328031','#D16197','#74B8DC','#ED8C3C')



p <- ggplot(dat2, aes(x=PCA.PC1, y=PCA.PC2, fill = factor(KBase.cat.Factors1))) + theme_bw() + geom_point(size=6, stroke=4, shape=21, aes(color = factor(KBase.cat.Factors2))) + geom_point(size=6, stroke=2, shape=21, aes(color = factor(KBase.cat.Factors3))) + guides(fill = guide_legend(title="KBase.cat.Factors1", override.aes=list(shape=21)), color = guide_legend(title="KBase.cat.Factors2")) + scale_fill_manual(values=pal1) + scale_color_manual(values=pal1)

p + geom_text_repel(aes(fill = factor(KBase.cat.Factors1), label = rownames(dat2)), size = 3.5)
p + geom_label(label=rownames(dat2))




ggbiplot(dat3.pca, aes(label = rowname(dat3.pca)), labels=rownames(dat3.pca)) + geom_text_repel(aes(label = rownames(df)), size = 3.5)





