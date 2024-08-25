-- Purpose: Generate embeddings for products before insert or update
CREATE OR REPLACE FUNCTION generate_product_embedding()
RETURNS TRIGGER AS $$
DECLARE
    product_embedding VECTOR(1536);
    var_category_name TEXT;
    var_tags TEXT[];
BEGIN
    -- Retrieve the category name
    SELECT c.category_name INTO var_category_name
    FROM CATEGORY c
    WHERE c.id = NEW.category_id;

    -- Retrieve tags associated with the product (if applicable)
    SELECT array_agg(t.tag_name) INTO var_tags
    FROM TAG t
    JOIN PRODUCT_TAG pt ON t.id = pt.tag_id
    WHERE pt.product_id = NEW.id;

    -- Generate the embedding using the azure_openai.create_embeddings function
    product_embedding := azure_openai.create_embeddings(
        'embedding',
        COALESCE(NEW.product_name, '') || ' ' ||
        COALESCE(NEW.description, '') || ' ' ||
        COALESCE(array_to_string(var_tags, ' '), '') || ' ' ||
        COALESCE(var_category_name, '')
    );

    NEW.embedding := product_embedding;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to generate embedding before inserting a new product
CREATE OR REPLACE TRIGGER create_product_embedding
BEFORE INSERT ON PRODUCT
FOR EACH ROW
EXECUTE FUNCTION generate_product_embedding();

-- Trigger to update embedding before updating an existing product
CREATE OR REPLACE TRIGGER update_product_embedding
BEFORE UPDATE ON PRODUCT
FOR EACH ROW
EXECUTE FUNCTION generate_product_embedding();
