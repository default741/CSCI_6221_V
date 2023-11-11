module main

import utils
import time
import linear_regression as lr
import py_plot

import read_xlsx_v

struct OLSRegressionDescription {
    mut:
        dependent_variable string
        model_name string
        method string
        datetime time.Time
        no_of_observations int
        r_squared f64
        f_statistic f64
}

struct LinearRegressionParams {
    mut:
        weights []f64
        bias f64
        learning_rate f64
        iterations int
}

fn calculate_gradients(x []f64, y []f64, y_pred []f64) (f64, f64) {
    num_records := x.len

    mut error := []f64{}
    mut loss := []f64{}

    mut dw := 0.0
    mut db := 0.0

    for idx in 0..num_records {
        loss << y[idx] - y_pred[idx]
        error << x[idx] * loss[idx]
    }

    mut dot_product := utils.fsum(error)
    mut loss_sum := utils.fsum(loss)

    dw = -2 * dot_product / num_records
    db = -2 * loss_sum / num_records

    return dw, db
}


fn main() {
    excel_data := read_xlsx_v.parse('./data/test_data_mv.xlsx')!
    mut input_data := excel_data.clone()

    zero_weight_bias := false

    column_names := excel_data.first()
    input_data.delete(0)

    println("Features Used: ${column_names}")

    mut x := [][]f64{len: input_data[0].len - 1, init: []f64{len: input_data.len}}
    mut feature := []f64{}

    mut y := []f64{}

    for mut record in input_data {
        int_record := record.map(it.f64())
        y << int_record[input_data[0].len - 1]
    }

    for idx_i in 0..input_data.len {
        for idx_j in 0..input_data[0].len - 1 {
            x[idx_j][idx_i] = input_data[idx_i][idx_j].f64()
        }
    }

    println(x)

    mut init_weights := []f64{}
    mut init_bias := 0.0

    if zero_weight_bias {
        for idx in 0..x.len {
            init_weights << 0.0
        }

        init_bias = 0.0
    }
    else {
        for idx in 0..x.len {
            init_weights << utils.round(utils.fcovariance(x[idx], y) / utils.fvariance(x[idx]))
        }

        mut slope_x_sum := 0.0

        for idx in 0..x.len {
            slope_x_sum = slope_x_sum + (init_weights[idx] * utils.fmean(x[idx]))
        }

        init_bias = utils.round(utils.fmean(y) - slope_x_sum)
    }

    println(init_weights)
    println(init_bias)


    mut params := LinearRegressionParams {
        weights: init_weights
        bias: init_bias
        learning_rate: 0.01
        iterations: 1000
    }

    mut y_pred := []f64{}

    for idx in 0..params.iterations {
        y_pred = lr.predict(x, params.weights, params.bias)
        dw, db := calculate_gradients(x, y, y_pred)

        params.weight = utils.round(params.weight - (params.learning_rate * dw))
        params.bias = utils.round(params.bias - (params.learning_rate * db))
    }

    // mut results := OLSRegressionDescription {
    //     dependent_variable: column_names[column_names.len - 1]
    //     model_name: "Simple Linear Regression"
    //     method: "Mean Square Error"
    //     datetime: time.now()
    //     no_of_observations: x.len
    //     r_squared: utils.round(lr.r_square(y_pred, y))
    // }

    // println(results)
    // println(params)

    // mut plot_data := py_plot.PlotGraph {
    //     slope: params.weight
    //     intercept: params.bias
    //     feature_data: x
    //     target_data: y
    // }

    // py_plot.plot_graph(mut plot_data)
}