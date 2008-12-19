require 'ostruct'
require 'forwardable'
require 'erb'
require 'yaml/encoding'

module YamlModel

  # Declare your own YAML-based model by inheriting from YamlModel::Base.
  #
  # Example: 
  #   class Book < YamlModel::Base
  #     fields :title, :author, :content
  #   end
  class Base
    extend Forwardable
    extend ApplicationHelper

    def initialize(attributes = {})
      @attributes = OpenStruct.new(attributes)
    end

    # Run this method to declare the fields of your model.
    # Example: 
    #   class Book < YamlModel::Base
    #     fields :title, :author, :content
    #   end
    def self.fields(*fields)
      fields.each do |field|
        define_method field do
          @attributes.__send__(field)
        end
      end
    end

    @@data_dir = "#{RAILS_ROOT}/data/"

    # Run this method to point to a different data directory than
    # RAILS_ROOT/data/ or to return the data_dir (if no argument is given)
    def self.data_dir(path = nil)
      @@data_dir = path unless path.blank?
      @@data_dir.ensure_trailing_slash
    end

    # Returns the full path to the data file.
    def self.data_file
      File.expand_path("#{data_dir}#{model_name.underscore}.yml")
    end

    # Creates the data file, if it doesn't exist yet.
    def self.setup
      File.open(data_file, 'a')
    end

    # Returns all records stored in the data file.
    def self.all
      yaml = render_erb_template(data_file)
      all = YAML.load(yaml) || []
      all.map { |item| self.new(item) }
    end

    # Not implemented yet.
    def self.create(options = {})
      fields.each do |field|
        options.to_yaml
      end
    end

    # Returns the first record.
    def self.first
      all.first
    end

    # Returns the last record.
    def self.last
      all.last
    end

    private

    def self.file_content(filename)
      File.read(filename)
    end

    def self.render_erb_template(filename)
      template = file_content(filename)
      ERB.new(template).result(binding)
    end
  end

end
