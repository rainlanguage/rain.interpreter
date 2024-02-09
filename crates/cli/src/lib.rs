use crate::commands::Parse;
use crate::execute::Execute;
use anyhow::Result;
use clap::Parser;

mod commands;
mod execute;
mod fork;
mod output;

#[derive(Parser)]
pub enum Interpreter {
    Parse(Parse),
}

impl Interpreter {
    pub async fn execute(self) -> Result<()> {
        match self {
            Interpreter::Parse(parse) => parse.execute().await,
        }
    }
}
