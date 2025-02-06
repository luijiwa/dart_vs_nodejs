wrk -t4 -c100 -d10s http://localhost:8081/users/1
wrk -t4 -c100 -d10s http://localhost:8082/users/1
Running 10s test @ http://localhost:8081/users/1
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    80.29ms    5.96ms 109.34ms   82.29%
    Req/Sec   311.38     58.35   470.00     47.00%
  12412 requests in 10.01s, 3.68MB read
Requests/sec:   1239.42
Transfer/sec:    376.42KB
Running 10s test @ http://localhost:8082/users/1
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    35.21ms   29.77ms 513.09ms   98.11%
    Req/Sec   774.59    115.95     0.91k    90.00%
  30867 requests in 10.01s, 8.95MB read
Requests/sec:   3082.74
Transfer/sec:      0.89MB


wrk -t4 -c100 -d10s http://localhost:8081/users/1
wrk -t4 -c100 -d10s http://localhost:8082/users/1
Running 10s test @ http://localhost:8081/users/1
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    81.93ms  102.77ms 732.99ms   85.01%
    Req/Sec   524.14    117.07   830.00     70.25%
  20886 requests in 10.02s, 6.20MB read
Requests/sec:   2085.14
Transfer/sec:    633.33KB
Running 10s test @ http://localhost:8082/users/1
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    31.75ms   19.67ms 398.01ms   98.56%
    Req/Sec   828.98    112.46     1.00k    81.25%
  33017 requests in 10.01s, 9.57MB read
Requests/sec:   3297.52
Transfer/sec:      0.96MB