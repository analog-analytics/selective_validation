Gem::Specification.new do |s|
  s.name = 'selective_validation'
  s.version = '0.0.1'
  s.date = '2012-08-10'
  s.summary = "Validate only what you want, when you want."
  s.description = "For ActiveRecord models, allows dynamically restricting validation to specified attributes. " \
                + "Originally developed to support multi-step registration with partial persistence (i.e. checkpoints).
                + That is, registration where the the fields for a model are split across multiple pages."
  s.authors = ["Daniel Zajic"]
  s.email = "danielzajic@gmail.com"

  s.add_runtime_dependency 'activemodel'
  s.add_runtime_dependency 'shoulda-context'

  s.files = Dir["{lib|test}/**/*.rb"]
  s.homepage = "http://github.com/dzajic/selective_validation"
end