-- Read-only preflight. Run against the PCM database; returns metadata only.
-- Missing rows or insufficient capacity block activation.
-- Includes all schemas so the operator can verify the actual table schema.
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE,
       CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE LOWER(TABLE_NAME) = 'manager_passwoerter'
  AND LOWER(COLUMN_NAME) IN ('password', 'bankingpin', 'encryptet_pwd', 'encryptet_pin')
ORDER BY TABLE_SCHEMA, ORDINAL_POSITION;
