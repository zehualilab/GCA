
################################################################
# Cluster
################################################################


library(Seurat)

a = as.matrix(read.table('MODE_MAT.txt',header=T,row.names=1))
SUM = apply(a,2,sum)
B = which(SUM>=3)
b = a[,B]
RSUM=apply(b,1,sum)
b=b[which(RSUM>0),]

all_gene=rownames(b)

EXP = CreateSeuratObject(raw.data = b, min.cells = 0, min.genes=0)
EXP=NormalizeData(object = EXP, normalization.method = "LogNormalize", scale.factor = 10000)
EXP = ScaleData(object = EXP,, genes.use = all_gene)

PCNUM=40
EXP <- RunPCA(object = EXP, pc.genes = all_gene, do.print = TRUE, pcs.print = 1:5,    genes.print = 5, pcs.compute=PCNUM, maxit = 500, weight.by.var = FALSE )
PCElbowPlot(object = EXP,num.pc=PCNUM)

PCAPlot(object = EXP, dim.1 = 1, dim.2 = 2)

PCUSE=1:10
EXP = RunTSNE(object = EXP, dims.use = PCUSE, do.fast = TRUE,check_duplicates = FALSE )

RES=0.6
EXP <- FindClusters(object = EXP, reduction.type = "pca", dims.use = PCUSE,  resolution = RES, print.output = 0, save.SNN = TRUE,force.recalc =T)
TSNEPlot(object = EXP,do.label=T)

EXP@scale.data=as.matrix(EXP@data)
pbmc=EXP
library(dplyr)
pbmc.markers <- FindAllMarkers(object = pbmc, only.pos = TRUE, min.pct = 0.05, thresh.use = 0.1)
pbmc.markers %>% group_by(cluster) %>% top_n(2, avg_logFC)
top10 <- pbmc.markers %>% group_by(cluster) %>% top_n(10, avg_logFC)
DoHeatmap(object = pbmc, genes.use = top10$gene, slim.col.label = TRUE, remove.key = TRUE,col.low = "grey90", col.mid = "grey75", col.high = "red",cex.row=6 )

pdf('CLUSTER.pdf',width=5,height=5)
TSNEPlot(object = EXP,do.label=T)
dev.off()
pdf('HEAT.pdf',width=15,height=15)
DoHeatmap(object = pbmc, genes.use = top10$gene, slim.col.label = TRUE, remove.key = TRUE,col.low = "grey90", col.mid = "grey90", col.high = "red",cex.row=6 )
dev.off()

write.table(file='IDENT.txt',EXP@ident,row.names=T,col.names=F,sep='\t',quote=F)
write.table(pbmc.markers ,file='markers.txt',row.names=T,col.names=T,quote=F,sep='\t')
write.table(top10,file='top10.txt',row.names=T,col.names=T,quote=F,sep='\t')

################################################################
# Draw Graph
################################################################

library(stringr)
library(igraph)

top10=read.table('top10.txt',row.names=1,header=T)

cluster_list = unique(top10[,6])

