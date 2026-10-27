# Master runner for dataset pages & cards
# Run from repository root:
#   source("scripts/build_all_datasets.R")

message("=== [1/2] Generating cards listing (scripts/03_generate_cards.R) ===")
source("scripts/03_generate_cards.R")

message("=== [2/2] Generating dataset detail pages (scripts/04_generate_dataset_qmd.R) ===")
source("scripts/04_generate_dataset_qmd.R")

message("\nRebuild complete! Next steps:")
message("  quarto render")
message("  quarto render datasets/")
message("  quarto preview\n")
