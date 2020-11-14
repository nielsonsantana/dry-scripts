#! python3
# Releaser Script
import os
from shutil import copyfile
import filecmp

SCRIPTS = [
    'deploy-cloudrun.sh'
]

INITIAL_RELEASE = '0.1.0'

DIR_PATH = os.path.dirname(os.path.realpath(__file__))

def get_last_release(path):
    files = sorted(os.listdir(path), reverse=True)
    for file_name in files:
        if not 'latest' in file_name:
            version_extension = file_name.split('-')[-1]
            return '.'.join(version_extension.split('.')[:-1])

    return None

def get_next_release(current_release):
    if not current_release:
        return INITIAL_RELEASE

    splitted = current_release.split('.')
    splitted[1] = str(int(splitted[1]) + 1)
    return '.'.join(splitted)

for script in SCRIPTS:
    script_name = ''.join(script.split('.')[:-1])
    extension = script.split('.')[-1]

    script_path = os.path.join(DIR_PATH, script)

    latest_script = f'{script_name}-latest.{extension}'
    release_script_dir = os.path.join(DIR_PATH, f'releases/{script_name}/')
    latest_script_path = os.path.join(release_script_dir, latest_script)

    if not os.path.exists(latest_script_path):
        copyfile(script_path, latest_script_path)

    if filecmp.cmp(script_path, latest_script_path, shallow=False) is False:
        copyfile(script_path, latest_script_path)
        current_release = get_last_release(release_script_dir)
        next_release = get_next_release(current_release)
        # print('')
        # value = print(f"Please enter a release [{next_release}]\n")
        # value = input(f"Release: [{next_release}]:")
        versioned_release = f'{release_script_dir}/{script_name}-{next_release}.{extension}'
        copyfile(script_path, versioned_release)

