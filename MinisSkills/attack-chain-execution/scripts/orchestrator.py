#!/usr/bin/env python3
"""
Attack Chain Orchestrator
Coordinates multi-phase attack workflows
"""

import subprocess
import json
import socket
import time
from typing import Dict, List, Any, Optional
from datetime import datetime
from dataclasses import dataclass, asdict
from enum import Enum
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')
logger = logging.getLogger(__name__)


class PhaseStatus(Enum):
    COMPLETED = "completed"
    FAILED = "failed"


@dataclass
class PhaseResult:
    phase_number: int
    phase_name: str
    status: str
    findings: List[Dict[str, Any]]
    duration_seconds: float
    error: Optional[str] = None


class AttackChainOrchestrator:
    """Coordinates multi-phase attack chains"""

    PHASES = [
        {"number": 1, "name": "intelligence", "description": "Reconnaissance and target profiling"},
        {"number": 2, "name": "discovery", "description": "Vulnerability identification"},
        {"number": 3, "name": "exploitation", "description": "Exploitation attempts"},
        {"number": 4, "name": "persistence", "description": "Post-exploitation persistence"},
        {"number": 5, "name": "cleanup", "description": "Evidence removal"},
    ]

    COMMON_SERVICES = {
        21: "FTP", 22: "SSH", 80: "HTTP", 443: "HTTPS", 3306: "MySQL", 5432: "PostgreSQL"
    }

    def __init__(self, timeout: int = 300, force: bool = False):
        self.timeout = timeout
        self.force = force
        self.phases_results: List[PhaseResult] = []
        self.start_time: Optional[datetime] = None
        logger.info(f"Orchestrator initialized (timeout: {timeout}s, force: {force})")

    def execute_chain(self, target: str, phases_to_run: Optional[List[int]] = None) -> Dict[str, Any]:
        """Execute complete attack chain"""
        if phases_to_run is None:
            phases_to_run = [1, 2, 3, 4, 5]
        
        self.start_time = datetime.utcnow()
        logger.info(f"Starting attack chain against {target}")
        
        try:
            for phase_config in self.PHASES:
                phase_num = phase_config["number"]
                if phase_num not in phases_to_run:
                    continue
                
                logger.info(f"[PHASE {phase_num}] {phase_config['description']}")
                phase_result = self._execute_phase(phase_num, target)
                self.phases_results.append(phase_result)
                
                if phase_result.status == PhaseStatus.FAILED.value and phase_num < 4:
                    logger.warning(f"Phase {phase_num} failed, continuing...")
            
            return self._generate_report(target)
        except Exception as e:
            logger.error(f"Attack chain failed: {e}", exc_info=True)
            return {"skill": "attack-chain-execution", "status": "failed", "error": str(e)}

    def _execute_phase(self, phase_num: int, target: str) -> PhaseResult:
        """Execute single phase"""
        phase_config = next(p for p in self.PHASES if p["number"] == phase_num)
        phase_name = phase_config["name"]
        start = time.time()
        
        try:
            findings = []
            if phase_num == 1:
                findings = self._phase_intelligence(target)
            elif phase_num == 2:
                findings = self._phase_discovery(target)
            elif phase_num in [3, 4, 5]:
                findings = [{"status": "requires_force_mode" if not self.force else "executed"}]
            
            duration = time.time() - start
            return PhaseResult(phase_num, phase_name, PhaseStatus.COMPLETED.value, findings, round(duration, 2))
        except Exception as e:
            return PhaseResult(phase_num, phase_name, PhaseStatus.FAILED.value, [], round(time.time() - start, 2), str(e))

    def _phase_intelligence(self, target: str) -> List[Dict]:
        """Phase 1: Reconnaissance"""
        findings = []
        try:
            ip = socket.gethostbyname(target)
            findings.append({"type": "dns_resolution", "hostname": target, "ip": ip})
        except:
            pass
        
        for port in [21, 22, 80, 443, 3306, 5432]:
            try:
                result = subprocess.run(
                    f"timeout 2 bash -c 'echo >/dev/tcp/{target}/{port}' 2>/dev/null && echo open || echo closed",
                    shell=True,
                    capture_output=True,
                    text=True,
                    timeout=3
                )
                if "open" in result.stdout:
                    findings.append({
                        "type": "open_port",
                        "port": port,
                        "service": self.COMMON_SERVICES.get(port, "Unknown")
                    })
            except:
                pass
        
        return findings

    def _phase_discovery(self, target: str) -> List[Dict]:
        """Phase 2: Vulnerability discovery"""
        findings = []
        try:
            result = subprocess.run(
                "find / -perm -4000 -type f 2>/dev/null | head -10",
                shell=True,
                capture_output=True,
                text=True,
                timeout=30
            )
            suid = [b for b in result.stdout.strip().split("\n") if b]
            if suid:
                findings.append({"type": "suid_binaries", "count": len(suid), "examples": suid[:3]})
        except:
            pass
        
        return findings

    def _generate_report(self, target: str) -> Dict[str, Any]:
        """Generate final report"""
        end_time = datetime.utcnow()
        duration = (end_time - self.start_time).total_seconds() if self.start_time else 0
        successful = sum(1 for p in self.phases_results if p.status == PhaseStatus.COMPLETED.value)
        
        return {
            "skill": "attack-chain-execution",
            "status": "success" if len(self.phases_results) > 0 else "failed",
            "campaign": {"target": target, "duration_seconds": round(duration, 2)},
            "phases": [asdict(p) for p in self.phases_results],
            "summary": {
                "phases_executed": len(self.phases_results),
                "phases_successful": successful,
                "access_achieved": False
            }
        }


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Attack Chain Orchestrator")
    parser.add_argument("target", help="Target IP or hostname")
    parser.add_argument("--phases", nargs="+", type=int, default=[1, 2, 3, 4, 5])
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--output", "-o", help="Output file")
    args = parser.parse_args()
    
    orchestrator = AttackChainOrchestrator(force=args.force)
    report = orchestrator.execute_chain(args.target, args.phases)
    output = json.dumps(report, indent=2)
    print(output)
    
    if args.output:
        with open(args.output, "w") as f:
            f.write(output)


if __name__ == "__main__":
    main()
