#!/usr/bin/python3

import json
import os
import random

from slugify import slugify

random.seed(1)

# top 25 most-evolved tasks
# ---------- Forwarded message ---------
# From: Luis Zaman <zamanlh@umich.edu>
# Date: Wed, Apr 19, 2023, 15:55
# Subject: Fwd: Evolved Tasks
# To: Bhaskar Kumawat <kumawatb@umich.edu>
#
#
# Here's the 25-most evolved tasks (with the number of times each was executed over some large number of replicates at the end of evolution).
#
# ---------- Forwarded message ---------
# From: Luis Zaman <zamanlh@umich.edu>
# Date: Fri, Apr 3, 2020 at 10:21 AM
# Subject: Evolved Tasks
# To: Gyuri Barabas <dysordys@gmail.com>, <johanna.orsholm@gmail.com>
#
#
# NAND 140098025
# NOT 82163344
# ORN 77364042
# 3BO 38952992
# AND 21143295
# 3CI 18368660
# ANDN 14555194
# 3BZ 12006297
# 3AG 10622124
# OR 9970543
# 3CP 4667263
# 3BY 3694491
# NOR 2431521
# 3BS 1158777
# 3BA 880838
# 3CJ 352276
# 3AH 266981
# 3AQ 266376
# 3CN 221321
# 3CB 184648
# 3AX 140695
# 3AR 36095
# 3AO 29922
# 3CH 14704
# 3CC 14077
#
# Here’s a list of the 25 tasks that evolved most in order of their frequency of being executed overall in some small experiment. This should help give you a rough ordering of their “complexity”.

tasks = [
    "NAND nand",
    "NOT not",
    "ORN orn",
    "LOG3BO logic_3BO",
    "AND and",
    "LOG3CI logic_3CI",
    "ANDN andn",
    "LOG3BZ logic_3BZ",
    "LOG3AG logic_3AG",
    "OR or",
    "LOG3CP logic_3CP",
    "LOG3BY logic_3BY",
    "NOR nor",
    "LOG3BS logic_3BS",
    "LOG3BA logic_3BA",
    "LOG3CJ logic_3CJ",
    "LOG3AH logic_3AH",
    "LOG3AQ logic_3AQ",
    "LOG3CN logic_3CN",
    "LOG3CB logic_3CB",
    "LOG3AX logic_3AX",
    "LOG3AR logic_3AR",
    "LOG3AO logic_3AO",
    "LOG3CH logic_3CH",
    "LOG3CC logic_3CC",
]
os.makedirs("tasks", exist_ok=True)
for __ in range(40):
    sampled = random.sample(tasks, 3)
    with open(f"tasks/{slugify(' '.join(sampled))}", "w") as tasks_config_file:
        tasks_config_file.write("RESOURCE resECHO:inflow=125:outflow=0.10\n")
        for task in sampled:
            tasks_config_file.write(
                f"REACTION {task} process:resource=resECHO:value=1.0:type=pow:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1\n"
            )
