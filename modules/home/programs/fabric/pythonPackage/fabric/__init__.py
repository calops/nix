import importlib.util
import sys
import os

spec = importlib.util.spec_from_file_location(
    "fabric.bar", f"{os.getenv('XDG_CONFIG_HOME')}/fabric/bar/init.py"
)

assert spec is not None
fabric_bar = importlib.util.module_from_spec(spec)
sys.modules["fabric.bar"] = fabric_bar

assert spec.loader is not None
spec.loader.exec_module(fabric_bar)

fabric_bar.run()
