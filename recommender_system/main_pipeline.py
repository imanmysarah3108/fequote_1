# Re-exports the CBF recommender so callers can import it from the pipeline
# module. api_server.py imports `recommend_quotes` from here.
from recommender_system.quote_recommender import recommend_quotes

__all__ = ["recommend_quotes"]
