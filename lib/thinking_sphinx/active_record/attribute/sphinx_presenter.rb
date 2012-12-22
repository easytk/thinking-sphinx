class ThinkingSphinx::ActiveRecord::Attribute::SphinxPresenter
  SPHINX_TYPES = {
    :integer   => :uint,
    :boolean   => :bool,
    :timestamp => :timestamp,
    :float     => :float,
    :string    => :string,
    :bigint    => :bigint,
    :ordinal   => :str2ordinal,
    :wordcount => :str2wordcount
  }

  def initialize(attribute, source)
    @attribute, @source = attribute, source
  end

  def collection_type
    @attribute.multi? ? :multi : sphinx_type
  end

  def declaration
    if @attribute.multi?
      multi_declaration
    else
      @attribute.name
    end
  end

  def sphinx_type
    SPHINX_TYPES[@attribute.type]
  end

  private

  def multi_declaration
    case @attribute.source_type
    when :query
      "#{sphinx_type} #{@attribute.name} from query; #{query.to_sql}"
    when :ranged_query
      "#{sphinx_type} #{@attribute.name} from ranged-query; #{query.to_sql true}; #{query.range_sql}"
    else
      "#{sphinx_type} #{@attribute.name} from field"
    end
  end

  def query
    @query ||= ThinkingSphinx::ActiveRecord::Attribute::Query.new(
      @attribute, @source
    )
  end
end