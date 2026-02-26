# ============================================
# LAB 3: Singleton Pattern
# ============================================
# The Singleton pattern ensures that a class has only one instance
# and provides a global point of access to it.
# Run this file with: ruby singleton.rb

# Exercise 1: Implement a basic Singleton
# Create a Logger class that can only have one instance
# Hint: Use class variables and private constructor

class Logger
  # TODO: Make the constructor private using private_class_method
  # TODO: Create a class variable @@instance
  # TODO: Implement self.instance method that returns the single instance
  @@instance = nil

  def initialize
    @logs = []
  end
  private_class_method :new # запретить прямой new

  def log(message)
    @logs << "[#{Time.now}] #{message}"
  end

  def show_logs
    @logs
  end

  def clear_logs
    @logs.clear
  end

  def self.instance
    @@instance ||= new
  end
end

# Exercise 2: Implement Singleton using Ruby's Singleton module
# Create a Configuration class using Ruby's built-in Singleton module
# Hint: require 'singleton' and include Singleton

require 'singleton'

class Configuration
  # TODO: Include the Singleton module
  include Singleton

  attr_accessor :app_name, :version, :debug_mode

  def initialize
    @app_name = 'MyApp'
    @version = '1.0.0'
    @debug_mode = false
  end

  def settings
    {
      app_name: @app_name,
      version: @version,
      debug_mode: @debug_mode
    }
  end
end

# Exercise 3: Implement a Database Connection Pool Singleton
# Create a DatabaseConnection class that manages a single connection

class DatabaseConnection
  # TODO: Implement Singleton pattern (manually or with module)
  # TODO: Add a @connected attribute to track connection state

  private_class_method :new # или include Singleton

  @@instance = nil
  def self.instance
    @@instance ||= new
  end

  def initialize
    @connected = false
    @connection_string = nil
  end

  def connect(connection_string)
    # TODO: Set @connected to true and save connection_string
    # TODO: Return "Connected to #{connection_string}"
    @connected = true
    "Connected to #{connection_string}"
  end

  def disconnect
    # TODO: Set @connected to false
    # TODO: Return "Disconnected"
    @connected = false
    'Disconnected'
  end

  def connected?
    @connected
  end

  def execute_query(query)
    # TODO: Return "Executing: #{query}" if connected
    # TODO: Return "Not connected to database" if not connected
    return 'Not connected to database' unless connected?

    "Executing: #{query}"
  end
end

# ============================================
# TEST CASES - Do not modify below this line
# ============================================

