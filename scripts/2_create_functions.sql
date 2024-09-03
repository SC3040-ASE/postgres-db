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
    product_image VARCHAR(255),
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
        p.product_image,
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
