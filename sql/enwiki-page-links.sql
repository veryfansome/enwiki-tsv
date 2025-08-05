SET @TITLE_INCLUDE_EXPR := '(*UTF8)(*UCP)^([\\p{Latin}\\p{Nd}''",.:\(\)-]+)(?:_([\\p{Latin}\\p{Nd}''",.:\(\)-]+)){0,9}$';
SET @TITLE_EXCLUDE_EXPR := '^(?!All_|Automatic_category_|Commons_category_link_|Wikipedia_categories_named_after_|Wikipedia_template_|.*_Wikipedians|.*_stubs|.*_templates)';

WITH filtered_category AS (
    SELECT
          c.cat_id
        , c.cat_title
    FROM
        category            AS c
    WHERE
            c.cat_pages     > 0
        AND c.cat_title     NOT IN (
              'Set_categories'
            , 'Stub_categories'
            , 'Stub_categories_needing_attention'
            , 'Wikipedia_soft_redirected_categories'
        )
        AND c.cat_title     RLIKE @TITLE_INCLUDE_EXPR
        AND c.cat_title     RLIKE @TITLE_EXCLUDE_EXPR
)

SELECT
      cl.cl_from        AS page_id
    , fc.cat_id         AS cat_id
FROM
    categorylinks       AS cl
JOIN
    filtered_category   AS fc
    ON fc.cat_title = cl.cl_to
WHERE
    cl.cl_type = 'page'
;
