import re

a = "==== 3 failed, 2792 passed, 39 skipped, 2 deselected, 1 xfailed, 73 warnings in 200.43s (0:03:20) ==="

if re.match(r'^\=.*\=$', a):
    print("matched.")
else:
    print("not matched.")

