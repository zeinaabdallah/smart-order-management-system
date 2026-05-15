CREATE TABLE users
(
    id            UUID        NOT NULL DEFAULT gen_random_uuid(),
    email         VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(50)  NOT NULL DEFAULT 'USER',
    created_at    TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP    NOT NULL DEFAULT now(),

    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT uq_users_email UNIQUE (email)
);


-- This is the first Flyway migration for the auth-service. 
-- It creates the users table that the auth-service owns.

-- When auth-service starts, Flyway runs this SQL against the PostgreSQL container. 
-- After that the JPA User entity you'll 
-- write later maps directly to this table. 
-- You never edit this file again — if the schema needs to change, 
-- you write V2__...sql.
