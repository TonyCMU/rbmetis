RSpec::Matchers.define :be_wpart_of do |_expected_|
  match do |actual|
    npart = _expected_.size
    hist = [0]*npart
    actual.each do |i|
      hist[i] += 1
    end
    #p ["hist:",hist]
    nvertex = actual.size
    (0...npart).all? do |i|
      x = _expected_[i] * nvertex
      (x.round - hist[i]) <= 0.5
    end
  end
end
