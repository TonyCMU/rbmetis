require "rspec"
dir = File.dirname(File.expand_path(__FILE__))
require dir+"/matcher.rb"
require dir+"/../lib/rbmetis"

def part_graph(type, *args)
  case type.to_s
  when /^r/i
    RbMetis.part_graph_recursive(*args)
  when /^k/i
    RbMetis.part_graph_kway(*args)
  end
end

describe "RbMetis.default_options" do
  it do
    RbMetis.default_options.should eq [-1]*40
  end
end

describe "Graph[ 0 - 1 - 2 - 3 ]" do
  before do
    @xadj = [0,1,3,5,6]
    @adjncy = [1, 0,2, 1,3, 2]
  end

  %w[recursive kway].each do |tp|
    it "part_graph_#{tp} 2:2" do
      part_graph(tp, @xadj, @adjncy, 2, tpwgts:[0.5,0.5]).should be_wpart_of [0.5,0.5]
    end
  end

  %w[recursive].each do |tp|
    it "part_graph_#{tp} 3:1" do
      part_graph(tp, @xadj, @adjncy, 2, tpwgts:[0.75,0.25]).should be_wpart_of [0.75,0.25]
    end

    it "part_graph_#{tp} 1:3" do
      part_graph(tp, @xadj, @adjncy, 2, tpwgts:[0.25,0.75]).should be_wpart_of [0.25,0.75]
    end

    it "part_graph_#{tp} 1:1:2" do
      part_graph(tp, @xadj, @adjncy, 3, tpwgts:[0.25,0.25,0.5]).should be_wpart_of [0.25,0.25,0.5]
    end
  end
end


describe "Graph[ 0 - 1 - 2 - 3 - 4 ]" do
  before do
    @xadj = [0,1,3,5,7,8]
    @adjncy = [1, 0,2, 1,3, 2,4, 3]
  end

  %w[recursive].each do |tp|
    it "part_graph_#{tp} 1:4" do
      part_graph(tp, @xadj, @adjncy, 2, tpwgts:[0.2,0.8]).should be_wpart_of [0.2,0.8]
    end

    it "part_graph_#{tp} 2:3" do
      part_graph(tp, @xadj, @adjncy, 2, tpwgts:[0.4,0.6]).should be_wpart_of [0.4,0.6]
    end

    it "part_graph_#{tp} 3:2" do
      part_graph(tp, @xadj, @adjncy, 2, tpwgts:[0.6,0.4]).should be_wpart_of [0.6,0.4]
    end

    it "part_graph_#{tp} 4:1" do
      part_graph(tp, @xadj, @adjncy, 2, tpwgts:[0.8,0.2]).should be_wpart_of [0.8,0.2]
    end
  end
end
