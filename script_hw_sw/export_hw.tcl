
## wrap the top files
make_wrapper -files [get_files /home/arun/Desktop/work/design_1.0/mb_dma_hls/hw_sw/mb_dma_design_1_0.srcs/sources_1/bd/mb_dma_simple_lb/mb_dma_simple_lb.bd] -top
## launch generate bitstreams.
launch_runs impl_1 -to_step write_bitstream -jobs 4
## copy the hdf files to the sdk folder.
file copy -force /home/arun/Desktop/work/design_1.0/mb_dma_hls/hw_sw/mb_dma_design_1_0.runs/impl_1/mb_dma_simple_lb_wrapper.sysdef /home/arun/Desktop/work/design_1.0/mb_dma_hls/sw_src/hdf/mb_dma_simple_lb_wrapper.hdf
## launch sdk.
launch_sdk -workspace /home/arun/Desktop/work/design_1.0/mb_dma_hls/sw_src -hwspec /home/arun/Desktop/work/design_1.0/mb_dma_hls/sw_src/hdf/mb_dma_simple_lb_wrapper.hdf
