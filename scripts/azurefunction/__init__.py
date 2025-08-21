import logging
import subprocess
import azure.functions as func

def main(mytimer: func.TimerRequest) -> None:
    """
    Función activada por un temporizador para ejecutar el script de snapshot.
    """
    logging.info('Python timer trigger function started.')

    try:
        # Llama al script Bash
        result = subprocess.run(
            ['/bin/bash', 'qdrant_volume_snapshot.sh'],
            check=True,
            capture_output=True,
            text=True
        )
        
        logging.info(f"Script output: {result.stdout}")
        
        if result.returncode != 0:
            logging.error(f"Script failed with exit code {result.returncode}: {result.stderr}")
            
    except subprocess.CalledProcessError as e:
        logging.error(f"Script execution failed: {e.stderr}")
        
    except Exception as ex:
        logging.error(f"An unexpected error occurred: {ex}")