-- Purpose: Search for products based on a search query
CREATE OR REPLACE FUNCTION product_search(
    searchQuery TEXT,
    numResults INT
)
RETURNS TABLE (
    product_id INTEGER,
    owner_id INTEGER,
    product_name VARCHAR(255),
    price DECIMAL(10, 2),
    tags TEXT[],
    condition VARCHAR(255),
    total_quantity INTEGER,
    current_quantity INTEGER,
    category VARCHAR(255),
    description TEXT,
    score REAL
) AS $$
DECLARE
    query_embedding VECTOR(1536);
BEGIN
    query_embedding := azure_openai.create_embeddings('ase', searchQuery);

    RETURN QUERY
    SELECT
        p.id AS product_id,
        p.owner_id,
        p.product_name,
        p.price,
        COALESCE(array_agg(t.tag_name::TEXT), '{}') AS tags,
        p.condition,
        p.total_quantity,
        p.current_quantity,
        c.category_name AS category,
        p.description,
        (p.embedding <=> query_embedding)::REAL AS score
    FROM
        PRODUCT p
    JOIN
        CATEGORY c ON p.category_id = c.id
    LEFT JOIN
        PRODUCT_TAG pt ON p.id = pt.product_id
    LEFT JOIN
        TAG t ON pt.tag_id = t.id
    GROUP BY
        p.id, c.category_name
    ORDER BY
        score ASC
    LIMIT numResults;
END;
$$ LANGUAGE plpgsql;



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
                      product_name VARCHAR(255),
                      price DECIMAL(10, 2),
                      tags TEXT[],
                      condition VARCHAR(255),
                      total_quantity INTEGER,
                      current_quantity INTEGER,
                      category VARCHAR(255),
                      description TEXT,
                      score REAL
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
                p.product_name,
                p.price,
                COALESCE(array_agg(t.tag_name::TEXT), '{}') AS tags,
                p.condition,
                p.total_quantity,
                p.current_quantity,
                c.category_name AS category,
                p.description,
                (p.embedding <=> query_embedding)::REAL AS score,
                ROW_NUMBER() OVER (ORDER BY (p.embedding <=> query_embedding)::REAL ASC) AS rank
            FROM
                PRODUCT p
                    JOIN
                CATEGORY c ON p.category_id = c.id
                    LEFT JOIN
                PRODUCT_TAG pt ON p.id = pt.product_id
                    LEFT JOIN
                TAG t ON pt.tag_id = t.id
            WHERE
                (p.embedding <=> query_embedding)::REAL < 0.2::REAL
            GROUP BY
                p.id, c.category_name
        )
        SELECT
            ranked_products.product_id,
            ranked_products.owner_id,
            ranked_products.product_name,
            ranked_products.price,
            ranked_products.tags,
            ranked_products.condition,
            ranked_products.total_quantity,
            ranked_products.current_quantity,
            ranked_products.category,
            ranked_products.description,
            ranked_products.score
        FROM
            ranked_products
        WHERE
            ranked_products.rank BETWEEN startRank AND endRank
        ORDER BY
            ranked_products.rank ASC;
END;
$$ LANGUAGE plpgsql;