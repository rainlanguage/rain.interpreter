use anyhow::Result;
use clap::{Parser, Subcommand};

pub mod eval2; 

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
pub struct Cli {
    #[command(subcommand)]
    interpreter: Interpreter,
} 

#[derive(Subcommand)]
pub enum Interpreter {
     Eval2(eval2::Eval2),
}

pub async fn dispatch(interpreter: Interpreter) -> Result<()> {
    match interpreter {
        Interpreter::Eval2(eval2) => {
            let _ = eval2::handle_eval2(eval2).await;
            Ok(())
        }
    }
}

pub async fn main() -> Result<()> {
    let cli = Cli::parse(); 
    dispatch(cli.interpreter).await    
}
