# enwiki-tsv

Code for downloading and processing .sql dump files of English Wikipedia data used to generate the .tsv files published to the [veryfansome/enwiki-tsv](https://huggingface.co/datasets/veryfansome/enwiki-tsv/tree/main) dataset on Hugging Face. 

### Tables
- category
- categorylinks
- page
- page_props

### Generated files
- enwiki-latest-category.tsv
- enwiki-latest-page.tsv
- enwiki-latest-page-links.tsv
- enwiki-latest-subcat-links.tsv

### Dataset usage example:
```python
import polars as pl
from datasets import load_dataset

enwiki_category_df =(
    load_dataset("veryfansome/enwiki-tsv", data_files="enwiki-latest-category.tsv", split="train")
    .to_polars().lazy()
)
enwiki_page_df =(
    load_dataset("veryfansome/enwiki-tsv", data_files="enwiki-latest-page.tsv", split="train")
    .to_polars().lazy()
)
enwiki_page_links_df =(
    load_dataset("veryfansome/enwiki-tsv", data_files="enwiki-latest-page-links.tsv", split="train")
    .to_polars().lazy()
)
enwiki_subcat_links_df =(
    load_dataset("veryfansome/enwiki-tsv", data_files="enwiki-latest-subcat-links.tsv", split="train")
    .to_polars().lazy()
)

if __name__ == '__main__':
    qry = "Physics"
    filtered_category_df = enwiki_category_df.filter(pl.col("cat_title") == qry).collect()
    print(filtered_category_df)

    subcat_df = (
        filtered_category_df
        .lazy()
        .join(enwiki_subcat_links_df, left_on="cat_id", right_on="parent_id", how="inner")
        .drop(["cat_id", "cat_title", "cat_pages", "cat_subcats"])
        .join(enwiki_category_df, left_on="child_id", right_on="cat_id", how="inner")
        .drop(["cat_pages", "cat_subcats"])
        .rename({"child_id": "cat_id"})
        .sort(by=['cat_title'])
        .collect()
    )
    print(subcat_df)

    category_page_df = (
        enwiki_page_links_df
        .filter(pl.col("cat_id").is_in(
            filtered_category_df["cat_id"].to_list() + subcat_df["cat_id"].to_list()
        ))
        .join(enwiki_category_df, on="cat_id", how="inner")
        .drop(["cat_pages", "cat_subcats"])
        .join(enwiki_page_df, on='page_id', how='inner')
        .sort(by=['page_title'])
        .collect()
    )
    print(category_page_df)
```
Output:
```text
shape: (1, 4)
┌────────┬───────────┬───────────┬─────────────┐
│ cat_id ┆ cat_title ┆ cat_pages ┆ cat_subcats │
│ ---    ┆ ---       ┆ ---       ┆ ---         │
│ i64    ┆ str       ┆ i64       ┆ i64         │
╞════════╪═══════════╪═══════════╪═════════════╡
│ 24251  ┆ Physics   ┆ 39        ┆ 13          │
└────────┴───────────┴───────────┴─────────────┘
shape: (11, 2)
┌───────────┬───────────────────────┐
│ cat_id    ┆ cat_title             │
│ ---       ┆ ---                   │
│ i64       ┆ str                   │
╞═══════════╪═══════════════════════╡
│ 143329257 ┆ Concepts_in_physics   │
│ 249249303 ┆ Eponyms_in_physics    │
│ 158173    ┆ History_of_physics    │
│ 151267748 ┆ Modern_physics        │
│ 248687917 ┆ Physical_modeling     │
│ …         ┆ …                     │
│ 157163484 ┆ Physics-related_lists │
│ 248798234 ┆ Physics_by_country    │
│ 246996    ┆ Physics_education     │
│ 246610393 ┆ Subfields_of_physics  │
│ 247938415 ┆ Works_about_physics   │
└───────────┴───────────────────────┘
shape: (223, 5)
┌──────────┬───────────┬─────────────────────┬─────────────────────────────────┬─────────────────────────────────┐
│ page_id  ┆ cat_id    ┆ cat_title           ┆ page_title                      ┆ short_description               │
│ ---      ┆ ---       ┆ ---                 ┆ ---                             ┆ ---                             │
│ i64      ┆ i64       ┆ str                 ┆ str                             ┆ str                             │
╞══════════╪═══════════╪═════════════════════╪═════════════════════════════════╪═════════════════════════════════╡
│ 34357822 ┆ 246996    ┆ Physics_education   ┆ AP_Physics                      ┆ College Board examinations      │
│ 38051313 ┆ 246996    ┆ Physics_education   ┆ AP_Physics_1                    ┆ College Board exam              │
│ 43458076 ┆ 246996    ┆ Physics_education   ┆ AP_Physics_2                    ┆ College Board exam              │
│ 4973059  ┆ 246996    ┆ Physics_education   ┆ AP_Physics_B                    ┆ Advanced Placement course and … │
│ 5793570  ┆ 246996    ┆ Physics_education   ┆ AP_Physics_C:_Electricity_and_… ┆ Advanced Placement course       │
│ …        ┆ …         ┆ …                   ┆ …                               ┆ …                               │
│ 71138    ┆ 143329257 ┆ Concepts_in_physics ┆ Wave_function_collapse          ┆ Process by which a quantum sys… │
│ 1884336  ┆ 143329257 ┆ Concepts_in_physics ┆ Wigner_quasiprobability_distri… ┆ Wigner distribution function i… │
│ 21903944 ┆ 246996    ┆ Physics_education   ┆ WolframAlpha                    ┆ Search and answer engine        │
│ 1621535  ┆ 158173    ┆ History_of_physics  ┆ Woodstock_of_physics            ┆ 1987 American Physical Society… │
│ 84400    ┆ 143329257 ┆ Concepts_in_physics ┆ Zero-point_energy               ┆ Lowest possible energy of a qu… │
└──────────┴───────────┴─────────────────────┴─────────────────────────────────┴─────────────────────────────────┘
```