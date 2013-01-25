# Cassanity

Layer of goodness on top of cassandra-cql so you do not have to write CQL strings all over the place.

## Installation

Add this line to your application's Gemfile:

    gem 'cassanity'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cassanity

## Usage

```ruby
require 'cassanity'

# client does the heavy lifting of setting up a cassandra cql database instance,
# a cassanity executor for that database, and a cassanity connection
client = Cassanity::Client.new

# get keyspace instance
keyspace = client[:my_app]

# tell client to use keyspace for future queries
# this is optional as cassanity always sends the keyspace and column family name
# whenever they are needed
keyspace.use

# schema for apps column family
apps_schema = Cassanity::Schema.new({
  primary_key: :id,
  columns: {
    id: :text,
    name: :text,
    created_at: :timestamp,
  },
  with: {
    comment: 'For storing apps',
  }
})

# get instance of column family with name and schema set
apps = keyspace.column_family({
  name: :apps,
  schema: apps_schema,
})

# you can also just pass a hash for the schema
apps = keyspace.column_family({
  name: :apps,
  schema: {
    primary_key: :id,
    columns: {
      id: :text,
      name: :text,
      created_at: :timestamp,
    },
    with: {
      comment: 'For storing apps',
    }
  },
})

# create column family based on name and schema
apps.create

# insert row
apps.insert(data: {
  id: '1',
  name: 'GitHub.com',
  created_at: Time.now,
})

# update name for row
apps.update(set: {name: 'GitHub'}, where: {id: '1'})

# delete row
apps.delete(where: {id: '1'})

# truncate column family (remove all rows, still can add new stuff)
apps.truncate

# drop column family (no more inserting into it, it is gone)
apps.drop
```

You can also do a lot more. Here are a few more [examples](https://github.com/jnunemaker/cassanity/tree/master/examples):

* [Batch Operations](https://github.com/jnunemaker/cassanity/tree/master/examples/batch.rb)
* [Counters](https://github.com/jnunemaker/cassanity/tree/master/examples/counters.rb)
* [Keyspaces](https://github.com/jnunemaker/cassanity/tree/master/examples/keyspaces.rb)
* [Column Families](https://github.com/jnunemaker/cassanity/tree/master/examples/column_families.rb)
* [Select a Range](https://github.com/jnunemaker/cassanity/tree/master/examples/select_range.rb)

## Instrumentation

Cassanity comes with a log subscriber and automatic metriks instrumentation. By
default these work with ActiveSupport::Notifications, but only require the
pieces of ActiveSupport that are needed and only do so if you actually attempt
to require the instrumentation files listed below.

If you use any of this instrumentation, you will need to have activesupport in
your Gemfile.

To use the log subscriber:

```ruby
require 'cassanity/instrumentation/log_subscriber'
```

To use the metriks instrumentation:

```ruby
require 'cassanity/instrumentation/metriks'
```

## Compatibility

* Ruby 1.9.3

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
