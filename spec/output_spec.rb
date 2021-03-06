require 'spec_helper'

RSpec.describe Output do
  let(:cfn_file) {File.open("#{File.dirname(__FILE__)}/samples/basic-amazon-redshift-cluster.json")}
  let(:cfn_hash) {YAML.load(cfn_file.read)}

  let(:name) {"ClusterEndpoint"}
  subject {described_class.new(name, cfn_hash['Outputs'][name])}

  it "has name ClusterEndpoint" do
    expect(subject.name).to eq "ClusterEndpoint"
  end

  # TODO: Create compare function for IntrinsicFunction
  it "has value of cluster endpoint and port" do
    expect(subject.value.instance_of? IntrinsicFunction).to be(true)
    expect(subject.value.name).to eq("Fn::Join")
    expect(subject.value.parameters.first).to eq ":"
  end
end
