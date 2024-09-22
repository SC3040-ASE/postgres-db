CREATE OR REPLACE FUNCTION tag_search(
    param_category_id INTEGER,
    title TEXT,
    description TEXT,
    numResults INT
)
RETURNS TABLE (
    tag_id INTEGER,
    tag_name VARCHAR(255),
    tag_category_id INTEGER,
    score REAL
) AS $$
DECLARE
    query_embedding VECTOR(1536);
    searchQuery TEXT := title || ' ' || description;
BEGIN
    query_embedding := azure_openai.create_embeddings('ase', searchQuery);

    RETURN QUERY
    SELECT
        t.id AS tag_id,
        t.tag_name,
        t.category_id AS tag_category_id,
        (t.embedding <=> query_embedding)::REAL AS score
    FROM
        TAG t
    WHERE
        t.category_id = param_category_id
    ORDER BY
        score ASC
    LIMIT numResults;
END;
$$ LANGUAGE plpgsql;

-- Purpose: Search for products based on a search query with a range
CREATE OR REPLACE FUNCTION product_search_range(
    searchQuery TEXT,
    startRank INT,
    endRank INT
)
    RETURNS TABLE (
                      product_id INTEGER,
                      owner_id INTEGER,
                      owner_username VARCHAR(255),
                      product_name VARCHAR(255),
                      price DECIMAL(10, 2),
                      condition VARCHAR(255),
                      current_quantity INTEGER,
                      created_on TIMESTAMP,
                      score REAL,
                      total_count INTEGER
                  ) AS $$
DECLARE
    query_embedding VECTOR(1536);
BEGIN
    query_embedding := azure_openai.create_embeddings('ase', searchQuery);

    RETURN QUERY
        WITH ranked_products AS (
            SELECT
                p.id AS product_id,
                p.owner_id,
                u.username AS owner_username,
                p.product_name,
                p.price,
                p.condition,
                p.current_quantity,
                p.created_on,
                (p.embedding <=> query_embedding)::REAL AS score,
                ROW_NUMBER() OVER (ORDER BY (p.embedding <=> query_embedding)::REAL ASC) AS rank
            FROM
                PRODUCT p
                    JOIN
                _USER u ON p.owner_id = u.id
                    JOIN
                CATEGORY c ON p.category_id = c.id
                    LEFT JOIN
                PRODUCT_TAG pt ON p.id = pt.product_id
                    LEFT JOIN
                TAG t ON pt.tag_id = t.id
            WHERE
                (p.embedding <=> query_embedding)::REAL < 0.25::REAL
            GROUP BY
                p.id, u.username, c.category_name
        ),
             total_count AS (
                 SELECT COUNT(*)::INTEGER AS total_count
                 FROM ranked_products
             )
        SELECT
            rp.product_id,
            rp.owner_id,
            rp.owner_username,
            rp.product_name,
            rp.price,
            rp.condition,
            rp.current_quantity,
            rp.created_on,
            rp.score,
            tc.total_count
        FROM
            ranked_products rp,
            total_count tc
        WHERE
            rp.rank BETWEEN startRank AND endRank
        ORDER BY
            rp.rank ASC;
END;
$$ LANGUAGE plpgsql;

-- Purpose: Search for products based on a search query with a range and owner id
CREATE OR REPLACE FUNCTION product_search_range(
    searchQuery TEXT,
    startRank INT,
    endRank INT,
    ownerId INT
)
    RETURNS TABLE (
                      product_id INTEGER,
                      owner_id INTEGER,
                      owner_username VARCHAR(255),
                      product_name VARCHAR(255),
                      price DECIMAL(10, 2),
                      condition VARCHAR(255),
                      current_quantity INTEGER,
                      created_on TIMESTAMP,
                      score REAL,
                      total_count INTEGER
                  ) AS $$
DECLARE
    query_embedding VECTOR(1536);
BEGIN
    query_embedding := azure_openai.create_embeddings('ase', searchQuery);

    RETURN QUERY
        WITH ranked_products AS (
            SELECT
                p.id AS product_id,
                p.owner_id,
                u.username AS owner_username,
                p.product_name,
                p.price,
                p.condition,
                p.current_quantity,
                p.created_on,
                (p.embedding <=> query_embedding)::REAL AS score,
                ROW_NUMBER() OVER (ORDER BY (p.embedding <=> query_embedding)::REAL ASC) AS rank
            FROM
                PRODUCT p
                    JOIN
                _USER u ON p.owner_id = u.id
                    JOIN
                CATEGORY c ON p.category_id = c.id
                    LEFT JOIN
                PRODUCT_TAG pt ON p.id = pt.product_id
                    LEFT JOIN
                TAG t ON pt.tag_id = t.id
            WHERE
                (p.embedding <=> query_embedding)::REAL < 0.25::REAL
                AND p.owner_id = ownerId
            GROUP BY
                p.id, u.username, c.category_name
        ),
             total_count AS (
                 SELECT COUNT(*)::INTEGER AS total_count
                 FROM ranked_products
             )
        SELECT
            rp.product_id,
            rp.owner_id,
            rp.owner_username,
            rp.product_name,
            rp.price,
            rp.condition,
            rp.current_quantity,
            rp.created_on,
            rp.score,
            tc.total_count
        FROM
            ranked_products rp,
            total_count tc
        WHERE
            rp.rank BETWEEN startRank AND endRank
        ORDER BY
            rp.rank ASC;
END;
$$ LANGUAGE plpgsql;
