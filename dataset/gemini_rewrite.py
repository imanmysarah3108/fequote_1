import time
from dataset.fer_gemini import get_client

REWRITE_PROMPT = """
You are a motivational quote rewriting assistant.

Given:
1. Original motivational quote
2. User situation/context

Rewrite the quote so it becomes more personal, encouraging and emotionally supportive.

Requirements:
- Preserve original meaning
- Maximum 50 words
- Simple English
- Positive tone
- Return only the rewritten quote
- No explanation
- No quotation marks
- No markdown formatting

Original quote:
{quote}

User context:
{context}
"""


def rewrite_quote(original_quote: str, context: str) -> str:
    client = get_client()
    prompt = REWRITE_PROMPT.format(quote=original_quote.strip(), context=context.strip())

    for attempt in range(3):
        try:
            response = client.generate_content(prompt)
            text = response.text.strip()
            text = text.strip('"').strip("'").strip()
            return text
        except Exception as error:
            print(f"Rewrite retry {attempt + 1}:", error)
            time.sleep(2)

    raise RuntimeError("Failed to rewrite quote after multiple attempts")
