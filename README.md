# RbMetis

FFI wrapper of [METIS graph partitioning library](http://glaros.dtc.umn.edu/gkhome/metis/metis/overview)

* [GitHub](https://github.com/masa16/rbmetis)
* [RubyGems](https://rubygems.org/gems/rbmetis)
* [Class Documentation](http://rubydoc.info/gems/rbmetis/frames/)

## Requirement

* [METIS version 5.1.0](http://glaros.dtc.umn.edu/gkhome/metis/metis/overview)
* [Ruby-FFI](https://rubygems.org/gems/ffi)

## Installation

Install from RubyGems:

    $ gem install rbmetis

Or download source tree from [releases](https://github.com/masa16/rbmetis/releases),
cd to tree top and run:

    $ ruby setup.rb

### Installation Option

* Required METIS files:
  * C header: metis.h
  * Library: libmetis.so or libmetis.a

* option for extconf.rb

        --with-metis-dir=path
        --with-metis-include=path
        --with-metis-lib=path

* How to pass option to extconf.rb

        $ gem install rbmetis -- --with-metis-dir=/opt/metis
        $ ruby setup.rb -- --with-metis-dir=/opt/metis

## Usage

Loading RbMeits:

    require 'rbmetis'

Currently implemented APIs:

    RbMetis.part_graph_recursive(xadj, adjncy, npart, opts = {})
    RbMetis.part_graph_kway(xadj, adjncy, npart, opts = {})
    RbMetis.default_options

See also [RbMeits API document](http://rubydoc.info/gems/rbmetis/frames)
and [METIS manual](http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/manual.pdf)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rbmetis/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
