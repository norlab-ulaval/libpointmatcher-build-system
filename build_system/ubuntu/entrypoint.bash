#!/bin/bash

source ./function_library/prompt_utilities.bash

echo -e "${MSG_DIMMED_FORMAT}"
draw_horizontal_line_across_the_terminal_window '+'
echo -e 'Starting entrypoint.bash' '+'

pwd
tree -L 3

echo -e "${MSG_END_FORMAT}"
echo -e "Executing CMD › ${MSG_DIMMED_FORMAT}$*"
draw_horizontal_line_across_the_terminal_window '+'
echo -e "${MSG_END_FORMAT}"

# ====Continue=====================================================================================================

exec "${@}"

