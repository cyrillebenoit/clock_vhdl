
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name projetS4 -dir "/home/cyrille/projetS4/clock_vhdl/planAhead_run_2" -part xc3s100ecp132-4
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "/home/cyrille/projetS4/clock_vhdl/principal.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/cyrille/projetS4/clock_vhdl} }
set_property target_constrs_file "principal.ucf" [current_fileset -constrset]
add_files [list {principal.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "/home/cyrille/projetS4/clock_vhdl/principal.ncd"
if {[catch {read_twx -name results_1 -file "/home/cyrille/projetS4/clock_vhdl/principal.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"/home/cyrille/projetS4/clock_vhdl/principal.twx\": $eInfo"
}
