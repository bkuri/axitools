#!/usr/bin/env python3
"""
Shared utilities for AxiTools scripts
"""

import os
import tomllib
from typing import Dict, Tuple, Optional


def find_config(name: str) -> Tuple[Dict, Optional[str]]:
    """
    Find configuration file with proper hierarchy:
    1. Environment variable (AXQ_CONFIG, AXR_CONFIG)
    2. User config (~/.config/{name}.toml)  
    3. System config (/etc/axitools/{name}.toml)
    
    Returns:
        tuple: (config_dict, config_file_path)
    """
    env_var = os.getenv(name.upper() + '_CONFIG')
    candidates = []
    
    if env_var:
        candidates.append(env_var)
    
    user_config = os.path.expanduser(f'~/.config/{name}.toml')
    system_config = f'/etc/axitools/{name}.toml'
    candidates.extend([user_config, system_config])
    
    for path in candidates:
        if path and os.path.exists(path):
            try:
                with open(path, 'rb') as f:
                    return tomllib.load(f), path
            except Exception as e:
                print(f"Warning: Failed to load config from {path}: {e}", file=sys.stderr)
                continue
    
    return {}, None


def load_config(name: str) -> Dict:
    """
    Convenience wrapper for find_config that returns just the config dict
    """
    config, path = find_config(name)
    if path:
        print(f"Using config: {path}", file=sys.stderr)
    return config