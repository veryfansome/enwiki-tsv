SET @TITLE_INCLUDE_EXPR := '(*UTF8)(*UCP)^([\\p{Latin}\\p{Nd}''",.:\(\)-]+)(?:_([\\p{Latin}\\p{Nd}''",.:\(\)-]+)){0,9}$';

SELECT
      p.page_id
    , p.page_title
    , ppb.pp_value              AS short_description
FROM
    page                        AS p
JOIN
    page_props                  AS ppb
    ON
            p.page_id           = ppb.pp_page
        AND p.page_namespace    = 0  -- Article pages
        AND p.page_is_redirect  = 0
        AND p.page_is_new       = 0
        AND p.page_len          >= 3000
        AND ppb.pp_propname     = 'wikibase-shortdesc'
WHERE
        p.page_title            RLIKE @TITLE_INCLUDE_EXPR
    AND ppb.pp_value            IS NOT NULL
    AND TRIM(ppb.pp_value)      <> ''
ORDER
    BY p.page_title             ASC
;
