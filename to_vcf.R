library(data.table)
library(tidyverse)

message("Read in counts file")
snv_counts <- fread(snakemake@input$counts)


snvs_sum <- snv_counts[, list(alt_counts = sum(alt_counts), total_counts = sum(total_counts), nvar = .N), by = c("chr", "pos", "ref", "alt")] %>% 
  .[, VAF := alt_counts / (total_counts)]

message("Filter counts file")
snvs_sum <- snvs_sum[VAF > 0.0]
snv_counts <- snv_counts[pos %in% snvs_sum$pos]
positions <- sample(unique(snv_counts$pos), 500)#snakemake@config$n_snps_sample)
snv_counts <- snv_counts[pos %in% positions]

message("Create vcf columns")
snv_counts <- snv_counts[, GT := ifelse(alt_counts > 0, "1/1", "0/0")] %>% 
  .[, DP := total_counts] %>% 
  .[, AD := alt_counts] %>% 
  .[, vcf_entry := paste(GT, DP, AD, sep = ":")] %>% 
  .[, snpid := paste(chr, pos, ref, alt, sep = "_")]

vcf_mat <- snv_counts %>% 
  dcast(., snpid ~ cell_id, value.var = "vcf_entry", fill = ".:.:.")
snpid <- vcf_mat[, 1]
vcf_mat <- vcf_mat[, -1] %>% as.data.frame()
row.names(vcf_mat) <- snpid$snpid

snv_summary <- snv_counts %>% 
  .[, list(alt_counts = sum(alt_counts), total_counts = sum(total_counts)), by = .(chr, pos, ref, alt, snpid)] %>% 
  arrange(chr, pos) %>% 
  mutate(vcf_entry = paste0("AD=", alt_counts, ";DP=", total_counts, ";OTH=0"))

vcf <- data.frame(CHROM = snv_summary$chr, 
                  POS = snv_summary$pos, 
                  ID = snv_summary$snpid, 
                  REF = snv_summary$ref,
                  ALT = snv_summary$alt)
names(vcf) <- c("#CHROM", "POS", "ID", "REF", "ALT")
vcf$QUAL <- "."
vcf$FILTER <- "PASS"
vcf$INFO <- snv_summary$vcf_entry
vcf$FORMAT <- "GT:DP:AD"

message("Write vcf file")
vcf <- bind_cols(vcf, vcf_mat[vcf$ID,])
write("##fileformat=VCFv4.2", snakemake@output$vcf)
fwrite(vcf, snakemake@output$vcf, sep = "\t", append = T, col.names = T)