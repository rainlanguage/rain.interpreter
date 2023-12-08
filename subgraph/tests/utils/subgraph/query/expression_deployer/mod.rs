use std::str::FromStr;

use self::expression_deployer::{ExpressionDeployerExpressionDeployer, ResponseData, Variables};
use super::send_request;
use anyhow::{anyhow, Result};
use ethers::types::Address;
use graphql_client::{GraphQLQuery, Response};
use serde::{Deserialize, Serialize};

#[derive(GraphQLQuery)]
#[graphql(
    schema_path = "tests/utils/subgraph/query/schema.json",
    query_path = "tests/utils/subgraph/query/expression_deployer/query.graphql",
    response_derives = "Debug, Serialize, Deserialize"
)]
pub struct ExpressionDeployer;

#[derive(Serialize, Deserialize, Debug)]
pub struct QueryResponse {
    pub id: Address,
}

impl QueryResponse {
    pub fn from(response: ResponseData) -> QueryResponse {
        let deployer: ExpressionDeployerExpressionDeployer = response.expression_deployer.unwrap();

        QueryResponse {
            id: Address::from_str(&deployer.id).expect("invalid string address"),
        }
    }
}

pub async fn get_query(id: &Address) -> Result<QueryResponse> {
    let variables = Variables {
        id: format!("{:?}", id).to_string().into(),
    };
    let request_body = ExpressionDeployer::build_query(variables);
    let response: Response<ResponseData> = send_request(request_body).await?.json().await?;

    match response.data {
        Some(data) => Ok(QueryResponse::from(data)),
        None => Err(anyhow!("Failed to get query")),
    }
}
