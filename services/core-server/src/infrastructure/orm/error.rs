use std::io;

use diesel::result::Error as DieselError;
use thiserror::Error;

// ===========================================================================

#[derive(Debug, Error)]
pub enum RepositoryError {
    #[error("Database error: {0}")]
    Database(#[from] DieselError),

    #[error("I/O error: {0}")]
    Io(#[from] io::Error),

    #[error("Validation error: {0}")]
    Validation(String),

    #[error("Unknown error: {0}")]
    Unknown(String),
}

// ===========================================================================
