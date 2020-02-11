#!/usr/bin/python
# From https://old.reddit.com/r/i3wm/comments/8njtwg/anyone_need_to_quickly_switch_to_the_nearest/dzwktps/

import json, subprocess

output = subprocess.check_output(['i3-msg', '-t', 'get_workspaces'])
workspaces = json.loads(output)

next_num = next(i for i in range(1, 100) if not [ws for ws in workspaces if ws['num'] == i])

subprocess.call(['i3-msg', 'workspace number %i' % next_num])
