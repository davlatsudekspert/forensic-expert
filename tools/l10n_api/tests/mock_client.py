"""Mock Anthropic mijozi (tarmoqsiz)."""
from types import SimpleNamespace


class _Stream:
    def __init__(self, resp):
        self.resp = resp

    def __enter__(self):
        return self

    def __exit__(self, *a):
        return False

    def get_final_message(self):
        return self.resp


class MockClient:
    """responder(kw) -> str (JSON matn) yoki Exception ko'tarishi mumkin."""

    def __init__(self, responder, in_tok=1000, out_tok=500):
        self.responder, self.calls = responder, []
        self.in_tok, self.out_tok = in_tok, out_tok
        self.messages = SimpleNamespace(stream=self._stream)

    def _stream(self, **kw):
        self.calls.append(kw)
        text = self.responder(kw)
        usage = SimpleNamespace(input_tokens=self.in_tok, output_tokens=self.out_tok,
                                cache_creation_input_tokens=0, cache_read_input_tokens=0)
        return _Stream(SimpleNamespace(content=[SimpleNamespace(type="text", text=text)], usage=usage, stop_reason="end_turn"))


def user_of(kw):
    return kw["messages"][0]["content"][0]["text"]
