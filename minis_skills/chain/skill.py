import logging
logging.basicConfig(level=logging.WARNING)
def run(payload, role="chain"):
    try:
        return {"role": role, "status": "done", "payload": payload}
    except Exception as e:
        logging.error(f"error: {e}")
        return {"error": str(e)}
