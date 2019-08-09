require 'extlib'
class CloudFormation

  ELEMENTS = [
    :parameters,
    :resources,
    :conditions,
    :outputs,
    :mappings,
    :rules,
    :metadata,
    :description,
    :aws_template_format_version
  ]

  attr_reader(*ELEMENTS)

  def initialize(cfn_string)
    if json_text?(cfn_string)
      raise ParserError.new('Invalid JSON!') unless valid_json?(cfn_string)
      cfn_hash = JSON.parse(cfn_string)
    else
      cfn_hash = YAML.load(cfn_string)
    end    
    #puts cfn_hash['Metadata']
    ELEMENTS.each do |e|
      key  = e.to_s.camel_case
      if key =~ /^Aws/
        key = key.sub(/^Aws/, "AWS")
      end

      if cfn_hash[key]
        attr = parse_element(e, cfn_hash[key])
        instance_variable_set("@" + e.to_s, attr)
      end
    end
  end

  private
  def json_text?(cfn_string)
    first_character = cfn_string.gsub(/\s/, '').split('').first
    matches = cfn_string.scan(/\{[^}]*\}/)
    first_character == '{' && !matches.empty?
  end

  def valid_json?(cfn_string)
      JSON.parse(cfn_string)
      return true
  rescue JSON::ParserError => error
    return false
  end
    
  def parse_element(elm_name, json)
    function = parser(elm_name)
    send(function, elm_name, json)
  end

  def parser(name)
    case name
    when :description
      :simple_parser
    when :aws_template_format_version
      :simple_parser
    else
      :complex_parser
    end
  end

  def simple_parser(name, json)
    json
  end

  def complex_parser(name, json)
    elms = []
    case name
    when :metadata
      json.each_pair { |k, v| elms << Metadata.new(k, v) }
    when :rules
      json.each_pair { |k, v| elms << Rules.new(k, v) }
    when :parameters
      json.each_pair { |k, v| elms << Parameter.new(k, v) }
    when :resources
      json.each_pair { |k, v| elms << Resource.new(k, v) }
    when :outputs
      json.each_pair { |k, v| elms << Output.new(k, v) }
    when :mappings
      json.each_pair { |k, v| elms << Mapping.new(k, v) }
    when :conditions
      json.each_pair { |k, v| elms << Condition.new(k, v) }
    end
    return elms
  end
end
