const AWS = require('aws-sdk')
const client = new AWS.Athena({})
const bucket = process.env.BUCKET


exports.handler = function (event, context, callback) {
    console.log("REQUEST RECEIVED:\n" + JSON.stringify(event))
    const ATHENA_OUTPUT_LOCATION = `s3://${bucket}/query/`
    const location = `s3://${bucket}/annealer-experiment/metric/`
    const dropTableSql = "DROP TABLE IF EXISTS qc_batch_performance"

    const createTableSql = "CREATE EXTERNAL TABLE IF NOT EXISTS qc_batch_performance(\n" +
        "\tM int,\n" +
        "\tD int,\n" +
        "\tDevice string,\n" +
        "\tInstanceType string,\n" +
        "\tComputeType string,\n" +
        "\tMins float\n" +
        ") ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\\n' LOCATION '" + location + "'"

    const createViewSql = "CREATE OR REPLACE VIEW qc_batch_performance_view as\n" +
        "select M,\n" +
        "\tD,\n" +
        "\tDevice,\n" +
        "\tInstanceType,\n" +
        "\tComputeType,\n" +
        "\tavg(mins) as mins\n" +
        "from qc_batch_performance\n" +
        "group by M,\n" +
        "\tD,\n" +
        "\tDevice,\n" +
        "\tInstanceType,\n" +
        "\tComputeType\n" +
        "order by M,\n" +
        "\tD,\n" +
        "\tDevice,\n" +
        "\tInstanceType,\n" +
        "\tComputeType"

    const querySql = "SELECT * FROM qc_batch_performance_view"

    console.log("sql:" + dropTableSql)
    client.startQueryExecution({
        QueryString: dropTableSql,
        ResultConfiguration: {OutputLocation: ATHENA_OUTPUT_LOCATION},
    }, (error, results) => {
        if (error) {
            return callback(error)
        } else {
            console.info(results.QueryExecutionId)
            setTimeout(() => {
                client.startQueryExecution({
                    QueryString: createTableSql,
                    ResultConfiguration: {OutputLocation: ATHENA_OUTPUT_LOCATION},
                }, (error, results) => {
                    if (error) {
                        return callback(error)
                    } else {
                        console.info(results.QueryExecutionId)
                        setTimeout(() => {
                            console.log("sql:" + createViewSql)
                            client.startQueryExecution({
                                QueryString: createViewSql,
                                ResultConfiguration: {OutputLocation: ATHENA_OUTPUT_LOCATION},
                            }, (error, results) => {
                                if (error) {
                                    return callback(error)
                                } else {
                                    console.info(results.QueryExecutionId)
                                    setTimeout(() => {
                                        console.log("sql:" + querySql)
                                        client.startQueryExecution({
                                            QueryString: querySql,
                                            ResultConfiguration: {OutputLocation: ATHENA_OUTPUT_LOCATION},
                                        }, (error, results) => {
                                            if (error) {
                                                return callback(error)
                                            } else {
                                                console.info(results.QueryExecutionId)
                                            }
                                        })
                                    }, 10000)
                                }
                            })
                        }, 10000)
                    }
                })
            }, 10000)
        }
    })

    callback(null, {queryResult: ATHENA_OUTPUT_LOCATION})
}