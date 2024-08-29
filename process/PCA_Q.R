# 加载必要的库
library(ggplot2)
library(reshape2)
library(ggrepel)

# 第一步：读取矩阵文件并生成对称矩阵
read_matrix_file <- function(file_path) {
  mat_df <- read.csv(file_path, header = FALSE, stringsAsFactors = FALSE)

  # 提取行和列标签
  row_labels <- mat_df[-1, 1]
  col_labels <- mat_df[1, -1]

  # 提取矩阵部分
  mat <- as.matrix(mat_df[-1, -1])

  # 将字符型转换为数值型
  mat <- apply(mat, 2, as.numeric)

  # 生成对称矩阵
  sym_mat <- mat + t(mat) - diag(diag(mat))

  # 设置行和列名
  rownames(sym_mat) <- row_labels
  colnames(sym_mat) <- col_labels

  return(sym_mat)
}

# 第二步：遍历Q文件夹中的所有文件，生成对称矩阵列表
read_matrices <- function(folder_path) {
  file_list <- list.files(folder_path, full.names = TRUE)
  matrix_list <- list()

  for (file in file_list) {
    sym_mat <- read_matrix_file(file)
    matrix_list[[file]] <- sym_mat
  }

  return(matrix_list)
}

# 第三步：将矩阵展平成向量
flatten_matrix <- function(matrix_list) {
  flattened_list <- lapply(matrix_list, function(mat) {
    return(as.vector(mat))
  })

  data_matrix <- do.call(rbind, flattened_list)
  return(data_matrix)
}

# 第四步：PCA分析
perform_pca <- function(data_matrix) {
  pca_result <- prcomp(data_matrix, scale. = TRUE)
  return(pca_result)
}

# 第五步：PCA结果可视化
plot_pca <- function(pca_result, file_names) {
  pca_df <- as.data.frame(pca_result$x)

  # 处理文件名，只保留基名
  pca_df$file <- gsub("^.*/|\\.csv$", "", file_names)

  # 提取PCA解释的方差百分比
  variance_percent <- round(100 * pca_result$sdev^2 / sum(pca_result$sdev^2), 2)

  # 获取X和Y的范围
  x_range <- range(pca_df$PC1)
  y_range <- range(pca_df$PC2)

  # 扩展范围
  x_expand <- x_range[2] - x_range[1]
  y_expand <- y_range[2] - y_range[1]

  # 绘制PCA图
  ggplot(pca_df, aes(x = PC1, y = PC2, label = file)) +
    geom_point() +
    geom_text_repel() +  # 使用ggrepel避免标注重叠
    xlim(x_range[1] - x_expand/5, x_range[2] + x_expand/5) +  # 扩展X轴范围
    ylim(y_range[1] - y_expand/5, y_range[2] + y_expand/5) +  # 扩展Y轴范围
    theme_minimal() +
    labs(title = "PCA of Exchangability Matrices",
         x = paste0("PC1 (", variance_percent[1], "%)"),
         y = paste0("PC2 (", variance_percent[2], "%)"))
}

# 主程序
folder_path <- "Q"
matrix_list <- read_matrices(folder_path)
data_matrix <- flatten_matrix(matrix_list)
pca_result <- perform_pca(data_matrix)

# 获取文件名列表用于显示
file_names <- list.files(folder_path, full.names = FALSE)
plot_pca(pca_result, file_names)

