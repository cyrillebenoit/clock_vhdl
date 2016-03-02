
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name projetS4 -dir "/home/cyrille/projetS4/clock_vhdl/planAhead_run_3" -part xc3s100ecp132-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/cyrille/projetS4/clock_vhdl/principal.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/cyrille/projetS4/clock_vhdl} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "principal.ucf" [current_fileset -constrset]
add_files [list {principal.ucf}] -fileset [get_property constrset [current_run]]
link_design
