
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name projetS4 -dir "/home/cyrille/projetS4/clock_vhdl/planAhead_run_5" -part xc3s100ecp132-4
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "principal.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {principal.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top principal $srcset
add_files [list {principal.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s100ecp132-4
