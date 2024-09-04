require 'benchmark/ips'

module DotMethodVsLambdaVsDirectCall
  # Simple Operation: A quick task
  def self.quick_task(input)
    input + 1
  end

  # Complex Operation: A long-running, resource-intensive task
  def self.heavy_computation(input)
    (1..1_000_000).reduce(input) { |sum, n| sum + n }
  end

  # Context-Heavy Operation: A task that captures a lot of context or uses deep stacks
  def self.deep_context_task(input)
    1_000.times do
      input += 1
    end
    input
  end

  def self.run_benchmark
    # Lambdas for each operation
    quick_task_lambda = ->(input) { DotMethodVsLambdaVsDirectCall.quick_task(input) }
    heavy_computation_lambda = ->(input) { DotMethodVsLambdaVsDirectCall.heavy_computation(input) }
    deep_context_task_lambda = ->(input) { DotMethodVsLambdaVsDirectCall.deep_context_task(input) }

    # Method objects for each operation
    quick_task_method = DotMethodVsLambdaVsDirectCall.method(:quick_task)
    heavy_computation_method = DotMethodVsLambdaVsDirectCall.method(:heavy_computation)
    deep_context_task_method = DotMethodVsLambdaVsDirectCall.method(:deep_context_task)

    Benchmark.ips do |x|
      # Benchmark simple operation
      x.report("Simple Operation: Direct call") do
        DotMethodVsLambdaVsDirectCall.quick_task(1)
      end
      x.report("Simple Operation: Lambda call") do
        quick_task_lambda.call(1)
      end
      x.report("Simple Operation: Method object call") do
        quick_task_method.call(1)
      end
      # Compare the results for each type
      x.compare!
    end

    Benchmark.ips do |x|
      # Benchmark complex operation
      x.report("Complex Operation: Direct call") do
        DotMethodVsLambdaVsDirectCall.heavy_computation(1)
      end
      x.report("Complex Operation: Lambda call") do
        heavy_computation_lambda.call(1)
      end
      x.report("Complex Operation: Method object call") do
        heavy_computation_method.call(1)
      end
      # Compare the results for each type
      x.compare!
    end

    Benchmark.ips do |x|
      # Benchmark context-heavy operation
      x.report("Context-Heavy Operation: Direct call") do
        DotMethodVsLambdaVsDirectCall.deep_context_task(1)
      end
      x.report("Context-Heavy Operation: Lambda call") do
        deep_context_task_lambda.call(1)
      end
      x.report("Context-Heavy Operation: Method object call") do
        deep_context_task_method.call(1)
      end

      # Compare the results for each type
      x.compare!
    end
  end
end

# Execute the benchmark
DotMethodVsLambdaVsDirectCall.run_benchmark
