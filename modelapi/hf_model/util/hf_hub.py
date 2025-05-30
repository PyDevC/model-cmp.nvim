from huggingface_hub import login, logout

from logging import log
import time

def hflogin(token=None, newlogin=False, retrytime=1.0)->None:
    # Create logs for each step
    if token is None:
        log(1,"HF_TOKEN is empty set HF_TOKEN with your access token of huggingface")
    while True:
        try:
            login(token, new_session=newlogin)
            break
        except Exception as e:
            if e is ValueError:
                log(1, f"Invalid token: {e}")
                break
            else:
                log(1, f"Login failed: {e}, Retrying in 1s")
                time.sleep(retrytime)

def hflogout(token=None)->None:
    if token is None:
        log(1, "Token is empty Add a vaild token")
    try:
        logout(token)
    except Exception as e:
        log(1, f"Logout failed: {e}")
