use anyhow::Result;
use ethers::types::Address;

mod expression_deployer;

pub static SG_URL: &str = "http://localhost:8000/subgraphs/name/test/test";

pub struct Query;
impl Query {
    pub async fn expression_deployer(id: &Address) -> Result<expression_deployer::QueryResponse> {
        expression_deployer::get_query(id).await
    }
}

async fn send_request<T: serde::Serialize>(request_body: T) -> Result<reqwest::Response> {
    let response = reqwest::Client::new()
        .post(SG_URL)
        .json(&request_body)
        .send()
        .await?;
    Ok(response)
}
