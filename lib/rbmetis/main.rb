module RbMetis
  class MetisError < StandardError
  end

  #  Returned normally
  METIS_OK              =  1
  #  Returned due to erroneous inputs and/or options
  METIS_ERROR_INPUT     = -2
  #  Returned due to insufficient memory
  METIS_ERROR_MEMORY    = -3
  #  Some other errors
  METIS_ERROR           = -4

  NOPTIONS = 40

  #/*! Operation type codes */
  OP_PMETIS,
  OP_KMETIS,
  OP_OMETIS = (0..2).to_a

  #/*! Options codes (i.e., options[]) */
  OPTION_PTYPE,
  OPTION_OBJTYPE,
  OPTION_CTYPE,
  OPTION_IPTYPE,
  OPTION_RTYPE,
  OPTION_DBGLVL,
  OPTION_NITER,
  OPTION_NCUTS,
  OPTION_SEED,
  OPTION_NO2HOP,
  OPTION_MINCONN,
  OPTION_CONTIG,
  OPTION_COMPRESS,
  OPTION_CCORDER,
  OPTION_PFACTOR,
  OPTION_NSEPS,
  OPTION_UFACTOR,
  OPTION_NUMBERING,
  #/* Used for command-line parameter purposes */
  OPTION_HELP,
  OPTION_TPWGTS,
  OPTION_NCOMMON,
  OPTION_NOOUTPUT,
  OPTION_BALANCE,
  OPTION_GTYPE,
  OPTION_UBVEC = (0..25).to_a

  # /*! Partitioning Schemes */
  PTYPE_RB,
  PTYPE_KWAY = (0..1).to_a

  # /*! Graph types for meshes */
  GTYPE_DUAL,
  GTYPE_NODAL = (0..1).to_a

  # /*! Coarsening Schemes */
  CTYPE_RM,
  CTYPE_SHEM = (0..1).to_a

  # /*! Initial partitioning schemes */
  IPTYPE_GROW,
  IPTYPE_RANDOM,
  IPTYPE_EDGE,
  IPTYPE_NODE,
  IPTYPE_METISRB = (0..4).to_a

  # /*! Refinement schemes */
  RTYPE_FM,
  RTYPE_GREEDY,
  RTYPE_SEP2SIDED,
  RTYPE_SEP1SIDED = (0..3).to_a

  # /*! Debug Levels */
  DBG_INFO       = 1
  DBG_TIME       = 2
  DBG_COARSEN    = 4
  DBG_REFINE     = 8
  DBG_IPART      = 16
  DBG_MOVEINFO   = 32
  DBG_SEPINFO    = 64
  DBG_CONNINFO   = 128
  DBG_CONTIGINFO = 256
  DBG_MEMORY     = 2048

  # /* Types of objectives */
  OBJTYPE_CUT,
  OBJTYPE_VOL,
  OBJTYPE_NODE = (0..2).to_a

  # @visibility private
  module Lib
    def part_graph_preprocess(xadj_arg, adjncy_arg, np, args={})
      nv = xadj_arg.size - 1

      # The number of vertices in the graph.
      nvtxs  = alloc_idx(nv)
      # The adjacency structure of the graph as described in Section 5.5.
      xadj   = alloc_idx_ary(xadj_arg)
      adjncy = alloc_idx_ary(adjncy_arg)
      # The number of parts to partition the graph.
      nparts = alloc_idx(np)

      ncon = check_idx(args, :ncon, 1)
      nc = read_idx(ncon)

      # The weights of the vertices as described in Section 5.5.
      vwgt = check_idx_array(args, :vwgt, nv*nc, "nvtxs*ncon")

      # The number of balancing constraints. It should be at least 1.
      ncon = alloc_idx(nc)

      # The size of the vertices for computing the total communication
      # volume as described in Section 5.7.
      vsize = check_idx(args, :vsize, 1)

      # The weights of the edges as described in Section 5.5.
      adjwgt = check_idx_array(args, :adjwgt, adjncy_arg.size, "size of adjncy")

      # This is an array of size nparts*ncon that specifies the desired
      # weight for each partition and constraint.
      # The target partition weight for the ith partition and jth
      # constraint is specified at tpwgts[i*ncon+j]
      # For each constraint, the sum of the tpwgts[] entries must be 1.0.
      tpwgts = check_real_array(args, :tpwgts, np*nc, "nparts*ncon")

      # This is an array of size ncon that specifies the allowed load
      # imbalance tolerance for each constraint.
      # For the ith partition and jth constraint the allowed weight is
      # the ubvec[j]*tpwgts[i*ncon+j] fraction of the jth’s constraint
      # total weight. The load imbalances must be greater than 1.0.
      # A NULL value can be passed indicating that the load imbalance
      # tolerance for each constraint should be 1.001 (for ncon=1) or
      # 1.01 (for ncon>1).
      ubvec = check_real_array(args, :ubvec, nc, "ncon")

      # This is the array of options as described in Section 5.4.
      options = check_idx_array(args, :options, 40)

      # Upon successful completion, this variable stores the edge-cut or
      # the total communication volume of the partitioning solution. The
      # value returned depends on the partitioning’s objective
      # function.
      objval = alloc_idx(0)

      # This is a vector of size nvtxs that upon successful completion
      # stores the partition vector of the graph. The numbering of this
      # vector starts from either 0 or 1, depending on the value of
      # options[METIS OPTION NUMBERING].
      part = alloc_idx_ary([0]*nv)

      return [nvtxs, ncon, xadj, adjncy, vwgt, vsize, adjwgt, nparts,
              tpwgts, ubvec, options, objval, part]
    end
    module_function :part_graph_preprocess
  end

  # partition a graph into k parts using multilevel recursive bisection.
  # @overload part_graph_recursive(xadj, adjncy, npart, opts={})
  # @param  [Array] xadj adjacency structure of the graph
  # @param  [Array] adjncy adjacency structure of the graph
  # @param  [Integer] npart the number of partitions
  # @option opts [Array] :vwgt (nil) The weights of the vertices.
  # @option opts [Array] :ncon (1) The number of balancing
  #   constraints. It should be at least 1.
  # @option opts [Array] :vsize (nil) The size of the vertices for
  #   computing the total communication volume.
  # @option opts [Array] :adjwgt (nil) The weights of the edges.
  # @option opts [Array] :tpwgts (nil) an array of size nparts*ncon
  #   that specifies the desired weight for each partition and
  #   constraint.  The target partition weight for the ith partition
  #   and jth constraint is specified at tpwgts[i*ncon+j] For each
  #   constraint, the sum of the tpwgts[] entries must be 1.0.
  # @option opts [Array] :ubvec (nil) an array of size ncon that
  #   specifies the allowed load imbalance tolerance for each
  #   constraint.  For the ith partition and jth constraint the allowed
  #   weight is the ubvec[j]*tpwgts[i*ncon+j] fraction of the jth’s
  #   constraint total weight. The load imbalances must be greater than
  #   1.0.  A NULL value can be passed indicating that the load
  #   imbalance tolerance for each constraint should be 1.001 (for
  #   ncon=1) or 1.01 (for ncon>1).
  # @option opts [Array] :options (nil) the array of options.
  #   The following options are valid for METIS PartGraphRecursive:
  #   METIS_OPTION_CTYPE, METIS_OPTION_IPTYPE, METIS_OPTION_RTYPE,
  #   METIS_OPTION_NO2HOP, METIS_OPTION_NCUTS, METIS_OPTION_NITER,
  #   METIS_OPTION_SEED, METIS_OPTION_UFACTOR, METIS_OPTION_NUMBERING,
  #   METIS_OPTION_DBGLVL
  # @return [Array] an array that stores the partition of the graph.
  # @raise  [RbMetis::MetisError]
  def part_graph_recursive(xadj, adjncy, npart, opts={})
    # args = [ nvtxs, ncon, xadj, adjncy, vwgt, vsize, adjwgt, nparts,
    #          tpwgts, ubvec, options, objval, part ]
    args = Lib.part_graph_preprocess(xadj, adjncy, npart, opts)
    retval = Lib.METIS_PartGraphRecursive(*args)
    Lib.postprocess(retval)
    part = args.last
    nv = xadj.size - 1
    #p read_idx(objval)
    return Lib.read_idx_ary(part,nv)
  end
  module_function :part_graph_recursive


  # partition a graph into k parts using multilevel k-way partitioning.
  # @overload part_graph_kway(xadj, adjncy, npart, opts={})
  # @param  [Array] xadj adjacency structure of the graph
  # @param  [Array] adjncy adjacency structure of the graph
  # @param  [Integer] npart the number of partitions
  # @option opts [Array] :vwgt (nil) The weights of the vertices.
  # @option opts [Array] :ncon (1) The number of balancing
  #   constraints. It should be at least 1.
  # @option opts [Array] :vsize (nil) The size of the vertices for
  #   computing the total communication volume.
  # @option opts [Array] :adjwgt (nil) The weights of the edges.
  # @option opts [Array] :tpwgts (nil) an array of size nparts*ncon
  #   that specifies the desired weight for each partition and
  #   constraint.  The target partition weight for the ith partition
  #   and jth constraint is specified at tpwgts[i*ncon+j] For each
  #   constraint, the sum of the tpwgts[] entries must be 1.0.
  # @option opts [Array] :ubvec (nil) an array of size ncon that
  #   specifies the allowed load imbalance tolerance for each
  #   constraint.  For the ith partition and jth constraint the allowed
  #   weight is the ubvec[j]*tpwgts[i*ncon+j] fraction of the jth’s
  #   constraint total weight. The load imbalances must be greater than
  #   1.0.  A NULL value can be passed indicating that the load
  #   imbalance tolerance for each constraint should be 1.001 (for
  #   ncon=1) or 1.01 (for ncon>1).
  # @option opts [Array] :options (nil) the array of options.
  #   The following options are valid for METIS PartGraphKway:
  #   METIS_OPTION_OBJTYPE, METIS_OPTION_CTYPE, METIS_OPTION_IPTYPE,
  #   METIS_OPTION_RTYPE, METIS_OPTION_NO2HOP, METIS_OPTION_NCUTS,
  #   METIS_OPTION_NITER, METIS_OPTION_UFACTOR, METIS_OPTION_MINCONN,
  #   METIS_OPTION_CONTIG, METIS_OPTION_SEED, METIS_OPTION_NUMBERING,
  #   METIS_OPTION_DBGLVL
  # @return [Array] an array that stores the partition of the graph.
  # @raise  [RbMetis::MetisError]
  def part_graph_kway(xadj, adjncy, npart, opts={})
    # args = [ nvtxs, ncon, xadj, adjncy, vwgt, vsize, adjwgt, nparts,
    #          tpwgts, ubvec, options, objval, part ]
    args = Lib.part_graph_preprocess(xadj, adjncy, npart, opts)
    retval = Lib.METIS_PartGraphKway(*args)
    Lib.postprocess(retval)
    part = args.last
    nv = xadj.size - 1
    #p read_idx(objval)
    return Lib.read_idx_ary(part,nv)
  end
  module_function :part_graph_kway

  # Initializes the options array into its default values.
  # @return [Array] The array of options that will be initialized.
  # It’s size is METIS_NOPTIONS.
  def default_options
    options = Lib.alloc_idx_ary([0]*40)
    Lib.METIS_SetDefaultOptions(options)
    Lib.read_idx_ary(options,40)
  end
  module_function :default_options
end
