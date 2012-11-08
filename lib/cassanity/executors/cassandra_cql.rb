require 'cassandra-cql'
require 'cassanity/error'
require 'cassanity/argument_generators/keyspaces'
require 'cassanity/argument_generators/keyspace_create'
require 'cassanity/argument_generators/keyspace_drop'
require 'cassanity/argument_generators/keyspace_use'
require 'cassanity/argument_generators/column_family_create'
require 'cassanity/argument_generators/column_family_drop'
require 'cassanity/argument_generators/column_family_truncate'
require 'cassanity/argument_generators/column_family_select'
require 'cassanity/argument_generators/column_family_insert'
require 'cassanity/argument_generators/column_family_update'
require 'cassanity/argument_generators/column_family_delete'
require 'cassanity/argument_generators/column_family_alter'
require 'cassanity/argument_generators/index_create'
require 'cassanity/argument_generators/index_drop'
require 'cassanity/argument_generators/batch'
require 'cassanity/result_transformers/result_to_array'
require 'cassanity/result_transformers/mirror'

module Cassanity
  module Executors
    class CassandraCql

      # Private: Hash of commands to related argument generators.
      ArgumentGenerators = {
        keyspaces: Cassanity::ArgumentGenerators::Keyspaces.new,
        keyspace_create: Cassanity::ArgumentGenerators::KeyspaceCreate.new,
        keyspace_drop: Cassanity::ArgumentGenerators::KeyspaceDrop.new,
        keyspace_use: Cassanity::ArgumentGenerators::KeyspaceUse.new,
        column_family_create: Cassanity::ArgumentGenerators::ColumnFamilyCreate.new,
        column_family_drop: Cassanity::ArgumentGenerators::ColumnFamilyDrop.new,
        column_family_truncate: Cassanity::ArgumentGenerators::ColumnFamilyTruncate.new,
        column_family_select: Cassanity::ArgumentGenerators::ColumnFamilySelect.new,
        column_family_insert: Cassanity::ArgumentGenerators::ColumnFamilyInsert.new,
        column_family_update: Cassanity::ArgumentGenerators::ColumnFamilyUpdate.new,
        column_family_delete: Cassanity::ArgumentGenerators::ColumnFamilyDelete.new,
        column_family_alter: Cassanity::ArgumentGenerators::ColumnFamilyAlter.new,
        index_create: Cassanity::ArgumentGenerators::IndexCreate.new,
        index_drop: Cassanity::ArgumentGenerators::IndexDrop.new,
        batch: Cassanity::ArgumentGenerators::Batch.new,
      }

      # Private: Hash of commands to related result transformers.
      ResultTransformers = {
        column_family_select: Cassanity::ResultTransformers::ResultToArray.new,
        keyspaces: Cassanity::ResultTransformers::ResultToArray.new,
      }

      # Private: Default result transformer for commands that do not have one.
      Mirror = Cassanity::ResultTransformers::Mirror.new

      # Private
      attr_reader :client

      # Private
      attr_reader :argument_generators

      # Private
      attr_reader :result_transformers

      # Internal: Initializes a cassandra-cql based CQL executor.
      #
      # args - The Hash of arguments.
      #        :client - The CassandraCQL::Database connection instance.
      #        :logger - What to use to log the cql and such being executed.
      #        :argument_generators - A Hash where each key is a command name
      #                               and each value is the related argument
      #                               generator that responds to `call`
      #                               (optional).
      #        :result_transformers - A Hash where each key is a command name
      #                               and each value is the related result
      #                               transformer that responds to `call`
      #                               (optional).
      #
      # Examples
      #
      #   client = CassandraCQL::Database.new('host')
      #   Cassanity::Executors::CassandraCql.new(client: client)
      #
      def initialize(args = {})
        @client = args.fetch(:client)
        @logger = args[:logger]
        @argument_generators = args.fetch(:argument_generators) { ArgumentGenerators }
        @result_transformers = args.fetch(:result_transformers) { ResultTransformers }
      end

      # Internal: Execute a CQL query.
      #
      # args - One or more arguments to send to execute. First should always be
      #        String CQL query. The rest should be the bound variables if any
      #        are needed.
      #
      # Examples
      #
      #   call({
      #     command: :keyspaces,
      #   })
      #
      #   call({
      #     command: :keyspace_create,
      #     arguments: {name: 'analytics'},
      #   })
      #
      # Returns the result of execution.
      # Raises Cassanity::Error if anything goes wrong during execution.
      def call(args = {})
        command = args.fetch(:command)
        generator = @argument_generators.fetch(command)
        execute_arguments = generator.call(args[:arguments])

        if @logger
          @logger.debug { "#{self.class} executing #{execute_arguments.inspect}" }
        end

        result = @client.execute(*execute_arguments)

        transformer = @result_transformers.fetch(command) { Mirror }
        transformer.call(result)
      rescue KeyError
        raise Cassanity::UnknownCommand
      rescue Exception => e
        raise Cassanity::Error
      end
    end
  end
end
