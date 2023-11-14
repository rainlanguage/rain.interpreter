mod cli;
pub(crate) mod interpreter;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    cli::main().await
}
