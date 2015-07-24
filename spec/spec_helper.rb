
RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
end

def puts! args, label=""
  puts "+++ +++ #{label}"
  puts args.inspect
end
