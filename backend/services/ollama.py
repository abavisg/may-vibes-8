import os
import requests
import json
from fastapi import HTTPException
from typing import Tuple, List


def reframe_thought(thought: str) -> Tuple[List[str], str]:
    """
    Call Ollama via local API to reframe the thought.
    Returns a tuple of (suggestions, tag).
    """
    ollama_url = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434")
    model = os.getenv("OLLAMA_MODEL")
    if not model:
        raise HTTPException(status_code=500, detail="OLLAMA_MODEL not configured")
    system_prompt = {
        "role": "system",
        "content": (
            "You are a compassionate therapist. "
            "When given a negative thought, provide three concise positive reframes under 'suggestions' "
            "and a one-word or short 'tag' summarizing the theme. Respond only with valid JSON."
        )
    }
    user_prompt = {"role": "user", "content": f"Thought: \"{thought}\""}
    payload = {"model": model, "messages": [system_prompt, user_prompt]}
    try:
        resp = requests.post(f"{ollama_url}/v1/chat/completions", json=payload, timeout=15)
        resp.raise_for_status()
        data = resp.json()
        content = data["choices"][0]["message"]["content"]
        parsed = json.loads(content)
        suggestions = parsed.get("suggestions", [])
        tag = parsed.get("tag", "")
    except Exception:
        # Fallback stub in case of errors
        suggestions = [
            f"Positive reframe 1 for: {thought}",
            f"Positive reframe 2 for: {thought}",
            f"Positive reframe 3 for: {thought}",
        ]
        tag = "Fallback-Tag"
    return suggestions, tag 