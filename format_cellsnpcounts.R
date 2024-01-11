library(data.table)
library(tidyverse)

getdf <- function(x, ...) {
  
  s <- Matrix::summary(x)
  
  row <- s$i
  if (!is.null(rownames(x))) {
    row <- rownames(x)[row]
  }
  col <- s$j
  if (!is.null(colnames(x))) {
    col <- colnames(x)[col]
  }
  
  ret <- data.table(
    snvid = row, 
    cellid = col, 
    value = s$x,
    stringsAsFactors = FALSE
  )
  ret
}

message("Read in list of barcodes")
samples <- fread(snakemake@input$results_sample, header = FALSE, col.names = "barcode") %>%
  .[, cellid := 1:.N]

message("Read in VCF")
vcf <- fread(snakemake@input$vcf)

message("Format VCF files")
vcf <- vcf %>%
  .[, snvid := 1:.N] %>%
  rename(CHROM = `#CHROM`) %>% 
  select(-ID, -QUAL, -FILTER, -INFO)

message("Read in matrix files")
DP <- Matrix::readMM(snakemake@input$results_DP_mtx)
DPdf <- getdf(DP) %>%
  rename(DP = value)
AD <- Matrix::readMM(snakemake@input$results_AD_mtx)
ADdf <- getdf(AD) %>%
  rename(AD = value)

message("Matrix counts and vcf")
newdf <- ADdf[DPdf, nomatch = NA, on = c("cellid", "snvid")] %>%
  setnafill(., type = "const", cols = c("AD"), fill = 0) %>% 
  merge(., vcf, all.x = TRUE, on = "snvid") 

newdf$cell_id <- samples$barcode
newdf <- newdf %>% 
  select(cell_id, CHROM, POS, REF, ALT, AD, DP) %>% 
  dplyr::rename(chr = CHROM, pos = POS, ref = REF, alt = ALT, alt_counts = AD, total_counts = DP)

fwrite(newdf, file = snakemake@output$alldata)