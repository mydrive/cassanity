# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

rspec_options = {
  all_after_pass: false,
  all_on_start: false,
  keep_failed: false
}

guard 'rspec', rspec_options do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| [
    "spec/unit/#{m[1]}_spec.rb",
    "spec/integration/#{m[1]}_spec.rb",
  ] }
  watch('spec/helper.rb')  { "spec" }
end
