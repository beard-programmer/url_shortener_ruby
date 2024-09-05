# API Benchmarking Guide

This guide will help you benchmark the **Encode** and **Decode** endpoints of your URL shortener service using **ApacheBench (ab)**.

## Prerequisites

Before running benchmarks, ensure the following:
1. **Sinatra** application is running (API server) on `localhost:4567`.
2. You have **ApacheBench** (ab) installed. It usually comes bundled with the **Apache HTTP Server** package on most Linux and macOS systems.

To check if **ApacheBench** is installed, run:
```bash
ab -V
```

If it is not installed, you can install it using a package manager:
- On macOS (via Homebrew): `brew install httpd`
- On Ubuntu/Debian: `sudo apt-get install apache2-utils`

## Benchmarking the API Endpoints

We will benchmark two API endpoints:

1. `/encode` - Encodes a long URL into a short URL.
2. `/decode` - Decodes a short URL back to the original URL.

### 1. Benchmarking the **Encode** Endpoint
Run the following command to benchmark the `/encode` endpoint:

```bash
ab -p benchmarks/encode_data.json \
   -T application/json \
   -H "Content-Type: application/json" \
   -n 1000 \
   -c 50 \
   http://127.0.0.1:4567/encode
```
### 2. Benchmarking the **Decode** Endpoint

Create a file `benchmarks/decode_data.json` with the following content:

Run the following command to benchmark the `/decode` endpoint:

```bash
ab -p benchmarks/decode_data.json \
   -T application/json \
   -H "Content-Type: application/json" \
   -n 1000 \
   -c 50 \
   http://127.0.0.1:4567/decode
```

### Interpreting the Results

After running the benchmarks, ApacheBench will output the results. Some key metrics to observe:

- **Requests per second**: The number of requests the server can handle per second.
- **Time per request**: Average time taken to handle a single request.
- **Failed requests**: Number of requests that failed during the benchmark.

Sample output:
```
Requests per second:    296.65 [#/sec] (mean)
Time per request:       168.546 [ms] (mean)
Failed requests:        0
```

### 3. Adjusting the Benchmark

You can adjust the following parameters depending on your testing needs:
- `-n`: Increase or decrease the number of requests for more accurate results.
- `-c`: Adjust the concurrency level to see how your server handles different loads.

Example:
```bash
ab -p benchmarks/encode_data.json \
   -T application/json \
   -H "Content-Type: application/json" \
   -n 2000 \
   -c 100 \
   http://127.0.0.1:4567/encode
```

## Conclusion

