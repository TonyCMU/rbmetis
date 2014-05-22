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

describe "Graph[ 0 - 1 - 2 - 3 ]" do
  before do
    @xadj = [0,1,3,5,6]
    @adjncy = [1, 0,2, 1,3, 2]
    #@vwgt = [ [1,0], [1,0], [0,1], [0,1] ]
    @vwgt = [ [1,0], [0,1], [1,0], [0,1] ]
  end

  %w[recursive kway].each do |tp|
    it "mc_part_graph vwgt=[ [1,0], [1,0], [0,1], [0,1] ]" do
      vwgt = [ [1,0], [1,0], [0,1], [0,1] ].flatten
      part_graph(tp, @xadj, @adjncy, 2, ncon:2, vwgt:vwgt).should be_wpart_of [0.5,0.5]
    end

    it "mc_part_graph vwgt=[ [1,0], [0,1], [1,0], [0,1] ]" do
      vwgt = [ [1,0], [0,1], [1,0], [0,1] ].flatten
      part_graph(tp, @xadj, @adjncy, 2, ncon:2, vwgt:vwgt).should be_wpart_of [0.5,0.5]
    end

    it "mc_part_graph vwgt=[ 1,0, 0,1, 1,0, 0,1 ]" do
      vwgt = [ 1,0, 0,1, 1,0, 0,1 ]
      part_graph(tp, @xadj, @adjncy, 2, ncon:2, vwgt:vwgt).should be_wpart_of [0.5,0.5]
    end
  end

end
