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
      child_category.cat_id         AS child_id
--    , child_category.cat_title      AS child_title
    , parent_category.cat_id        AS parent_id
--    , parent_category.cat_title     AS parent_title
FROM
    categorylinks                   AS cl
JOIN
    filtered_category               AS parent_category ON parent_category.cat_title = cl.cl_to
JOIN
    page                            AS p
    ON
        p.page_id                   = cl.cl_from
    AND p.page_namespace            = 14  -- Category pages
    AND p.page_title                RLIKE @TITLE_INCLUDE_EXPR
    AND p.page_title                RLIKE '^(?!.*_stubs|.*_templates)'
    AND p.page_is_redirect          = 0
    AND p.page_is_new               = 0
JOIN
    filtered_category               AS child_category ON child_category.cat_title = p.page_title
WHERE
    cl.cl_type                      = 'subcat'
ORDER
    BY p.page_title                 ASC
;
