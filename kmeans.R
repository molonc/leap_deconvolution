library(data.table)
library(tidyverse)
library(ClusterR)
library(cluster)
library(cowplot)
theme_set(theme_cowplot())

message("Read in counts file")
snv_counts <- fread(snakemake@input$counts)

snvs_sum <- snv_counts[, list(alt_counts = sum(alt_counts), total_counts = sum(total_counts), nvar = .N), by = c("chr", "pos", "ref", "alt")] %>% 
  .[, VAF := alt_counts / (total_counts)]

message("Filter counts file")
snvs_sum <- snvs_sum[VAF > 0.0]
snv_counts <- snv_counts[pos %in% snvs_sum$pos]
positions <- sample(unique(snv_counts$pos), 500)#snakemake@config$n_snps_sample)
snv_counts <- snv_counts[pos %in% positions]

message("Create matrix")
snvsmat <- 
  snv_counts[, id := paste(chr, pos, ref, alt, sep = "_")] %>% 
  as.data.table() %>% 
  .[, alt_counts := fifelse(alt_counts > 1, 1, alt_counts)] %>% 
  dcast(., cell_id ~ id, value.var = "alt_counts", fill = 0)
cell_ids <- snvsmat[, 1]
snvsmat <- as.data.frame(snvsmat[, -1])
row.names(snvsmat) <- cell_ids$cell_id

message("Run PCA")
snvspr <- prcomp(snvsmat, scale. = F)
pcadat <- as.data.frame(snvspr$x)
pcadat$cell_id <- row.names(pcadat)

message("Run K-means")
kmeans.re <- kmeans(snvspr$x[,1:5], centers = 3, nstart = 5)
df_k <- as.data.frame(kmeans.re$cluster)
df_k$cell_id <- row.names(df_k)
names(df_k) <- c("cluster_top5","cell_id")

kmeans.re <- kmeans(snvspr$x, centers = 3, nstart = 5)
df_k2 <- as.data.frame(kmeans.re$cluster)
df_k2$cell_id <- row.names(df_k2)
names(df_k2) <- c("cluster_all","cell_id")

df_k <- left_join(df_k, df_k2) %>% 
  select(cell_id, everything())

df_k_pca <- left_join(df_k, pcadat)

fwrite(df_k, snakemake@output$cluster_assignment)
fwrite(df_k_pca, snakemake@output$cluster_assignment_wpca)

g1 <- df_k_pca %>% ggplot(aes(x = PC1, y = PC2, col = paste0(cluster_top5))) +geom_point() + ggtitle("Top 5 PCA") + theme(legend.title = element_blank())
g2 <- df_k_pca %>% ggplot(aes(x = PC1, y = PC2, col = paste0(cluster_all))) +geom_point() + ggtitle("All PCA") + theme(legend.title = element_blank())
plot_grid(g1, g2) %>% 
  save_plot(snakemake@output$plot, ., base_width = 7, base_height = 3)