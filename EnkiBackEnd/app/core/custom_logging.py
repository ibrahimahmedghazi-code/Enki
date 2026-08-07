import logging
from enum import StrEnum

LOG_FORMAT_DEBUG = "%(levelname)s | %(message)s | %(pathname)s:%(lineno)d"
LOG_FORMAT_DEFAULT = "%(levelname)s | %(message)s"

class LogLevels(StrEnum):
    INFO = "INFO"
    WARN = "WARNING"
    ERROR = "ERROR"
    DEBUG = "DEBUG"

def configure_logging(level: str = LogLevels.INFO):
    level_name = level.upper()
    
    # Fallback to ERROR if level is invalid
    if level_name not in LogLevels.__members__:
        level_to_set = logging.ERROR
    else:
        level_to_set = level_name

    log_format = LOG_FORMAT_DEBUG if level_to_set == "DEBUG" else LOG_FORMAT_DEFAULT

    logging.basicConfig(
        level=level_to_set,
        format=log_format,
        force=True
    )
    logging.info(f"Enki Logger initialized at {level_to_set}")
