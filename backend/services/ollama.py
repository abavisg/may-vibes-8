import os
import requests
import json
from fastapi import HTTPException
from typing import Tuple, List
from services.categories import get_categories


def reframe_thought(thought: str) -> Tuple[List[str], str]:
    """
    Call Ollama via local API to reframe the thought.
    Returns a tuple of (suggestions, tag).
    """
    ollama_url = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434")
    model = os.getenv("OLLAMA_MODEL")
    if not model:
        raise HTTPException(status_code=500, detail="OLLAMA_MODEL not configured")
    # Incorporate fixed categories into the prompt
    categories = get_categories()
    categories_str = ", ".join(categories)
    system_prompt = {
        "role": "system",
        "content": (
            f"You are a compassionate therapist. "
            f"When given a negative thought, provide three concise positive reframes under 'suggestions' "
            f"and choose one 'tag' from the following categories: {categories_str}. "
            f"Respond only with valid JSON using keys 'suggestions' and 'tag'."
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


def get_sos_technique(feeling: str) -> str:
    """
    Call Ollama via local API to get an immediate coping technique.
    Returns a single technique as a string.
    """
    ollama_url = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434")
    model = os.getenv("OLLAMA_MODEL")
    if not model:
        # Fallback technique if model is not configured
        return "Take three deep breaths."

    system_prompt = {
        "role": "system",
        "content": (
            "You are a mindfulness and emotional regulation coach.\n"
            "A user just tapped the SOS button in a mindfulness app because they are feeling overwhelmed or anxious.\n"
            "\n"
            "Provide one short calming technique or exercise (1–2 sentences) the user can try right now.\n"
            "\n"
            "Focus on techniques that involve:\n"
            "\t•\tBreathing\n"
            "\t•\tBody awareness\n"
            "\t•\tSelf-compassion\n"
            "\t•\tSensory grounding\n"
            "\t•\tDisrupting negative thought spirals\n"
            "\n"
            "Keep it practical, non-spiritual, and beginner-friendly. No jargon.\n"
            "\n"
            "Return your response as plain text."
        )
    }
    user_prompt = {"role": "user", "content": f"Feeling/Situation: {feeling}"}
    payload = {"model": model, "messages": [system_prompt, user_prompt]}

    try:
        resp = requests.post(f"{ollama_url}/v1/chat/completions", json=payload, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        # The response should be plain text based on the prompt
        technique = data["choices"][0]["message"]["content"].strip()
        # Simple post-processing to clean up potential quotes or formatting
        if technique.startswith('"') and technique.endswith('"'):
            technique = technique[1:-1]

    except Exception:
        # Fallback technique in case of errors
        technique = "Try a quick grounding exercise: Notice 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste."

    return technique 