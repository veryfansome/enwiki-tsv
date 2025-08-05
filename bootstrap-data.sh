#!/usr/bin/env bash
set -e

ENWIKI_TABLE=(
  category
  categorylinks
  page
  page_props
)
MYSQL_CMD=(mysql enwiki)

for TBL in "${ENWIKI_TABLE[@]}"; do
    set -x
    TBL_DUMP_FILE="enwiki-latest-${TBL}.sql"
    TBL_GZIP_FILE="${TBL_DUMP_FILE}.gz"
    if [ ! -f "data/${TBL_DUMP_FILE}" ]; then
        if [ ! -f "data/${TBL_GZIP_FILE}" ]; then
            curl -L \
                -o "data/$TBL_GZIP_FILE" \
                "https://dumps.wikimedia.org/enwiki/latest/${TBL_GZIP_FILE}"
        fi
        pigz -d -p 8 "data/$TBL_DUMP_FILE"
    fi
    "${MYSQL_CMD[@]}" <<< "SHOW TABLES;" | grep "^${TBL}$" || "${MYSQL_CMD[@]}" < "data/$TBL_DUMP_FILE"
    set +x
done

TSV_FILE=(
  category
  page
  page-links
  subcat-links
)
for SUFFIX in "${TSV_FILE[@]}"; do
    set -x
    if [ ! -f "data/enwiki-latest-${SUFFIX}.tsv" ]; then
        "${MYSQL_CMD[@]}" < "sql/enwiki-${SUFFIX}.sql" > "data/enwiki-latest-${SUFFIX}.tsv"
    fi
    set +x
done
