require 'delegate'

module Cassanity
  module Drivers
    # Internal: An intermediate driver for cassandra-ruby that merges the
    # behavior of the cluster and the session in one single object
    class CassandraDriver
      extend Forwardable
      def_delegators :session, :execute, :keyspace, :prepare, :execute_async

      def self.connect(cql_options = {})
        new(cql_options).tap(&:connect)
      end

      # cql_options: Options for constructing a Cassandra::Cluster
      def initialize(cql_options = {})
        @cql_options = cql_options
      end

      def connect
        @driver = Cassandra.cluster @cql_options
      end

      def use(keyspace)
        execute "USE #{keyspace}"
      end

      def session
        @session ||= @driver.connect
      end

      def disconnect
        @driver.close if @driver
      end

    end
  end
end
