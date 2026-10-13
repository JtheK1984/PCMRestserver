-- Prepared schema only. Apply explicitly to the PCM database before provisioning.
-- No existing password records are changed by this script.
CREATE TABLE manager_vault_keys (
    ID_Benutzer INTEGER NOT NULL PRIMARY KEY,
    KeyID VARCHAR(38) NOT NULL,
    ProtectedKey VARCHAR(4096) NOT NULL
);
