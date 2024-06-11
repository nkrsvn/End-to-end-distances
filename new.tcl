#set outfile PES_185_end_to_end.dat
set polymer_path ../PES-185-50/PES-185-50/Cooling/
set script_path ../../../../End-to-end/   ;#relative to Cool_p_i folder
# Set the number of polymer chains
set N 8
set index_list_head {2659 5359 5455 10763 10856 16167 16260 18962}
set index_list_tail {51 2752 8061 8152 13465 13561 18869 21573}

# List to store data
set results {}

set pressures {26000_ 38000_ 50000_}
foreach p_ $pressures {
    for {set i 1} {$i < 4} {incr i} {
        cd $polymer_path
        cd Cool_${p_}${i}/
        topo readlammpsdata cooling_${p_}${i}.data full

        # List to store end-to-end distances for all chains in the current frame
        set end_to_end_distances {}

        # Output the results
        cd $script_path
        set outfile [open PES_185_end_to_end.dat a]

        # Iterate over all chains
        for {set chain 0} {$chain < $N} {incr chain} {
            # Get the indices for the head and tail of the current chain
            set head [lindex $index_list_head $chain]
            set tail [lindex $index_list_tail $chain]

            # Create a selection for the first and last atom of the current chain
            set sel_first [atomselect top "index $head"]
            set sel_last [atomselect top "index $tail"]

            # Check if selections are valid
            if {[$sel_first num] > 0 && [$sel_last num] > 0} {
                # Get the coordinates of the first and last atom
                set coord_first [lindex [$sel_first get {x y z}] 0]
                set coord_last [lindex [$sel_last get {x y z}] 0]

                # Calculate the distance between the first and last atom
                set distance [veclength [vecsub $coord_first $coord_last]]

                # Append the end-to-end distance to the list
                lappend end_to_end_distances $distance
            } else {
                # If selections are not valid, append a NaN value
                lappend end_to_end_distances "NaN"
            }

            # Delete the selections
            $sel_first delete
            $sel_last delete
        }

        # Create a string with p_, i, and the distances separated by tabs
        set result_str "$p_\t$i\t[join $end_to_end_distances "\t"]\n"

        # Append the result string to the results list
        lappend results $result_str
    }
}

# Write all results to the output file
set outfile [open "PES_185_end_to_end.dat" "a"]
foreach result $results {
    puts $outfile $result
}
close $outfile

# Delete all molecules
set id [molinfo list]
foreach id $id {
    mol delete $id
}