# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark/ips'
require 'hash_kit'

helper = HashKit::Helper.new

# ---------------------------------------------------------------------------
# Hash builders – every benchmark iteration gets a fresh hash so that
# default_proc assignment is always exercised (no short-circuit).
# ---------------------------------------------------------------------------

def build_small_flat_hash
  { 'name' => 'Alice', 'age' => 30, 'active' => true }
end

def build_large_flat_hash(n = 100)
  (0...n).each_with_object({}) { |i, h| h["key_#{i}"] = "value_#{i}" }
end

def build_nested_hash(depth = 5)
  hash = { 'leaf' => 'value' }
  depth.times { |i| hash = { "level_#{i}" => hash, "sibling_#{i}" => 'data' } }
  hash
end

def build_hash_with_arrays
  {
    'users' => [
      { 'name' => 'Alice', 'roles' => [{ 'id' => 1, 'name' => 'admin' }] },
      { 'name' => 'Bob',   'roles' => [{ 'id' => 2, 'name' => 'editor' }] },
      { 'name' => 'Carol', 'roles' => [{ 'id' => 3, 'name' => 'viewer' }] }
    ],
    'meta' => { 'page' => 1, 'total' => 3 }
  }
end

def build_large_nested_hash(width = 20, depth = 4)
  return (0...width).each_with_object({}) { |i, h| h["key_#{i}"] = "val_#{i}" } if depth == 0

  (0...width).each_with_object({}) do |i, h|
    h["node_#{i}"] = build_large_nested_hash(width, depth - 1)
  end
end

# ---------------------------------------------------------------------------
# Benchmark suite
# ---------------------------------------------------------------------------

puts 'HashKit::Helper#indifferent! benchmark'
puts "Ruby #{RUBY_VERSION} / benchmark-ips #{Benchmark::IPS::VERSION}"
puts '=' * 60

Benchmark.ips do |x|
  x.config(warmup: 2, time: 5)

  # --- Scenario 1: small flat hash (3 keys) ---
  x.report('small flat hash (3 keys)') do
    helper.indifferent!(build_small_flat_hash)
  end

  # --- Scenario 2: large flat hash (100 keys) ---
  x.report('large flat hash (100 keys)') do
    helper.indifferent!(build_large_flat_hash(100))
  end

  # --- Scenario 3: deeply nested hash (5 levels) ---
  x.report('nested hash (depth=5)') do
    helper.indifferent!(build_nested_hash(5))
  end

  # --- Scenario 4: hash containing arrays of hashes ---
  x.report('hash with arrays') do
    helper.indifferent!(build_hash_with_arrays)
  end

  # --- Scenario 5: large nested hash (wide + deep) ---
  x.report('large nested (10x3)') do
    helper.indifferent!(build_large_nested_hash(10, 3))
  end

  # --- Scenario 6: many sequential calls on small hashes ---
  x.report('50x sequential small hashes') do
    50.times { helper.indifferent!(build_small_flat_hash) }
  end

  # --- Scenario 7: many sequential calls on medium hashes ---
  x.report('50x sequential nested hashes') do
    50.times { helper.indifferent!(build_nested_hash(3)) }
  end

  x.compare!
end