def run_tests
  tests_passed = 0
  total_tests = 0

  puts 'Testing Singleton Pattern...'
  puts '=' * 40

  # Test 1: Logger Singleton - same instance
  total_tests += 1
  begin
    logger1 = Logger.instance
    logger2 = Logger.instance

    if logger1.equal?(logger2)
      tests_passed += 1
      puts '✓ Test 1 passed: Logger returns same instance'
    else
      puts '✗ Test 1 failed: Logger returns different instances'
    end
  rescue StandardError => e
    puts "✗ Test 1 failed: #{e.message}"
  end

  # Test 2: Logger cannot be instantiated with new
  total_tests += 1
  begin
    Logger.new
    puts '✗ Test 2 failed: Logger.new should raise an error'
  rescue NoMethodError
    tests_passed += 1
    puts '✓ Test 2 passed: Logger.new is private'
  rescue StandardError => e
    puts "✗ Test 2 failed: Wrong error - #{e.message}"
  end

  # Test 3: Logger functionality
  total_tests += 1
  begin
    logger = Logger.instance
    logger.clear_logs
    logger.log('Test message')

    if logger.show_logs.length == 1 && logger.show_logs[0].include?('Test message')
      tests_passed += 1
      puts '✓ Test 3 passed: Logger stores messages'
    else
      puts "✗ Test 3 failed: Logger doesn't store messages correctly"
    end
  rescue StandardError => e
    puts "✗ Test 3 failed: #{e.message}"
  end

  # Test 4: Configuration Singleton
  total_tests += 1
  begin
    config1 = Configuration.instance
    config2 = Configuration.instance

    config1.app_name = 'TestApp'

    if config2.app_name == 'TestApp'
      tests_passed += 1
      puts '✓ Test 4 passed: Configuration shares state'
    else
      puts "✗ Test 4 failed: Configuration instances don't share state"
    end
  rescue StandardError => e
    puts "✗ Test 4 failed: #{e.message}"
  end

  # Test 5: Configuration cannot be instantiated with new
  total_tests += 1
  begin
    Configuration.new
    puts '✗ Test 5 failed: Configuration.new should raise an error'
  rescue NoMethodError
    tests_passed += 1
    puts '✓ Test 5 passed: Configuration.new is private'
  rescue StandardError => e
    puts "✗ Test 5 failed: Wrong error - #{e.message}"
  end

  # Test 6: DatabaseConnection Singleton
  total_tests += 1
  begin
    db1 = DatabaseConnection.instance
    db2 = DatabaseConnection.instance

    if db1.equal?(db2)
      tests_passed += 1
      puts '✓ Test 6 passed: DatabaseConnection returns same instance'
    else
      puts '✗ Test 6 failed: DatabaseConnection returns different instances'
    end
  rescue StandardError => e
    puts "✗ Test 6 failed: #{e.message}"
  end

  # Test 7: DatabaseConnection functionality
  total_tests += 1
  begin
    db = DatabaseConnection.instance
    result = db.connect('localhost:5432')

    if db.connected? && result == 'Connected to localhost:5432'
      tests_passed += 1
      puts '✓ Test 7 passed: DatabaseConnection connects'
    else
      puts "✗ Test 7 failed: DatabaseConnection doesn't connect properly"
    end
  rescue StandardError => e
    puts "✗ Test 7 failed: #{e.message}"
  end

  # Test 8: DatabaseConnection query execution
  total_tests += 1
  begin
    db = DatabaseConnection.instance
    db.connect('localhost:5432')
    result = db.execute_query('SELECT * FROM users')

    if result == 'Executing: SELECT * FROM users'
      tests_passed += 1
      puts '✓ Test 8 passed: DatabaseConnection executes queries'
    else
      puts '✗ Test 8 failed: Query execution incorrect'
    end
  rescue StandardError => e
    puts "✗ Test 8 failed: #{e.message}"
  end
  # Test 9:  Logger stores multiple messages
  total_tests += 1
  begin
    logger = Logger.instance
    logger.clear_logs
    logger.log('Message 1')
    logger.log('Message 2')

    if logger.show_logs.length == 2 &&
       logger.show_logs[0].include?('Message 1') &&
       logger.show_logs[1].include?('Message 2')
      tests_passed += 1
      puts '✓ Test 9 passed: Logger stores multiple messages correctly'
    else
      puts '✗ Test 9 failed: Logger multiple messages issue'
    end
  rescue StandardError => e
    puts "✗ Test 9 failed: #{e.message}"
  end

  # Test 10: Configuration all attributes
  total_tests += 1
  begin
    config = Configuration.instance
    config.app_name = 'NewApp'
    config.version = '2.0.0'
    config.debug_mode = true

    if Configuration.instance.app_name == 'NewApp' &&
       Configuration.instance.version == '2.0.0' &&
       Configuration.instance.debug_mode == true
      tests_passed += 1
      puts '✓ Test 10 passed: Configuration shares all state'
    else
      puts '✗ Test 10 failed: Configuration state not shared correctly'
    end
  rescue StandardError => e
    puts "✗ Test 10 failed: #{e.message}"
  end
  # Test 11: DatabaseConnection disconnect/reconnect
  total_tests += 1
  begin
    db = DatabaseConnection.instance
    db.connect('localhost:5432')
    db.disconnect

    result = db.execute_query('SELECT * FROM users')
    db.connect('localhost:5432')

    if !db.connected? == false && result == 'Not connected to database' &&
       db.execute_query('SELECT 1') == 'Executing: SELECT 1'
      tests_passed += 1
      puts '✓ Test 11 passed: DatabaseConnection disconnect and reconnect works'
    else
      puts '✗ Test 11 failed: Disconnect/reconnect issue'
    end
  rescue StandardError => e
    puts "✗ Test 11 failed: #{e.message}"
  end

  # Test 12: DatabaseConnection multiple instance_ids
  total_tests += 1
  begin
    db1 = DatabaseConnection.instance
    db2 = DatabaseConnection.instance
    db3 = DatabaseConnection.instance

    if db1.equal?(db2) && db2.equal?(db3)
      tests_passed += 1
      puts '✓ Test 12 passed: DatabaseConnection instance is truly singleton'
    else
      puts '✗ Test 12 failed: Multiple instances detected'
    end
  rescue StandardError => e
    puts "✗ Test 12 failed: #{e.message}"
  end

  # Test 13: DatabaseConnection cannot be instantiated with new
  total_tests += 1
  begin
    DatabaseConnection.new
    puts '✗ Test 13 failed: DatabaseConnection.new should raise an error'
  rescue NoMethodError
    tests_passed += 1
    puts '✓ Test 13 passed: DatabaseConnection.new is private'
  rescue StandardError => e
    puts "✗ Test 13 failed: Wrong error - #{e.message}"
  end

  puts "\n#{'=' * 40}"
  if tests_passed == total_tests
    puts "🎉 All tests passed! (#{tests_passed}/#{total_tests})"
    puts 'Excellent! You understand the Singleton pattern!'
  else
    puts "Tests passed: #{tests_passed}/#{total_tests}"
    puts 'Keep working on the remaining exercises.'
  end
  puts '=' * 40
end

# Run the tests
run_tests
