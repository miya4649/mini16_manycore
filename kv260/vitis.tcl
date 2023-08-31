platform create -name {mini16_manycore_pf} -hw {project_1/top.xsa} -no-boot-bsp
platform write
domain create -name {standalone_psu_cortexa53_0} -os {standalone} -proc {psu_cortexa53_0} -runtime {cpp} -arch {64-bit} -support-app {empty_application}
platform generate -domains 
platform active {mini16_manycore_pf}
platform generate -quick
app create -name {mini16_manycore_app} -platform {mini16_manycore_pf} -domain {standalone_psu_cortexa53_0} -template {Empty Application(C)}
importsources -name {mini16_manycore_app} -path {vitis_src}
app build -name {mini16_manycore_app}