pdf('GRAPH.pdf',width=30,height=18)
par(mfrow=c(3,5))
for(this_cluster in cluster_list){   
    this_cluster_info=top10[which(top10[,6]==this_cluster),]  
    
    check_list=c()
    TG_EXP=c()
    TF_EXP=c()
    i=1
    while(i<=length(this_cluster_info[,1])){
        
        this_tftg_info = unlist(strsplit(as.character(this_cluster_info[i,7]), '.',fixed=TRUE))   
        this_tf=this_tftg_info[2]
        this_tg=this_tftg_info[4]
        this_mode=this_tftg_info[6]
        this_tg_exp=this_tftg_info[8]
        if(this_tg_exp == 'HI' & this_mode=='A'){this_tf_exp='HI'}
        if(this_tg_exp == 'HI' & this_mode=='R'){this_tf_exp='LW'}
        if(this_tg_exp == 'LW' & this_mode=='A'){this_tf_exp='LW'}
        if(this_tg_exp == 'LW' & this_mode=='R'){this_tf_exp='HI'}
        check_list=c(check_list,paste0(this_tf,':',this_tg))
        TG_EXP=cbind(TG_EXP,c(this_tg,this_tg_exp,this_cluster_info[i,4]))
        TF_EXP=cbind(TF_EXP,c(this_tf,this_tf_exp,this_cluster_info[i,4]))
        i=i+1}
    


    ALL_EXP=t(cbind(TG_EXP,TF_EXP))
    #TG_EXP=t(TG_EXP)
    #TF_EXP=t(TF_EXP)
    


    NET = cbind(rep('tag',length(this_cluster_info[,1])),rep('tag',length(this_cluster_info[,1])))  
    EDGE_COLOR = c()
    NODE_COLOR = c()
    i=1
    while(i<=length(this_cluster_info[,1])){
        
        this_tftg_info = unlist(strsplit(as.character(this_cluster_info[i,7]), '.',fixed=TRUE))   
        this_tf=this_tftg_info[2]
        this_tg=this_tftg_info[4]
        this_mode=this_tftg_info[6]
        this_tg_exp=this_tftg_info[8]
        if(this_tg_exp == 'HI' & this_mode=='A'){this_tf_exp='HI'}
        if(this_tg_exp == 'HI' & this_mode=='R'){this_tf_exp='LW'}
        if(this_tg_exp == 'LW' & this_mode=='A'){this_tf_exp='LW'}
        if(this_tg_exp == 'LW' & this_mode=='R'){this_tf_exp='HI'}
          
        MAX_TG_INDEX=which(as.numeric(  ALL_EXP[which(ALL_EXP[,1]==this_tg),3])==max( as.numeric(  ALL_EXP[which(ALL_EXP[,1]==this_tg),3])))[1]
        MAX_TF_INDEX=which(as.numeric(  ALL_EXP[which(ALL_EXP[,1]==this_tf),3])==max( as.numeric(  ALL_EXP[which(ALL_EXP[,1]==this_tf),3])))[1]


        if( ALL_EXP[which(ALL_EXP[,1]==this_tg & ALL_EXP[,2]==this_tg_exp),2]  ==  ALL_EXP[which(ALL_EXP[,1]==this_tg),2][MAX_TG_INDEX] 

            & ALL_EXP[which(ALL_EXP[,1]==this_tf & ALL_EXP[,2]==this_tf_exp),2]  ==  ALL_EXP[which(ALL_EXP[,1]==this_tf),2][MAX_TF_INDEX] 
            # & length(which(check_list ==paste0(this_tf,':',this_tg)))==1
            ){
            
            if(this_mode=='A'){EDGE_COLOR = c(EDGE_COLOR ,'red')}
            else{EDGE_COLOR = c(EDGE_COLOR ,'blue')}
                
            if(this_tg_exp=='HI'){NODE_COLOR = cbind(NODE_COLOR ,c(this_tg,'red'))}
            else{NODE_COLOR = cbind(NODE_COLOR ,c(this_tg,'blue'))}
        
            NODE_COLOR=as.matrix(NODE_COLOR)
        
            if(! this_tf %in% t(NODE_COLOR)[,1] ){ 
                if(this_tg_exp=='HI' & this_mode=='A'){ NODE_COLOR=cbind(NODE_COLOR ,c(this_tf, 'red'))}
                if(this_tg_exp=='LW' & this_mode=='A'){ NODE_COLOR=cbind(NODE_COLOR ,c(this_tf, 'blue'))}
                if(this_tg_exp=='HI' & this_mode=='R'){ NODE_COLOR=cbind(NODE_COLOR ,c(this_tf, 'blue'))}
                if(this_tg_exp=='LW' & this_mode=='R'){ NODE_COLOR=cbind(NODE_COLOR ,c(this_tf, 'red'))}
            }
        
             print(this_tftg_info)
        
             NET[i,1]=this_tf
             NET[i,2]=this_tg
             }        
        i=i+1}
    NET=NET[which(NET[,1]!='tag' & NET[,2]!='tag'),]
    g <- make_graph(t(NET),directed = TRUE)    
    E(g)$color = EDGE_COLOR
    NODE_COLOR=t(as.matrix(NODE_COLOR))
    #node.color=setNames( t(NODE_COLOR)[,2],t(NODE_COLOR)[,1])
    
    NEW_NODE_COLOR=c()
    VG=as.character(V(g))
    for(vg in names(V(g))){     
        this_node_color= NODE_COLOR[which(NODE_COLOR[,1]==as.character(vg)),2]  
        V(g)[vg]$color<-this_node_color
        }   
    plot(main=as.character(this_cluster), g, vertex.label.cex=1.5,edge.width=1, vertex.size=10, vertex.label.dist=2, vertex.label.color = "black")
      
    }
dev.off()



